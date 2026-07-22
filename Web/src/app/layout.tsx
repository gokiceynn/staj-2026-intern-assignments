import type { Metadata } from "next";
import { Inter } from "next/font/google";
import { Providers } from "@/components/providers";
import { Header } from "@/components/layout/Header";
import { Footer } from "@/components/layout/Footer";
import { AiAssistant } from "@/components/ai/AiAssistant";
import { WelcomeCampaignModal } from "@/components/campaign/WelcomeCampaignModal";
import { ToastContainer } from "@/components/ui/Toast";
import "./globals.css";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "VBShop — Online Alışveriş",
  description: "VBShop B2C e-ticaret platformu",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="tr" suppressHydrationWarning>
      <body className={`${inter.className} flex min-h-screen flex-col`}>
        <Providers>
          <Header />
          <main className="mx-auto w-full max-w-7xl flex-1 px-4 py-6">
            {children}
          </main>
          <Footer />
          <WelcomeCampaignModal />
          <AiAssistant />
          <ToastContainer />
        </Providers>
      </body>
    </html>
  );
}
