import type { Metadata } from "next";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import "./globals.css";

export const metadata: Metadata = {
  metadataBase: new URL("https://sustainersnest.org"),
  title: {
    default: "Sustainers NEST — Nature, Science & Technology",
    template: "%s — Sustainers NEST",
  },
  description:
    "A youth-driven environmental organization helping young people build nature-inspired solutions through science and technology.",
  openGraph: {
    title: "Sustainers NEST",
    description: "Nature, science and technology for a sustainable future.",
    type: "website",
  },
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="en">
      <body>
        <SiteHeader />
        <main>{children}</main>
        <SiteFooter />
      </body>
    </html>
  );
}
