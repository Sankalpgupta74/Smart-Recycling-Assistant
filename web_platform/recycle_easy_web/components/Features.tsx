"use client";

import { motion } from "framer-motion";
import { Camera, Map, Award, Globe, Search, Database } from "lucide-react";

const features = [
  {
    icon: Camera,
    title: "AI Vision Scanner",
    desc: "Instantly recognize 1,000+ materials using our specialized on-device TFLite model.",
    color: "#00E676"
  },
  {
    icon: Search,
    title: "OCR Enrichment",
    desc: "Package reading extracted automatically to confirm disposal rules for various brands.",
    color: "#00B0FF"
  },
  {
    icon: Map,
    title: "Community Intelligence",
    desc: "Real-time waste reporting and navigation to nearby recycling centers.",
    color: "#FFCA28"
  },
  {
    icon: Award,
    title: "Impact Rewards",
    desc: "Earn points and level up as you contribute to a cleaner, more sustainable planet.",
    color: "#FF7043"
  },
  {
    icon: Globe,
    title: "Global Reach",
    desc: "100+ languages supported with location-aware rules for multiple countries.",
    color: "#AB47BC"
  },
  {
    icon: Database,
    title: "Cloud Sync",
    desc: "Seamlessly backup your recycling journey and impact history in the cloud.",
    color: "#29B6F6"
  }
];

export default function Features() {
  return (
    <section className="py-32 bg-[#0A0E14] relative overflow-hidden">
      <div className="container px-6 mx-auto">
        <div className="max-w-3xl mb-20">
          <h2 className="mb-6 text-4xl font-bold md:text-5xl">
            More than just an <br />
            <span className="text-[#00E676]">Identity Tool</span>
          </h2>
          <p className="text-xl text-white/40">
            We've built a comprehensive ecosystem for modern waste management, 
            blending AI with community-driven action.
          </p>
        </div>

        <div className="grid grid-cols-1 gap-8 md:grid-cols-2 lg:grid-cols-3">
          {features.map((f, i) => (
            <motion.div
              key={f.title}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: i * 0.1 }}
              className="p-8 border glass-card border-white/5 rounded-3xl group"
            >
              <div 
                className="w-14 h-14 mb-6 rounded-2xl flex items-center justify-center transition-all group-hover:scale-110"
                style={{ backgroundColor: `${f.color}15` }}
              >
                <f.icon className="w-8 h-8" style={{ color: f.color }} />
              </div>
              <h3 className="mb-3 text-xl font-bold text-white">{f.title}</h3>
              <p className="leading-relaxed text-white/40">{f.desc}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
