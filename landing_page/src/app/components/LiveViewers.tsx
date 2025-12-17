import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useTheme } from '../context/ThemeContext';

export function LiveViewers() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  const [viewers, setViewers] = useState(7);
  const [isIncreasing, setIsIncreasing] = useState(true);

  // Calculate peak time multiplier based on local timezone
  const getPeakMultiplier = () => {
    const now = new Date();
    const hour = now.getHours();
    
    // Peak times and their multipliers
    // Morning rush: 7-9 AM (1.3x)
    if (hour >= 7 && hour < 9) return 1.3;
    
    // Lunch time: 12-2 PM (1.5x)
    if (hour >= 12 && hour < 14) return 1.5;
    
    // Evening prime time: 6-11 PM (1.8x - highest traffic)
    if (hour >= 18 && hour < 23) return 1.8;
    
    // Late night: 11 PM - 2 AM (1.2x - still decent traffic)
    if (hour >= 23 || hour < 2) return 1.2;
    
    // Work hours: 9 AM - 5 PM (0.7x - people at work)
    if (hour >= 9 && hour < 17) return 0.7;
    
    // Early morning: 2-7 AM (0.3x - lowest traffic)
    if (hour >= 2 && hour < 7) return 0.3;
    
    // Default
    return 1.0;
  };

  useEffect(() => {
    const updateViewers = () => {
      setViewers((prev) => {
        const peakMultiplier = getPeakMultiplier();
        
        // Base max is 12, adjusted by peak time
        const adjustedMax = Math.floor(12 * peakMultiplier);
        const adjustedMin = Math.floor(0 * peakMultiplier);
        
        // Random change between -2 and +2, but weighted towards the peak average
        const targetAverage = Math.floor((adjustedMax + adjustedMin) / 2);
        let change;
        
        // Tendency to move towards the target average
        if (prev < targetAverage) {
          change = Math.random() > 0.4 ? Math.floor(Math.random() * 3) : -1;
        } else if (prev > targetAverage) {
          change = Math.random() > 0.4 ? -Math.floor(Math.random() * 3) : 1;
        } else {
          change = Math.floor(Math.random() * 5) - 2; // -2 to +2
        }
        
        const newValue = prev + change;
        
        // Keep within bounds
        if (newValue > adjustedMax) {
          setIsIncreasing(false);
          return adjustedMax;
        }
        if (newValue < adjustedMin) {
          setIsIncreasing(true);
          return adjustedMin;
        }
        
        setIsIncreasing(change > 0);
        return newValue;
      });
      
      // Random interval between 1-60 seconds (1000-60000 milliseconds)
      const nextInterval = 1000 + Math.random() * 59000;
      setTimeout(updateViewers, nextInterval);
    };

    // Initial update
    const initialDelay = setTimeout(updateViewers, 2000);
    
    return () => clearTimeout(initialDelay);
  }, []);

  return (
    <motion.div
      initial={{ opacity: 0, x: -20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 1, delay: 2 }}
      className="fixed top-4 left-4 md:top-8 md:left-8 z-20 max-w-[calc(50vw-2rem)] sm:max-w-none"
    >
      <div className="relative">
        {/* Background glow */}
        <motion.div
          className="absolute -inset-4 blur-xl opacity-30 transition-all duration-500"
          style={{
            background: isUtopian
              ? 'radial-gradient(circle, rgba(255,215,0,0.4) 0%, transparent 70%)'
              : 'radial-gradient(circle, rgba(0,255,255,0.4) 0%, transparent 70%)',
          }}
          animate={{
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{ duration: 2, repeat: Infinity }}
        />

        {/* Main container */}
        <div className={`relative backdrop-blur-sm border px-3 py-2 md:px-4 md:py-3 transition-all duration-500 ${
          isUtopian ? 'bg-white/70 border-amber-400/50' : 'bg-black/50 border-cyan-400/30'
        }`}>
          {/* Corner brackets */}
          <div className={`absolute -left-1 -top-1 w-3 h-3 border-l-2 border-t-2 transition-colors duration-500 ${
            isUtopian ? 'border-amber-500' : 'border-cyan-400'
          }`} />
          <div className={`absolute -right-1 -top-1 w-3 h-3 border-r-2 border-t-2 transition-colors duration-500 ${
            isUtopian ? 'border-amber-500' : 'border-cyan-400'
          }`} />
          <div className={`absolute -left-1 -bottom-1 w-3 h-3 border-l-2 border-b-2 transition-colors duration-500 ${
            isUtopian ? 'border-amber-500' : 'border-cyan-400'
          }`} />
          <div className={`absolute -right-1 -bottom-1 w-3 h-3 border-r-2 border-b-2 transition-colors duration-500 ${
            isUtopian ? 'border-amber-500' : 'border-cyan-400'
          }`} />

          <div className="flex items-center gap-3">
            {/* Pulsing indicator */}
            <div className="relative">
              <motion.div
                className={`w-2 h-2 rounded-full transition-colors duration-500 ${
                  isUtopian ? 'bg-amber-400' : 'bg-cyan-400'
                }`}
                style={{
                  boxShadow: isUtopian ? '0 0 10px rgba(255,215,0,0.8)' : '0 0 10px rgba(0,255,255,0.8)',
                }}
                animate={{
                  opacity: [1, 0.3, 1],
                  scale: [1, 0.8, 1],
                }}
                transition={{ duration: 2, repeat: Infinity }}
              />
              <motion.div
                className={`absolute inset-0 w-2 h-2 rounded-full transition-colors duration-500 ${
                  isUtopian ? 'bg-amber-400' : 'bg-cyan-400'
                }`}
                animate={{
                  scale: [1, 2, 1],
                  opacity: [0.8, 0, 0.8],
                }}
                transition={{ duration: 2, repeat: Infinity }}
              />
            </div>

            {/* Counter */}
            <div className="flex items-baseline gap-2">
              <AnimatePresence mode="wait">
                <motion.span
                  key={viewers}
                  initial={{ y: isIncreasing ? 10 : -10, opacity: 0 }}
                  animate={{ y: 0, opacity: 1 }}
                  exit={{ y: isIncreasing ? -10 : 10, opacity: 0 }}
                  transition={{ duration: 0.3 }}
                  className={`text-xl font-light tabular-nums transition-colors duration-500 ${
                    isUtopian ? 'text-amber-600' : 'text-cyan-400'
                  }`}
                  style={{
                    textShadow: isUtopian ? '0 0 10px rgba(255,215,0,0.4)' : '0 0 10px rgba(0,255,255,0.6)',
                  }}
                >
                  {viewers}
                </motion.span>
              </AnimatePresence>
              
              <span className={`text-xs uppercase tracking-wider transition-colors duration-500 ${
                isUtopian ? 'text-amber-700/70' : 'text-cyan-500/70'
              }`}>
                {isUtopian ? 'Visionaries' : 'Neural Entities'}
              </span>
            </div>
          </div>

          {/* Scanning line */}
          <motion.div
            className="absolute bottom-0 left-0 right-0 h-[1px] transition-all duration-500"
            style={{
              background: isUtopian
                ? 'linear-gradient(90deg, transparent, rgba(255,215,0,0.8), transparent)'
                : 'linear-gradient(90deg, transparent, rgba(0,255,255,0.8), transparent)',
              boxShadow: isUtopian ? '0 0 5px rgba(255,215,0,0.5)' : '0 0 5px rgba(0,255,255,0.5)',
            }}
            animate={{
              scaleX: [0, 1, 0],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: "easeInOut",
            }}
          />

          {/* Status text */}
          <motion.div
            className={`text-[10px] uppercase tracking-widest mt-1 transition-colors duration-500 ${
              isUtopian ? 'text-amber-600/60' : 'text-cyan-600/60'
            }`}
            animate={{
              opacity: [0.4, 0.7, 0.4],
            }}
            transition={{ duration: 3, repeat: Infinity }}
          >
            {isUtopian ? '// ACTIVE NOW //' : '// LIVE NOW //'}
          </motion.div>
        </div>
      </div>
    </motion.div>
  );
}