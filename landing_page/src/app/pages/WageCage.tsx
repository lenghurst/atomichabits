import { motion } from 'motion/react';
import { useTheme } from '../context/ThemeContext';
import { useEffect } from 'react';
import { ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

export function WageCage() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  const navigate = useNavigate();

  // Auto-redirect after 5 seconds
  useEffect(() => {
    const timer = setTimeout(() => {
      navigate('/');
    }, 5000);
    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className={`min-h-screen flex items-center justify-center p-4 transition-all duration-500 ${
      isUtopian 
        ? 'bg-gradient-to-br from-amber-50 via-white to-yellow-50' 
        : 'bg-gradient-to-br from-black via-gray-900 to-black'
    }`}>
      {/* Background effects */}
      {!isUtopian && (
        <>
          {/* Scanlines */}
          <div className="fixed inset-0 pointer-events-none opacity-10"
            style={{
              backgroundImage: 'repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 255, 255, 0.03) 2px, rgba(0, 255, 255, 0.03) 4px)',
            }}
          />
          
          {/* Glitch effect */}
          <motion.div
            className="fixed inset-0 pointer-events-none"
            animate={{
              opacity: [0, 0.1, 0, 0.05, 0],
            }}
            transition={{
              duration: 5,
              repeat: Infinity,
              repeatDelay: 2,
            }}
            style={{
              background: 'linear-gradient(90deg, transparent 0%, rgba(255,0,255,0.1) 50%, transparent 100%)',
            }}
          />
        </>
      )}

      {/* Content */}
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        transition={{ duration: 0.6, ease: [0.22, 1, 0.36, 1] }}
        className="max-w-2xl w-full relative"
      >
        {/* Corner brackets */}
        <div className={`absolute -left-4 -top-4 w-8 h-8 border-l-2 border-t-2 transition-colors duration-500 ${
          isUtopian ? 'border-amber-400' : 'border-cyan-400'
        }`} />
        <div className={`absolute -right-4 -top-4 w-8 h-8 border-r-2 border-t-2 transition-colors duration-500 ${
          isUtopian ? 'border-amber-400' : 'border-cyan-400'
        }`} />
        <div className={`absolute -left-4 -bottom-4 w-8 h-8 border-l-2 border-b-2 transition-colors duration-500 ${
          isUtopian ? 'border-amber-400' : 'border-cyan-400'
        }`} />
        <div className={`absolute -right-4 -bottom-4 w-8 h-8 border-r-2 border-b-2 transition-colors duration-500 ${
          isUtopian ? 'border-amber-400' : 'border-cyan-400'
        }`} />

        {/* Main content box */}
        <div className={`backdrop-blur-md border-2 p-12 text-center transition-all duration-500 ${
          isUtopian 
            ? 'bg-white/60 border-amber-400/40' 
            : 'bg-black/50 border-cyan-400/30'
        }`}>
          {/* Title */}
          <motion.h1
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            className={`tracking-[0.3em] uppercase mb-8 transition-colors duration-500 ${
              isUtopian ? 'text-amber-600' : 'text-cyan-400'
            }`}
            style={{
              textShadow: isUtopian
                ? '0 0 20px rgba(255,215,0,0.6)'
                : '0 0 20px rgba(0,255,255,0.8)',
            }}
          >
            {isUtopian ? 'Commitment Registered' : 'Validation Complete'}
          </motion.h1>

          {/* Divider */}
          <motion.div
            initial={{ scaleX: 0 }}
            animate={{ scaleX: 1 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            className={`h-[2px] w-full mb-8 ${
              isUtopian 
                ? 'bg-gradient-to-r from-transparent via-amber-400 to-transparent' 
                : 'bg-gradient-to-r from-transparent via-cyan-400 to-transparent'
            }`}
            style={{
              boxShadow: isUtopian
                ? '0 0 10px rgba(255,215,0,0.6)'
                : '0 0 10px rgba(0,255,255,0.8)',
            }}
          />

          {/* Main message */}
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.6 }}
            className={`text-xl mb-2 transition-colors duration-500 ${
              isUtopian ? 'text-amber-900' : 'text-white'
            }`}
          >
            {isUtopian 
              ? 'Thank you for joining our mission.'
              : 'Get back to work.'}
          </motion.p>

          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 0.8 }}
            className={`text-xl mb-8 transition-colors duration-500 ${
              isUtopian ? 'text-amber-900' : 'text-white'
            }`}
          >
            {isUtopian 
              ? 'We will contact you soon.'
              : 'We will contact you.'}
          </motion.p>

          {/* Pulsing status indicator */}
          <motion.div
            initial={{ opacity: 0, scale: 0 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.6, delay: 1 }}
            className="flex items-center justify-center gap-3 mb-8"
          >
            <motion.div
              animate={{
                scale: [1, 1.2, 1],
                opacity: [0.5, 1, 0.5],
              }}
              transition={{
                duration: 2,
                repeat: Infinity,
                ease: "easeInOut",
              }}
              className={`w-3 h-3 rounded-full transition-all duration-500 ${
                isUtopian ? 'bg-amber-500' : 'bg-cyan-400'
              }`}
              style={{
                boxShadow: isUtopian
                  ? '0 0 20px rgba(255,215,0,0.8)'
                  : '0 0 20px rgba(0,255,255,1)',
              }}
            />
            <span className={`text-sm tracking-[0.3em] uppercase transition-colors duration-500 ${
              isUtopian ? 'text-amber-600' : 'text-cyan-500'
            }`}>
              {isUtopian ? 'Processing' : 'Status: Active'}
            </span>
          </motion.div>

          {/* Back button */}
          <motion.button
            aria-label="Return to home page"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ duration: 0.6, delay: 1.2 }}
            onClick={() => navigate('/')}
            className={`inline-flex items-center gap-2 px-6 py-3 border-2 backdrop-blur-sm transition-all duration-300 tracking-wider uppercase text-sm ${
              isUtopian
                ? 'border-amber-400/50 text-amber-600 hover:bg-amber-400/20 hover:border-amber-500'
                : 'border-cyan-400/50 text-cyan-400 hover:bg-cyan-400/20 hover:border-cyan-400'
            }`}
            style={{
              boxShadow: isUtopian
                ? '0 0 10px rgba(255,215,0,0.3)'
                : '0 0 10px rgba(0,255,255,0.3)',
            }}
          >
            <ArrowLeft className="w-4 h-4" />
            Return
          </motion.button>

          {/* Auto-redirect notice */}
          <motion.p
            initial={{ opacity: 0 }}
            animate={{ opacity: 0.5 }}
            transition={{ duration: 0.6, delay: 1.4 }}
            className={`mt-6 text-xs tracking-[0.2em] uppercase transition-colors duration-500 ${
              isUtopian ? 'text-amber-600' : 'text-cyan-600'
            }`}
          >
            Auto-redirect in 5 seconds
          </motion.p>
        </div>
      </motion.div>
    </div>
  );
}
