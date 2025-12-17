import { useState, useEffect, useRef } from 'react';
import { motion } from 'motion/react';
import { useTheme } from '../context/ThemeContext';
import { Scan, Hand } from 'lucide-react';

export function HiddenMessage() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const [isHovering, setIsHovering] = useState(false);
  
  // Store references to the actual DOM elements
  const charRefs = useRef<(HTMLSpanElement | null)[]>([]);
  // Store the calculated positions (x, y) of each character
  const [charPositions, setCharPositions] = useState<{ x: number; y: number }[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);

  const text = "2026. Better Systems, Better Habits, Better You.";
  const words = text.split(' ');

  // 1. Measure positions ONCE (on mount or resize)
  useEffect(() => {
    const measurePositions = () => {
      if (!containerRef.current) return;
      const parentRect = containerRef.current.getBoundingClientRect();
      
      const newPositions = charRefs.current.map(span => {
        if (!span) return { x: 0, y: 0 };
        const rect = span.getBoundingClientRect();
        return {
          x: rect.left - parentRect.left + rect.width / 2,
          y: rect.top - parentRect.top + rect.height / 2
        };
      });
      
      setCharPositions(newPositions);
    };

    // Measure initially (slight delay to ensure DOM is ready)
    const timeoutId = setTimeout(measurePositions, 100);

    // Re-measure if window resizes (responsive)
    window.addEventListener('resize', measurePositions);
    return () => {
      clearTimeout(timeoutId);
      window.removeEventListener('resize', measurePositions);
    };
  }, [text]); // Re-run if text changes

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    const rect = e.currentTarget.getBoundingClientRect();
    setMousePosition({
      x: e.clientX - rect.left,
      y: e.clientY - rect.top,
    });
  };

  return (
    <div 
      ref={containerRef}
      className="relative w-full max-w-4xl mx-auto mb-12 px-4"
      onMouseMove={handleMouseMove}
      onMouseEnter={() => setIsHovering(true)}
      onMouseLeave={() => setIsHovering(false)}
    >
      {/* Subtle border hint */}
      <motion.div
        className={`absolute inset-0 rounded-lg border transition-all duration-500 pointer-events-none ${
          isUtopian ? 'border-amber-400/20' : 'border-cyan-400/20'
        }`}
        animate={{
          opacity: isHovering ? 0 : [0.1, 0.3, 0.1],
          scale: isHovering ? 1 : [1, 1.01, 1],
        }}
        transition={{ 
          opacity: { duration: 3, repeat: Infinity },
          scale: { duration: 3, repeat: Infinity }
        }}
      />
      
      {/* Corner indicators */}
      {!isHovering && (
        <>
          <CornerPiece position="-left-1 -top-1" borderClass="border-l-2 border-t-2" isUtopian={isUtopian} delay={0} />
          <CornerPiece position="-right-1 -top-1" borderClass="border-r-2 border-t-2" isUtopian={isUtopian} delay={0.5} />
          <CornerPiece position="-left-1 -bottom-1" borderClass="border-l-2 border-b-2" isUtopian={isUtopian} delay={1} />
          <CornerPiece position="-right-1 -bottom-1" borderClass="border-r-2 border-b-2" isUtopian={isUtopian} delay={1.5} />
        </>
      )}
      
      <div className="relative h-32 flex items-center justify-center px-2">
        {/* Text Layer */}
        <div className="absolute inset-0 flex items-center justify-center px-2">
          <p className="text-sm md:text-base tracking-[0.4em] font-light select-none uppercase transition-colors duration-500 text-center leading-relaxed">
            {words.map((word, wordIndex) => {
              // Calculate starting index for this word to keep global index consistent
              const wordStartIndex = words.slice(0, wordIndex).join(' ').length + (wordIndex > 0 ? wordIndex : 0);
              
              return (
                <span key={wordIndex} className="inline-block whitespace-nowrap mr-[0.4em]">
                  {word.split('').map((char, charIndex) => {
                    const globalIndex = wordStartIndex + charIndex;
                    
                    // 2. Fast Distance Calculation - pure math, no DOM queries!
                    let distance = 1000;
                    if (isHovering && charPositions[globalIndex]) {
                      const pos = charPositions[globalIndex];
                      distance = Math.sqrt(
                        Math.pow(mousePosition.x - pos.x, 2) + 
                        Math.pow(mousePosition.y - pos.y, 2)
                      );
                    }
                    
                    const revealRadius = 80;
                    const opacity = isHovering 
                      ? Math.max(0, Math.min(1, 1 - distance / revealRadius))
                      : isUtopian ? 0.4 : 0.02;
                    
                    const colorIndex = globalIndex % 3;
                    const color = isUtopian
                      ? colorIndex === 0 ? '#D97706' : colorIndex === 1 ? '#0284C7' : '#059669'
                      : colorIndex === 0 ? '#00ffff' : colorIndex === 1 ? '#ff00ff' : '#ff6400';
                    
                    return (
                      <motion.span
                        key={charIndex}
                        // 3. Assign Ref here
                        ref={el => (charRefs.current[globalIndex] = el)}
                        animate={{ opacity }}
                        transition={{ duration: 0.15 }}
                        className="inline-block"
                        style={{ 
                          color: color,
                          textShadow: opacity > 0.5 
                            ? `0 0 10px ${color}, 0 0 20px ${color}, 0 0 30px ${color}`
                            : 'none',
                        }}
                      >
                        {char}
                      </motion.span>
                    );
                  })}
                </span>
              );
            })}
          </p>
        </div>
        
        {/* Cursor Follower - optimized positioning */}
        {isHovering && (
          <motion.div
            className="absolute pointer-events-none"
            animate={{
               x: mousePosition.x,
               y: mousePosition.y
            }}
            transition={{ type: "tween", ease: "linear", duration: 0 }}
            style={{
              left: 0,
              top: 0,
              x: "-50%", 
              y: "-50%" 
            }}
          >
            <div className="w-40 h-40 rounded-full blur-3xl transition-colors duration-500" 
              style={{
                background: isUtopian
                  ? 'radial-gradient(circle, rgba(217,119,6,0.3) 0%, transparent 70%)'
                  : 'radial-gradient(circle, rgba(0,255,255,0.2) 0%, transparent 70%)',
              }}
            />
          </motion.div>
        )}
      </div>
      
      {/* Footer Hints */}
      <FooterHint isHovering={isHovering} isUtopian={isUtopian} />
    </div>
  );
}

// Extracted sub-components for cleaner code
const CornerPiece = ({ position, borderClass, isUtopian, delay }: { 
  position: string; 
  borderClass: string; 
  isUtopian: boolean; 
  delay: number;
}) => (
  <motion.div
    className={`absolute ${position} w-4 h-4 ${borderClass} transition-colors duration-500 ${
      isUtopian ? 'border-amber-400/40' : 'border-cyan-400/40'
    }`}
    animate={{ opacity: [0.3, 0.7, 0.3] }}
    transition={{ duration: 2, repeat: Infinity, delay }}
  />
);

const FooterHint = ({ isHovering, isUtopian }: { isHovering: boolean; isUtopian: boolean }) => (
  <motion.div
    initial={{ opacity: 0 }}
    animate={{ opacity: isHovering ? 0 : 1 }}
    transition={{ duration: 0.5 }}
    className="text-center mt-4"
  >
    <motion.div
      className={`inline-flex items-center gap-2 text-xs tracking-[0.3em] uppercase font-light transition-colors duration-500 ${
        isUtopian ? 'text-amber-700' : 'text-cyan-400'
      }`}
      animate={{ opacity: [0.7, 1, 0.7] }}
      transition={{ duration: 2, repeat: Infinity }}
      style={{
        textShadow: isUtopian 
          ? '0 0 8px rgba(217,119,6,0.5)'
          : '0 0 8px rgba(0,255,255,0.4)',
      }}
    >
      <RotatingIcon isUtopian={isUtopian} delay={0} />
      <span className="whitespace-nowrap">{isUtopian ? '[REVEAL THE VISION]' : '[SCAN TO DECRYPT]'}</span>
      <RotatingIcon isUtopian={isUtopian} delay={0.1} />
    </motion.div>
    
    {/* Additional subtle hint */}
    <motion.div
      className={`text-[10px] tracking-widest mt-2 uppercase transition-colors duration-500 ${
        isUtopian ? 'text-amber-800' : 'text-cyan-500/50'
      }`}
      animate={{ opacity: [0.7, 1, 0.7] }}
      transition={{ duration: 3, repeat: Infinity, delay: 0.5 }}
    >
      <span className="whitespace-nowrap">Hover to unlock message</span>
    </motion.div>
  </motion.div>
);

const RotatingIcon = ({ isUtopian, delay }: { isUtopian: boolean; delay: number }) => (
  <motion.div
    animate={{ scale: [1, 1.2, 1], rotate: [0, 5, -5, 0] }}
    transition={{ duration: 2, repeat: Infinity, delay }}
  >
    {isUtopian ? <Hand className="w-3 h-3" /> : <Scan className="w-3 h-3" />}
  </motion.div>
);
