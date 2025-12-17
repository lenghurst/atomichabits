import { useState, useEffect, memo } from 'react';
import { motion, AnimatePresence } from 'motion/react';
import { useTheme } from '../context/ThemeContext';

// Memoized TimeUnit component - only re-renders when value or theme changes
const TimeUnit = memo(({ value, label }: { value: number; label: string }) => {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  
  return (
    <div className="flex flex-col items-center">
      <div className="relative h-12 flex items-center justify-center">
        <AnimatePresence mode="wait">
          <motion.div
            key={value}
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            transition={{ duration: 0.4, ease: 'easeInOut' }}
            className="absolute"
          >
            <div 
              className={`text-2xl md:text-3xl font-light tracking-wider tabular-nums transition-colors duration-500 ${
                isUtopian ? 'text-amber-600' : 'text-cyan-400'
              }`}
              style={{
                textShadow: isUtopian
                  ? '0 0 10px rgba(255,215,0,0.4), 0 0 20px rgba(255,215,0,0.2)'
                  : '0 0 10px rgba(0,255,255,0.6), 0 0 20px rgba(0,255,255,0.3)',
              }}
            >
              {String(value).padStart(2, '0')}
            </div>
          </motion.div>
        </AnimatePresence>
        
        {/* Corner brackets for each number */}
        <div className={`absolute -left-2 -top-1 w-2 h-2 border-l border-t transition-colors duration-500 ${
          isUtopian ? 'border-amber-400/40' : 'border-cyan-400/40'
        }`} />
        <div className={`absolute -right-2 -top-1 w-2 h-2 border-r border-t transition-colors duration-500 ${
          isUtopian ? 'border-amber-400/40' : 'border-cyan-400/40'
        }`} />
        <div className={`absolute -left-2 -bottom-1 w-2 h-2 border-l border-b transition-colors duration-500 ${
          isUtopian ? 'border-amber-400/40' : 'border-cyan-400/40'
        }`} />
        <div className={`absolute -right-2 -bottom-1 w-2 h-2 border-r border-b transition-colors duration-500 ${
          isUtopian ? 'border-amber-400/40' : 'border-cyan-400/40'
        }`} />
      </div>
      
      <div className={`text-[10px] md:text-xs mt-2 tracking-[0.2em] uppercase transition-colors duration-500 ${
        isUtopian ? 'text-amber-700/70' : 'text-cyan-600'
      }`}>
        {label}
      </div>
    </div>
  );
}, (prevProps, nextProps) => {
  // Custom comparison: only re-render if value actually changed
  return prevProps.value === nextProps.value && prevProps.label === nextProps.label;
});

TimeUnit.displayName = 'TimeUnit';

export function Countdown() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  const [timeLeft, setTimeLeft] = useState({
    days: 0,
    hours: 0,
    minutes: 0,
    seconds: 0,
  });

  useEffect(() => {
    const calculateTimeLeft = () => {
      const now = new Date();
      const endOfYear = new Date('2025-12-31T23:59:59');
      const difference = endOfYear.getTime() - now.getTime();

      if (difference > 0) {
        const newTimeLeft = {
          days: Math.floor(difference / (1000 * 60 * 60 * 24)),
          hours: Math.floor((difference / (1000 * 60 * 60)) % 24),
          minutes: Math.floor((difference / 1000 / 60) % 60),
          seconds: Math.floor((difference / 1000) % 60),
        };
        
        // Only update state if values actually changed
        setTimeLeft(prev => {
          if (prev.days !== newTimeLeft.days || 
              prev.hours !== newTimeLeft.hours || 
              prev.minutes !== newTimeLeft.minutes || 
              prev.seconds !== newTimeLeft.seconds) {
            return newTimeLeft;
          }
          return prev;
        });
      }
    };

    calculateTimeLeft();
    const timer = setInterval(calculateTimeLeft, 1000);

    return () => clearInterval(timer);
  }, []);

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 1, delay: 1, ease: [0.22, 1, 0.36, 1] }}
      className="w-full max-w-2xl mx-auto mb-12"
    >
      {/* Title */}
      <motion.div
        animate={{
          opacity: [0.4, 0.7, 0.4],
        }}
        transition={{ duration: 3, repeat: Infinity }}
        className={`text-center text-xs md:text-sm mb-6 tracking-[0.4em] uppercase font-light transition-colors duration-500 ${
          isUtopian ? 'text-amber-600' : 'text-cyan-500'
        }`}
      >
        {isUtopian ? 'NEW ERA BEGINS IN' : 'SYSTEM EVOLUTION IN'}
      </motion.div>

      {/* Countdown display */}
      <div className="relative">
        {/* Background glow */}
        <div 
          className="absolute inset-0 blur-2xl opacity-20 transition-all duration-500"
          style={{
            background: isUtopian
              ? 'radial-gradient(circle, rgba(255,215,0,0.3) 0%, transparent 70%)'
              : 'radial-gradient(circle, rgba(0,255,255,0.4) 0%, transparent 70%)',
          }}
        />
        
        <div className="relative grid grid-cols-4 gap-4 md:gap-8">
          <TimeUnit value={timeLeft.days} label="DAYS" />
          <TimeUnit value={timeLeft.hours} label="HRS" />
          <TimeUnit value={timeLeft.minutes} label="MIN" />
          <TimeUnit value={timeLeft.seconds} label="SEC" />
        </div>
      </div>

      {/* Scanning line */}
      <motion.div
        className="w-full h-[1px] mt-6 transition-all duration-500"
        style={{
          background: isUtopian
            ? 'linear-gradient(90deg, transparent, rgba(255,215,0,0.6), transparent)'
            : 'linear-gradient(90deg, transparent, rgba(0,255,255,0.6), transparent)',
          boxShadow: isUtopian
            ? '0 0 10px rgba(255,215,0,0.4)'
            : '0 0 10px rgba(0,255,255,0.4)',
        }}
        animate={{
          scaleX: [0, 1, 0],
        }}
        transition={{
          duration: 3,
          repeat: Infinity,
          ease: "easeInOut",
        }}
      />
    </motion.div>
  );
}
