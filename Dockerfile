FROM node:22-alpine3.18 as base
RUN apk add --no-cache libc6-compat
WORKDIR /app

# Rebuild the source code only when needed
FROM base AS builder

# install deps
COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# build time args
ARG NEXT_PUBLIC_MATOMO_URL
ENV NEXT_PUBLIC_MATOMO_URL $NEXT_PUBLIC_MATOMO_URL
ARG NEXT_PUBLIC_MATOMO_SITE_ID
ENV NEXT_PUBLIC_MATOMO_SITE_ID $NEXT_PUBLIC_MATOMO_SITE_ID
ARG NEXT_PUBLIC_SENTRY_DSN
ENV NEXT_PUBLIC_SENTRY_DSN $NEXT_PUBLIC_SENTRY_DSN
ARG GRIST_URL
ENV GRIST_URL $GRIST_URL
ARG GRIST_DOC_ID
ENV GRIST_DOC_ID $GRIST_DOC_ID

RUN --mount=type=secret,id=sentry_auth_token \
  --mount=type=secret,id=grist_api_key \
  export SENTRY_AUTH_TOKEN="$(cat /run/secrets/sentry_auth_token)"; \
  export GRIST_API_KEY="$(cat /run/secrets/grist_api_key)"; \
  npm run build


# Production image, copy all the files and run next
FROM base AS runner

ENV NODE_ENV production
ENV NEXT_TELEMETRY_DISABLED 1

RUN addgroup --system --gid 1001 nodejs && \
  adduser --system --uid 1001 nextjs

COPY --from=builder /app/next.config.js ./
COPY --from=builder /app/public ./public

COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./.next/static

USER 1001
EXPOSE 3000
ENV PORT 3000

CMD ["node", "server.js"]