FROM node:22-alpine3.18 AS base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Rebuild the source code only when needed
FROM base AS builder

# install deps
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# build time args
ARG GRIST_URL
ENV GRIST_URL $GRIST_URL
ARG GRIST_DOC_ID
ENV GRIST_DOC_ID $GRIST_DOC_ID

RUN --mount=type=secret,id=sentry_auth_token \
  --mount=type=secret,id=grist_api_key \
  --mount=type=secret,id=grist_doc_id \
  export SENTRY_AUTH_TOKEN="$(cat /run/secrets/sentry_auth_token)"; \
  export GRIST_API_KEY="$(cat /run/secrets/grist_api_key)"; \
  export GRIST_DOC_ID="$(cat /run/secrets/grist_doc_id)"; \
  npm run build


# Production image, copy all the files and run next
FROM base AS runner

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs && \
  adduser --system --uid 1001 nextjs

COPY --from=builder /app/next.config.mjs ./
COPY --from=builder /app/public ./public

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER 1001
EXPOSE 3000
ENV PORT 3000
ENV HOSTNAME="0.0.0.0"

CMD ["node", "server.js"]
