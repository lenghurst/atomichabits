import { motion } from 'motion/react';
import { useTheme } from '../context/ThemeContext';

export function FloatingOrbs() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  
  const orbs = isUtopian
    ? [
        { size: 400, duration: 25, delay: 0, x: [-20, 20, -20], y: [-30, 30, -30], color: 'rgba(255,215,0,0.3)' },
        { size: 350, duration: 20, delay: 2, x: [20, -20, 20], y: [20, -20, 20], color: 'rgba(135,206,235,0.3)' },
        { size: 300, duration: 30, delay: 4, x: [-15, 15, -15], y: [-25, 25, -25], color: 'rgba(152,255,152,0.3)' },
      ]
    : [
        { size: 400, duration: 25, delay: 0, x: [-20, 20, -20], y: [-30, 30, -30], color: 'rgba(0,255,255,0.4)' },
        { size: 350, duration: 20, delay: 2, x: [20, -20, 20], y: [20, -20, 20], color: 'rgba(255,0,255,0.4)' },
        { size: 300, duration: 30, delay: 4, x: [-15, 15, -15], y: [-25, 25, -25], color: 'rgba(255,100,0,0.4)' },
      ];

  return (
    <div className="fixed inset-0 overflow-hidden pointer-events-none">
      {orbs.map((orb, index) => (
        <motion.div
          key={index}
          className="absolute rounded-full blur-[150px] opacity-30 transition-all duration-1000"
          style={{
            width: orb.size,
            height: orb.size,
            left: '50%',
            top: '50%',
            marginLeft: -orb.size / 2,
            marginTop: -orb.size / 2,
            background: `radial-gradient(circle, ${orb.color} 0%, transparent 70%)`,
          }}
          animate={{
            x: orb.x,
            y: orb.y,
            scale: [1, 1.1, 0.9, 1],
          }}
          transition={{
            duration: orb.duration,
            delay: orb.delay,
            repeat: Infinity,
            ease: "easeInOut",
          }}
        />
      ))}
      
      {/* Neon particles */}
      {[...Array(12)].map((_, i) => {
        const colors = isUtopian
          ? { 0: '#FFD700', 1: '#87CEEB', 2: '#98FF98' }
          : { 0: '#00ffff', 1: '#ff00ff', 2: '#ff6400' };
        const color = colors[i % 3 as 0 | 1 | 2];
        
        return (
          <motion.div
            key={`particle-${i}`}
            className="absolute w-1 h-1 rounded-full transition-all duration-500"
            style={{
              left: `${20 + (i * 6)}%`,
              top: `${30 + (i * 5)}%`,
              background: color,
              boxShadow: `0 0 10px ${color}, 0 0 20px ${color}`,
            }}
            animate={{
              opacity: [0.2, 0.8, 0.2],
              scale: [0.5, 2, 0.5],
              y: [-30, 30, -30],
            }}
            transition={{
              duration: 4 + i * 0.5,
              repeat: Infinity,
              delay: i * 0.3,
              ease: "easeInOut",
            }}
          />
        );
      })}
      
      {/* Glitch/Energy bars */}
      {[...Array(3)].map((_, i) => (
        <motion.div
          key={`glitch-${i}`}
          className="absolute left-0 right-0 h-[2px] transition-all duration-500"
          style={{
            top: `${25 + i * 25}%`,
            background: isUtopian
              ? 'linear-gradient(90deg, transparent, rgba(255,215,0,0.5), transparent)'
              : 'linear-gradient(90deg, transparent, rgba(0,255,255,0.5), transparent)',
          }}
          animate={{
            opacity: [0, 0.8, 0],
            scaleX: [0, 1, 0],
          }}
          transition={{
            duration: 2,
            repeat: Infinity,
            delay: i * 2,
            ease: "easeInOut",
          }}
        />
      ))}
    </div>
  );
}