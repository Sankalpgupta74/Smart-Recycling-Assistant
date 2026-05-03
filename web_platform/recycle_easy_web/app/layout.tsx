import type { Metadata } from "next";
import { Outfit } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import { Download } from "lucide-react";

const outfit = Outfit({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Recycle Easy | AI-Powered Waste Intelligence",
  description: "The future of waste management in your pocket. Identify waste, track your impact, and join 1M+ recyclers globaly.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" className="dark">
      <body className={`${outfit.className} bg-[#0A0E14] text-white antialiased`}>
        {/* Navigation */}
        <header className="fixed top-0 left-0 right-0 z-50 px-6 py-4">
          <nav className="container flex items-center justify-between px-6 py-3 mx-auto border glass border-white/5 rounded-2xl">
            <div className="flex items-center gap-2">
              <div className="flex items-center justify-center w-8 h-8 rounded-lg bg-gradient-to-br from-[#00E676] to-[#00B0FF]">
                <LeafIcon className="w-5 h-5 text-black" />
              </div>
              <span className="text-xl font-bold tracking-tight">RecycleEasy</span>
            </div>
            
            <div className="hidden gap-8 text-sm font-medium transition-colors md:flex text-white/50">
              <Link href="#" className="hover:text-white">Features</Link>
              <Link href="#" className="hover:text-white">About Us</Link>
              <Link href="#" className="hover:text-white">API</Link>
              <Link href="#" className="hover:text-white">Impact</Link>
            </div>

            <button className="flex items-center gap-2 px-4 py-2 text-sm font-bold text-black transition-all bg-[#00E676] rounded-xl hover:bg-[#00C853] hover:scale-105 active:scale-95">
              <Download className="w-4 h-4" />
              Get the App
            </button>
          </nav>
        </header>

        {children}

        {/* Footer */}
        <footer className="py-20 border-t border-white/5">
          <div className="container px-6 mx-auto text-center">
            <div className="flex items-center justify-center gap-2 mb-8">
              <span className="text-2xl font-bold">RecycleEasy</span>
            </div>
            <p className="mb-10 text-white/30 max-w-md mx-auto">
              Empowering global change through local waste intelligence. Join the community of a cleaner planet today.
            </p>
            <div className="flex justify-center gap-6 text-sm text-white/40">
              <Link href="#">Terms</Link>
              <Link href="#">Privacy</Link>
              <Link href="#">Open Source</Link>
              <Link href="#">Contact</Link>
            </div>
            <div className="mt-12 text-xs text-white/10 uppercase tracking-widest">
              © 2026 RecycleEasy Platform. All rights reserved.
            </div>
          </div>
        </footer>
      </body>
    </html>
  );
}

function LeafIcon(props: any) {
  return (
    <svg 
      {...props} 
      viewBox="0 0 24 24" 
      fill="none" 
      stroke="currentColor" 
      strokeWidth="2.5" 
      strokeLinecap="round" 
      strokeLinejoin="round"
    >
      <path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8a8 8 0 0 1-8 8Z" />
      <path d="M19 21c-3 0-6-3-6-3" />
    </svg>
  );
}
