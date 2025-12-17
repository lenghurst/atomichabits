import { motion } from 'motion/react';
import { HiddenMessage } from './components/HiddenMessage';
import { EmailCapture } from './components/EmailCapture';
import { FloatingOrbs } from './components/FloatingOrbs';
import { Countdown } from './components/Countdown';
import { LiveViewers } from './components/LiveViewers';
import { ThemeToggle } from './components/ThemeToggle';
import { useTheme } from './context/ThemeContext';

export function AppContent() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';

  return (
    <div
      className={`relative min-h-screen overflow-hidden transition-colors duration-1000 ${
        isUtopian ? 'bg-gradient-to-br from-white via-sky-50 to-amber-50 text-amber-900' : 'bg-black text-white'
      }`}
    >
      {/* Background gradient */}
      <div
        className={`fixed inset-0 transition-all duration-1000 ${
          isUtopian
            ? 'bg-gradient-to-br from-white via-blue-50/30 to-amber-50/50'
            : 'bg-gradient-to-br from-black via-purple-950/20 to-black'
        }`}
      />

      {/* Animated grid pattern */}
      <div className="fixed inset-0 opacity-20 transition-opacity duration-1000">
        <div
          className="absolute inset-0 transition-all duration-1000"
          style={{
            backgroundImage: isUtopian
              ? `
                linear-gradient(rgba(255, 215, 0, 0.08) 1px, transparent 1px),
                linear-gradient(90deg, rgba(135, 206, 235, 0.08) 1px, transparent 1px)
              `
              : `
                linear-gradient(rgba(0, 255, 255, 0.1) 1px, transparent 1px),
                linear-gradient(90deg, rgba(255, 0, 255, 0.1) 1px, transparent 1px)
              `,
            backgroundSize: '50px 50px',
          }}
        />
      </div>

      {/* Scanlines effect */}
      <motion.div
        className="fixed inset-0 pointer-events-none opacity-10"
        animate={{
          backgroundPosition: ['0px 0px', '0px 100px'],
        }}
        transition={{ duration: 2, repeat: Infinity, ease: 'linear' }}
        style={{
          backgroundImage: isUtopian
            ? 'repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(255, 215, 0, 0.2) 2px, rgba(255, 215, 0, 0.2) 4px)'
            : 'repeating-linear-gradient(0deg, transparent, transparent 2px, rgba(0, 255, 255, 0.3) 2px, rgba(0, 255, 255, 0.3) 4px)',
          backgroundSize: '100% 100px',
        }}
      />

      {/* Animated floating orbs for 3D effect */}
      <FloatingOrbs />

      {/* Live viewers counter */}
      <LiveViewers />

      {/* Theme toggle */}
      <ThemeToggle />

      {/* Main content */}
      <div className="relative z-10 flex flex-col items-center justify-center min-h-screen px-4 py-12 md:py-16">
        {/* Add top padding on mobile to prevent overlap with widgets */}
        <div className="h-20 md:h-0" /> {/* Spacer for mobile */}
        
        {/* Hidden message that reveals on hover */}
        <HiddenMessage />

        {/* Main heading with atomic symbol */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 1.2, delay: 0.5, ease: [0.22, 1, 0.36, 1] }}
          className="text-center mb-12 mt-8"
        >
          <div className="relative w-64 h-64 mx-auto">
            {/* Animated glow layers */}
            <motion.div
              className="absolute -inset-32 blur-[120px] transition-all duration-1000"
              style={{
                background: isUtopian
                  ? 'radial-gradient(circle, rgba(255,215,0,0.3) 0%, transparent 70%)'
                  : 'radial-gradient(circle, rgba(0,255,255,0.4) 0%, transparent 70%)',
              }}
              animate={{
                opacity: [0.4, 0, 0, 0.4],
              }}
              transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
            />
            <motion.div
              className="absolute -inset-32 blur-[120px] transition-all duration-1000"
              style={{
                background: isUtopian
                  ? 'radial-gradient(circle, rgba(135,206,235,0.3) 0%, transparent 70%)'
                  : 'radial-gradient(circle, rgba(255,0,255,0.4) 0%, transparent 70%)',
              }}
              animate={{
                opacity: [0, 0.4, 0, 0],
              }}
              transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
            />
            <motion.div
              className="absolute -inset-32 blur-[120px] transition-all duration-1000"
              style={{
                background: isUtopian
                  ? 'radial-gradient(circle, rgba(152,255,152,0.3) 0%, transparent 70%)'
                  : 'radial-gradient(circle, rgba(255,100,0,0.4) 0%, transparent 70%)',
              }}
              animate={{
                opacity: [0, 0, 0.4, 0],
              }}
              transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
            />

            {/* Central atomic symbol/triangle */}
            <div className="absolute inset-0 flex items-center justify-center">
              {isUtopian ? (
                // Utopian: Triangle
                <motion.div
                  key="triangle"
                  className="relative flex items-center justify-center"
                  initial={{ opacity: 0, scale: 0.8, x: -20 }}
                  animate={{ opacity: 1, scale: 1, x: 0 }}
                  exit={{ opacity: 0, scale: 0.8, x: -20 }}
                  transition={{ 
                    opacity: { duration: 0.3, ease: 'easeOut' },
                    scale: { duration: 0.3, ease: 'easeOut' },
                    x: { duration: 0.3, ease: 'easeOut' }
                  }}
                >
                  <motion.div
                    className="text-8xl md:text-9xl font-light relative z-10 text-amber-500 leading-none"
                    animate={{
                      textShadow: [
                        '0 0 10px rgba(255,215,0,0.6), 0 0 20px rgba(255,215,0,0.4), 0 0 30px rgba(255,215,0,0.2)',
                        '0 0 10px rgba(135,206,235,0.6), 0 0 20px rgba(135,206,235,0.4), 0 0 30px rgba(135,206,235,0.2)',
                        '0 0 10px rgba(152,255,152,0.6), 0 0 20px rgba(152,255,152,0.4), 0 0 30px rgba(152,255,152,0.2)',
                        '0 0 10px rgba(255,215,0,0.6), 0 0 20px rgba(255,215,0,0.4), 0 0 30px rgba(255,215,0,0.2)',
                      ],
                    }}
                    transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
                    style={{ lineHeight: 1 }}
                  >
                    ▲
                  </motion.div>
                </motion.div>
              ) : (
                // Dystopian: Glowing Atomic Symbol ⚛
                <motion.div
                  key="atomic"
                  className="relative flex items-center justify-center"
                  initial={{ opacity: 0, scale: 0.8, x: -20 }}
                  animate={{ opacity: 1, scale: 1, x: 0 }}
                  exit={{ opacity: 0, scale: 0.8, x: -20 }}
                  transition={{ duration: 0.3, ease: 'easeOut' }}
                >
                  <motion.div
                    className="text-8xl md:text-9xl font-light relative z-10 text-cyan-400 leading-none"
                    animate={{
                      textShadow: [
                        '0 0 20px rgba(0,255,255,1), 0 0 40px rgba(0,255,255,0.8), 0 0 60px rgba(0,255,255,0.6)',
                        '0 0 20px rgba(255,0,255,1), 0 0 40px rgba(255,0,255,0.8), 0 0 60px rgba(255,0,255,0.6)',
                        '0 0 20px rgba(255,100,0,1), 0 0 40px rgba(255,100,0,0.8), 0 0 60px rgba(255,100,0,0.6)',
                        '0 0 20px rgba(0,255,255,1), 0 0 40px rgba(0,255,255,0.8), 0 0 60px rgba(0,255,255,0.6)',
                      ],
                    }}
                    transition={{ duration: 6, repeat: Infinity, ease: 'linear' }}
                    style={{ lineHeight: 1 }}
                  >
                    ⚛
                  </motion.div>
                  
                  {/* Additional glow layer for atomic symbol */}
                  <motion.div
                    className="absolute inset-0 flex items-center justify-center text-8xl md:text-9xl font-light text-cyan-400 opacity-30 leading-none"
                    animate={{
                      scale: [1, 1.1, 1],
                      opacity: [0.3, 0.6, 0.3],
                    }}
                    transition={{ duration: 2, repeat: Infinity }}
                    style={{ lineHeight: 1 }}
                  >
                    ⚛
                  </motion.div>
                </motion.div>
              )}
            </div>

            {/* Orbiting electrons/particles - outer orbit */}
            {[...Array(3)].map((_, i) => (
              <motion.div
                key={`outer-${i}`}
                className={`absolute w-2 h-2 rounded-full transition-all duration-1000 ${
                  isUtopian ? 'bg-amber-400' : 'bg-cyan-400'
                }`}
                style={{
                  left: '50%',
                  top: '50%',
                  marginLeft: -4,
                  marginTop: -4,
                  boxShadow: isUtopian
                    ? '0 0 10px rgba(255,215,0,0.8), 0 0 20px rgba(255,215,0,0.5)'
                    : '0 0 10px rgba(0,255,255,0.8), 0 0 20px rgba(0,255,255,0.5)',
                }}
                animate={{
                  x: [
                    Math.cos((i * 120 * Math.PI) / 180) * 80,
                    Math.cos(((i * 120 + 360) * Math.PI) / 180) * 80,
                  ],
                  y: [
                    Math.sin((i * 120 * Math.PI) / 180) * 80,
                    Math.sin(((i * 120 + 360) * Math.PI) / 180) * 80,
                  ],
                }}
                transition={{
                  duration: 4,
                  repeat: Infinity,
                  ease: 'linear',
                  delay: i * 0.3,
                }}
              />
            ))}

            {/* Orbiting electrons/particles - middle orbit */}
            {[...Array(2)].map((_, i) => (
              <motion.div
                key={`middle-${i}`}
                className={`absolute w-1.5 h-1.5 rounded-full transition-all duration-1000 ${
                  isUtopian ? 'bg-sky-400' : 'bg-magenta-400'
                }`}
                style={{
                  left: '50%',
                  top: '50%',
                  marginLeft: -3,
                  marginTop: -3,
                  boxShadow: isUtopian
                    ? '0 0 8px rgba(135,206,235,0.8), 0 0 16px rgba(135,206,235,0.5)'
                    : '0 0 8px rgba(255,0,255,0.8), 0 0 16px rgba(255,0,255,0.5)',
                }}
                animate={{
                  x: [
                    Math.cos((i * 180 * Math.PI) / 180) * 50,
                    Math.cos(((i * 180 + 360) * Math.PI) / 180) * 50,
                  ],
                  y: [
                    Math.sin((i * 180 * Math.PI) / 180) * 50,
                    Math.sin(((i * 180 + 360) * Math.PI) / 180) * 50,
                  ],
                }}
                transition={{
                  duration: 3,
                  repeat: Infinity,
                  ease: 'linear',
                  delay: i * 0.5,
                }}
              />
            ))}

            {/* Orbital rings */}
            <motion.div
              className={`absolute left-1/2 top-1/2 w-40 h-40 rounded-full border transition-colors duration-1000 ${
                isUtopian ? 'border-amber-400/20' : 'border-cyan-400/20'
              }`}
              style={{
                marginLeft: -80,
                marginTop: -80,
              }}
              animate={{
                rotate: 360,
                opacity: [0.2, 0.4, 0.2],
              }}
              transition={{
                rotate: { duration: 20, repeat: Infinity, ease: 'linear' },
                opacity: { duration: 3, repeat: Infinity },
              }}
            />

            <motion.div
              className={`absolute left-1/2 top-1/2 w-24 h-24 rounded-full border transition-colors duration-1000 ${
                isUtopian ? 'border-sky-400/20' : 'border-magenta-400/20'
              }`}
              style={{
                marginLeft: -48,
                marginTop: -48,
              }}
              animate={{
                rotate: -360,
                opacity: [0.2, 0.4, 0.2],
              }}
              transition={{
                rotate: { duration: 15, repeat: Infinity, ease: 'linear' },
                opacity: { duration: 2.5, repeat: Infinity },
              }}
            />
          </div>
        </motion.div>

        {/* Countdown */}
        <Countdown />

        {/* Email capture form */}
        <EmailCapture />

        {/* Footer */}
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 0.6 }}
          transition={{ duration: 2, delay: 1.5 }}
          className={`absolute bottom-8 text-xs tracking-[0.5em] font-light transition-colors duration-1000 ${
            isUtopian ? 'text-amber-600' : 'text-cyan-400'
          }`}
        >
          <motion.span
            animate={{
              opacity: [0.6, 1, 0.6],
            }}
            transition={{ duration: 3, repeat: Infinity }}
            style={{
              textShadow: isUtopian
                ? '0 0 10px rgba(255,215,0,0.3)'
                : '0 0 10px rgba(0,255,255,0.3)',
            }}
          >
            ◇ CREATED BY CRONY ◇
          </motion.span>
        </motion.div>
      </div>
    </div>
  );
}