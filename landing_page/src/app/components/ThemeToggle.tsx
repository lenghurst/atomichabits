import { motion } from 'motion/react';
import { useTheme } from '../context/ThemeContext';

export function ThemeToggle() {
  const { theme, toggleTheme } = useTheme();
  const isUtopian = theme === 'utopian';

  return (
    <motion.button
      type="button"
      aria-label={isUtopian ? "Switch to Dystopian mode" : "Switch to Utopian mode"}
      initial={{ opacity: 0, x: 20 }}
      animate={{ opacity: 1, x: 0 }}
      transition={{ duration: 1, delay: 2 }}
      onClick={toggleTheme}
      className="fixed top-4 right-4 md:top-8 md:right-8 z-20 group max-w-[calc(50vw-2rem)] sm:max-w-none"
    >
      <div className="relative">
        {/* Background glow */}
        <motion.div
          className="absolute -inset-4 blur-xl opacity-30"
          style={{
            background: isUtopian
              ? 'radial-gradient(circle, rgba(255,215,0,0.4) 0%, transparent 70%)'
              : 'radial-gradient(circle, rgba(255,0,255,0.4) 0%, transparent 70%)',
          }}
          animate={{
            opacity: [0.2, 0.4, 0.2],
          }}
          transition={{ duration: 2, repeat: Infinity }}
        />

        {/* Main container */}
        <div
          className={`relative backdrop-blur-sm border px-4 py-2 md:px-6 md:py-3 transition-all duration-500 ${
            isUtopian
              ? 'bg-white/80 border-amber-400/50'
              : 'bg-black/50 border-magenta-400/30'
          }`}
        >
          {/* Corner brackets */}
          <div
            className={`absolute -left-1 -top-1 w-3 h-3 border-l-2 border-t-2 transition-colors duration-500 ${
              isUtopian ? 'border-amber-400' : 'border-magenta-400'
            }`}
          />
          <div
            className={`absolute -right-1 -top-1 w-3 h-3 border-r-2 border-t-2 transition-colors duration-500 ${
              isUtopian ? 'border-amber-400' : 'border-magenta-400'
            }`}
          />
          <div
            className={`absolute -left-1 -bottom-1 w-3 h-3 border-l-2 border-b-2 transition-colors duration-500 ${
              isUtopian ? 'border-amber-400' : 'border-magenta-400'
            }`}
          />
          <div
            className={`absolute -right-1 -bottom-1 w-3 h-3 border-r-2 border-b-2 transition-colors duration-500 ${
              isUtopian ? 'border-amber-400' : 'border-magenta-400'
            }`}
          />

          <div className="flex items-center gap-3">
            {/* Toggle switch */}
            <div
              className={`relative w-14 h-7 rounded-full transition-colors duration-500 ${
                isUtopian ? 'bg-amber-200' : 'bg-magenta-900/50'
              }`}
            >
              <motion.div
                className={`absolute top-1 w-5 h-5 rounded-full transition-colors duration-500 ${
                  isUtopian ? 'bg-amber-500' : 'bg-magenta-400'
                }`}
                style={{
                  boxShadow: isUtopian
                    ? '0 0 10px rgba(255,215,0,0.8)'
                    : '0 0 10px rgba(255,0,255,0.8)',
                }}
                animate={{
                  x: isUtopian ? 30 : 4,
                }}
                transition={{ type: 'spring', stiffness: 500, damping: 30 }}
              />
            </div>

            {/* Label */}
            <div className="flex flex-col items-start">
              <span
                className={`text-xs uppercase tracking-wider font-light transition-colors duration-500 ${
                  isUtopian ? 'text-amber-700' : 'text-magenta-400'
                }`}
                style={{
                  textShadow: isUtopian
                    ? '0 0 10px rgba(255,215,0,0.3)'
                    : '0 0 10px rgba(255,0,255,0.3)',
                }}
              >
                {isUtopian ? 'Utopian' : 'Dystopian'}
              </span>
              <span
                className={`text-[9px] uppercase tracking-widest transition-colors duration-500 ${
                  isUtopian ? 'text-amber-600/60' : 'text-magenta-600/60'
                }`}
              >
                Reality
              </span>
            </div>
          </div>

          {/* Scanning line */}
          <motion.div
            className={`absolute bottom-0 left-0 right-0 h-[1px] transition-colors duration-500`}
            style={{
              background: isUtopian
                ? 'linear-gradient(90deg, transparent, rgba(255,215,0,0.8), transparent)'
                : 'linear-gradient(90deg, transparent, rgba(255,0,255,0.8), transparent)',
              boxShadow: isUtopian
                ? '0 0 5px rgba(255,215,0,0.5)'
                : '0 0 5px rgba(255,0,255,0.5)',
            }}
            animate={{
              scaleX: [0, 1, 0],
            }}
            transition={{
              duration: 2,
              repeat: Infinity,
              ease: 'easeInOut',
            }}
          />
        </div>
      </div>
    </motion.button>
  );
}
