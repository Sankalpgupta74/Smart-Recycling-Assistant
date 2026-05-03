"use client";

import { motion, AnimatePresence } from "framer-motion";
import { Camera, Search, CheckCircle2, ShieldAlert, Zap, ArrowRight } from "lucide-react";
import { useState, useEffect } from "react";

const DEMO_STEPS = [
  {
    icon: Camera,
    text: "Capturing waste material...",
    color: "#00E676",
  },
  {
    icon: Search,
    text: "Analyzing with TFLite model...",
    color: "#00B0FF",
  },
  {
    icon: Zap,
    text: "Confirming with OCR Fusion...",
    color: "#AB47BC",
  },
];

export default function AIDemo() {
  const [step, setStep] = useState(0);
  const [isDemoRunning, setIsDemoRunning] = useState(false);

  useEffect(() => {
    if (isDemoRunning) {
      const interval = setInterval(() => {
        setStep((s) => (s + 1) % (DEMO_STEPS.length + 1));
      }, 2000);
      return () => clearInterval(interval);
    }
  }, [isDemoRunning]);

  const startDemo = () => {
    setStep(0);
    setIsDemoRunning(true);
  };

  return (
    <section className="py-32 bg-[#0A0E14] relative overflow-hidden">
      <div className="container px-6 mx-auto">
        <div className="flex flex-col items-center gap-16 lg:flex-row">
          <div className="flex-1 max-w-2xl">
            <h2 className="mb-6 text-4xl font-bold md:text-5xl">
              Experience the <br />
              <span className="text-white/40 italic">Intelligence</span>
            </h2>
            <p className="mb-8 text-xl text-white/40">
              Our specialized AI engine doesn't just "guess." It uses a fusion of computer vision and character recognition to provide extreme accuracy.
            </p>
            
            <div className="space-y-6">
              <CheckItem text="On-device inference for maximum privacy" />
              <CheckItem text="Real-time OCR for package confirmation" />
              <CheckItem text="Dynamic rule library for 100+ countries" />
            </div>

            <button 
              onClick={startDemo}
              className="mt-10 px-8 py-4 text-lg font-bold transition-all border rounded-2xl glass border-white/10 hover:bg-white/5"
            >
              Start System Demo
              <ArrowRight className="inline-block ml-2 w-5 h-5" />
            </button>
          </div>

          <div className="flex-1 w-full lg:w-auto">
            <div className="relative p-8 border glass border-white/10 rounded-[3rem] aspect-square lg:aspect-[4/5] max-w-sm mx-auto shadow-2xl">
              {/* Simulator Screen */}
              <div className="absolute inset-4 bg-black rounded-[2.2rem] overflow-hidden">
                <AnimatePresence mode="wait">
                  {step < DEMO_STEPS.length ? (
                    <motion.div
                      key={step}
                      initial={{ opacity: 0 }}
                      animate={{ opacity: 1 }}
                      exit={{ opacity: 0 }}
                      className="flex flex-col items-center justify-center h-full px-8 text-center"
                    >
                      <div className="w-20 h-20 mb-6 rounded-full flex items-center justify-center animate-pulse" style={{ backgroundColor: `${DEMO_STEPS[step].color}15` }}>
                        {/* Correct type for icon usage */}
                        {(() => {
                           const Icon = DEMO_STEPS[step].icon;
                           return <Icon className="w-10 h-10" style={{ color: DEMO_STEPS[step].color }} />;
                        })()}
                      </div>
                      <p className="text-lg font-medium text-white/80">{DEMO_STEPS[step].text}</p>
                    </motion.div>
                  ) : (
                    <motion.div
                      key="result"
                      initial={{ opacity: 0, scale: 0.9 }}
                      animate={{ opacity: 1, scale: 1 }}
                      className="flex flex-col items-center justify-center h-full p-8"
                    >
                      <div className="w-16 h-16 mb-4 bg-[#00E676]/20 rounded-full flex items-center justify-center">
                        <CheckCircle2 className="w-8 h-8 text-[#00E676]" />
                      </div>
                      <h3 className="text-2xl font-bold text-white mb-2">Plastic Identified</h3>
                      <p className="text-sm text-center text-white/40 mb-6">Confidence: 98.4%</p>
                      
                      <div className="w-full p-4 border rounded-2xl bg-white/5 border-white/10">
                        <p className="text-xs font-bold uppercase tracking-widest text-[#00E676] mb-1">Recommended Bin</p>
                        <p className="text-white font-medium">Yellow (Waste Collection)</p>
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
                
                {/* Simulator UI */}
                <div className="absolute bottom-6 left-6 right-6 flex justify-between">
                   <div className="w-12 h-12 rounded-full border glass border-white/20 flex items-center justify-center">
                      <Camera className="w-6 h-6 text-white/40" />
                   </div>
                   <div className="w-12 h-12 rounded-full border glass border-white/20 flex items-center justify-center">
                      <ShieldAlert className="w-6 h-6 text-white/40" />
                   </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}

function CheckItem({ text }: { text: string }) {
  return (
    <div className="flex items-center gap-3">
      <div className="flex h-6 w-6 items-center justify-center rounded-full bg-[#00E676]/20">
        <CheckCircle2 className="h-4 w-4 text-[#00E676]" />
      </div>
      <span className="text-white/60">{text}</span>
    </div>
  );
}
