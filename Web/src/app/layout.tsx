import type { Metadata, Viewport } from "next";
import { Inter } from "next/font/google";
import { Providers } from "@/components/providers";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { SkipToContent } from "@/components/layout/SkipToContent";
import { AiAssistant } from "@/components/ai/AiAssistant";
import { WelcomeCampaignModal } from "@/components/campaign/WelcomeCampaignModal";
import { ToastContainer } from "@/components/ui/Toast";
import { ThemeFloatingToggle } from "@/components/layout/ThemeFloatingToggle";
import { BottomNav } from "@/components/layout/BottomNav";
import "./globals.css";

const inter = Inter({ subsets: ["latin"], display: "swap" });

export const metadata: Metadata = {
  title: "VBShop — Online Alışveriş",
  description: "VBShop B2C e-ticaret platformu",
  metadataBase: process.env.NEXT_PUBLIC_APP_URL
    ? new URL(process.env.NEXT_PUBLIC_APP_URL)
    : undefined,
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#ff6000" },
    { media: "(prefers-color-scheme: dark)", color: "#0F1115" },
  ],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="tr" suppressHydrationWarning>
      <head>
        <script
          dangerouslySetInnerHTML={{
            __html: `(function(){try{var t=localStorage.getItem("vbshop_theme");if(t==="dark")document.documentElement.classList.add("dark");else if(t==="light")document.documentElement.classList.remove("dark");}catch(e){}})();`,
          }}
        />
      </head>
      <body className={`${inter.className} flex min-h-screen flex-col`}>
        <Providers>
          <SkipToContent />
          <Header />
          <main
            id="main-content"
            tabIndex={-1}
            className="mx-auto w-full max-w-7xl flex-1 px-4 py-3 pb-20 outline-none md:py-6 md:pb-6"
          >
            {children}
          </main>
          <Footer className="hidden md:block" />
          <BottomNav />
          <ThemeFloatingToggle />
          <WelcomeCampaignModal />
          <AiAssistant />
          <ToastContainer />
        </Providers>
      </body>
    </html>
  );
}
