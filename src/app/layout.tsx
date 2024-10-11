import { Footer } from "@/ui/Footer";
import { fr } from "@codegouvfr/react-dsfr";
import { headerFooterDisplayItem } from "@codegouvfr/react-dsfr/Display";
import Header from "@codegouvfr/react-dsfr/Header";
import MuiDsfrThemeProvider from "@codegouvfr/react-dsfr/mui";
import { DsfrHead } from "@codegouvfr/react-dsfr/next-appdir/DsfrHead";
import { DsfrProvider } from "@codegouvfr/react-dsfr/next-appdir/DsfrProvider";
import { getHtmlAttributes } from "@codegouvfr/react-dsfr/next-appdir/getHtmlAttributes";
import { Metadata } from "next";
import Link from "next/link";
import { NextAppDirEmotionCacheProvider } from "tss-react/next/appDir";
import { ConsentBannerAndConsentManagement } from "../ui/consentManagement";
import { StartDsfr } from "./StartDsfr";
import { defaultColorScheme } from "./defaultColorScheme";
import { Matomo } from "@/ui/Matomo";

export const metadata: Metadata = {
  title: {
    default: "Audit technique - Incubateur des Territoires (ANCT)",
    template: "%s | Audit technique - Incubateur des Territoires (ANCT)",
  },
};

export default async function RootLayout({
  children,
}: {
  children: JSX.Element;
}) {
  return (
    <html {...getHtmlAttributes({ defaultColorScheme })}>
      <head>
        <StartDsfr />
        <DsfrHead
          Link={Link}
          preloadFonts={[
            //"Marianne-Light",
            //"Marianne-Light_Italic",
            "Marianne-Regular",
            //"Marianne-Regular_Italic",
            "Marianne-Medium",
            //"Marianne-Medium_Italic",
            "Marianne-Bold",
            //"Marianne-Bold_Italic",
            //"Spectral-Regular",
            //"Spectral-ExtraBold"
          ]}
        />
        <Matomo/>
      </head>
      <body
        style={{
          minHeight: "100vh",
          display: "flex",
          flexDirection: "column",
        }}
      >
        <DsfrProvider>
          <ConsentBannerAndConsentManagement />
          <NextAppDirEmotionCacheProvider options={{ key: "css" }}>
            <MuiDsfrThemeProvider>
              <Header
                brandTop={<>ANCT</>}
                serviceTitle={"Audits techniques de l'incubateur de l'ANCT"}
                homeLinkProps={{
                  href: "/",
                  title: "Audits techniques - ANCT",
                }}
                quickAccessItems={[headerFooterDisplayItem]}
              />
              <div
                style={{
                  flex: 1,
                  margin: "auto",
                  maxWidth: 1000,
                  ...fr.spacing("padding", {
                    topBottom: "10v",
                  }),
                }}
              >
                {children}
              </div>
            </MuiDsfrThemeProvider>
            <Footer />
          </NextAppDirEmotionCacheProvider>
        </DsfrProvider>
      </body>
    </html>
  );
}
