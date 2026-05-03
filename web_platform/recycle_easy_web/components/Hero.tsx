"use client";

import { motion } from "framer-motion";
import { ArrowRight, Leaf, Shield, Zap } from "lucide-react";
import { cn } from "@/lib/utils";

export default function Hero() {
  return (
    <section className="relative min-height-[90vh] flex items-center justify-center pt-32 pb-20 overflow-hidden">
      {/* Dynamic Background */}
      <div className="absolute inset-0 z-0">
        <div className="absolute top-1/4 left-1/4 w-96 h-96 bg-[#00E676]/10 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-1/4 right-1/4 w-96 h-96 bg-[#00B0FF]/10 rounded-full blur-[120px] animate-pulse delay-700" />
      </div>

      <div className="container relative z-10 px-6 mx-auto text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6 }}
          className="inline-flex items-center gap-2 px-4 py-2 mb-8 text-sm font-medium border rounded-full glass border-white/10"
        >
          <span className="flex h-2 w-2 rounded-full bg-[#00E676] animate-ping" />
          <span className="text-white/60">Now Live: v1.0.0 for iOS & Android</span>
        </motion.div>

        <motion.h1 
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.1 }}
          className="max-w-4xl mx-auto mb-6 text-6xl font-bold leading-tight tracking-tight md:text-8xl"
        >
          The Future of <br />
          <span className="text-transparent bg-clip-text bg-gradient-to-r from-[#00E676] to-[#00B0FF]">
            Waste Intelligence
          </span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.6, delay: 0.2 }}
          className="max-w-2xl mx-auto mb-10 text-lg md:text-xl text-white/50"
        >
          Identify any waste material instantly using AI, track your impact, and join a global community for a cleaner planet.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, scale: 0.95 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.6, delay: 0.3 }}
          className="flex flex-col items-center justify-center gap-4 sm:flex-row"
        >
          <button className="px-8 py-4 text-lg font-bold text-black bg-[#00E676] rounded-2xl hover:bg-[#00C853] transition-all hover:scale-105 active:scale-95 shadow-[0_0_30px_-10px_rgba(0,230,118,0.5)]">
            Download the App
          </button>
          <button className="px-8 py-4 text-lg font-bold transition-all border rounded-2xl glass border-white/10 hover:bg-white/5 hover:scale-105 active:scale-95">
            Watch the Demo
            <ArrowRight className="inline-block ml-2 w-5 h-5" />
          </button>
        </motion.div>

        {/* Info Cards */}
        <div className="grid grid-cols-1 gap-6 mt-20 md:grid-cols-3">
          <FeatureMini 
            icon={Zap} 
            title="Fast AI Scanning" 
            desc="Classification in < 0.5s with OCR enhancement."
          />
          <FeatureMini 
            icon={Leaf} 
            title="Eco Rewards" 
            desc="Earn impact points for every successful scan."
          />
          <FeatureMini 
            icon={Shield} 
            title="Local Rules" 
            desc="Location-aware disposal guidance in 100+ languages."
          />
        </div>
      </div>
    </section>
  );
}

function FeatureMini({ icon: Icon, title, desc }: { icon: any, title: string, desc: string }) {
  return (
    <motion.div
      whileHover={{ y: -5 }}
      className="p-6 text-left transition-all border glass-card border-white/5 rounded-3xl"
    >
      <div className="flex items-center justify-center w-12 h-12 mb-4 bg-white/5 rounded-2xl">
        <Icon className="w-6 h-6 text-[#00E676]" />
      </div>
      <h3 className="mb-2 font-bold text-white">{title}</h3>
      <p className="text-sm text-white/40">{desc}</p>
    </motion.div>
  );
}
