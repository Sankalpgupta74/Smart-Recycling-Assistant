import Hero from "@/components/Hero";
import Features from "@/components/Features";
import AIDemo from "@/components/AIDemo";

export default function Home() {
  return (
    <main className="min-h-screen">
      <Hero />
      <Features />
      <AIDemo />
      
      {/* Final CTA Section */}
      <section className="py-32 relative overflow-hidden bg-gradient-to-br from-[#00E676]/10 via-transparent to-[#00B0FF]/10">
        <div className="container px-6 mx-auto text-center border glass border-white/5 py-20 rounded-[4rem] shadow-3xl">
          <h2 className="mb-6 text-5xl font-bold md:text-7xl">
            Start Your Journey <br />
            <span className="text-[#00E676]">Today</span>
          </h2>
          <p className="max-w-xl mx-auto mb-10 text-xl text-white/40">
            Available now for iOS and Android. Join 1M+ users making a difference.
          </p>
          <div className="flex flex-col items-center justify-center gap-4 sm:flex-row">
            <button className="px-10 py-5 text-xl font-bold text-black bg-[#00E676] rounded-2xl hover:bg-[#00C853] transition-all hover:scale-105 active:scale-95 shadow-[0_0_40px_-10px_rgba(0,230,118,0.5)]">
              App Store
            </button>
            <button className="px-10 py-5 text-xl font-bold text-black bg-white rounded-2xl hover:bg-white/90 transition-all hover:scale-105 active:scale-95">
              Google Play
            </button>
          </div>
        </div>
      </section>
    </main>
  );
}
