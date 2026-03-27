import { useState, useEffect } from 'react';
import { motion } from 'motion/react';
import { ArrowRight, Loader2 } from 'lucide-react';
import { useTheme } from '../context/ThemeContext';
import { supabase } from '../../lib/supabaseClient';
import { useNavigate } from 'react-router-dom';

// Disposable/Temp email domains to block
const DISPOSABLE_DOMAINS = [
  "10minutemail.com", "guerrillamail.com", "mailinator.com", "yopmail.com",
  "sharklasers.com", "temp-mail.org", "throwawaymail.com", "getairmail.com",
  "dispostable.com", "mailvn.com", "tempmail.com", "fakeinbox.com",
  "trashmail.com", "getnada.com", "emailondeck.com", "mintemail.com",
  "mohmal.com", "mytemp.email", "guerrillamail.org", "maildrop.cc"
];

// Public email domains (consumer/personal)
const PUBLIC_DOMAINS = [
  "gmail.com", "yahoo.com", "hotmail.com", "outlook.com", "aol.com",
  "icloud.com", "protonmail.com", "zoho.com", "yandex.com", "gmx.com",
  "live.com", "me.com", "msn.com", "mail.com", "pm.me", "tutanota.com"
];

function validateEmailType(email: string) {
  if (!email || !email.includes('@')) return { status: "invalid" };

  const domain = email.split('@')[1].toLowerCase();

  // 1. Check for Blocked Temp Domains
  if (DISPOSABLE_DOMAINS.includes(domain)) {
    return {
      status: "blocked",
      message: "TEMP EMAIL DETECTED. USE A REAL ADDRESS."
    };
  }

  // 2. Check for Public "Human" Domains
  if (PUBLIC_DOMAINS.includes(domain)) {
    return {
      status: "allowed",
      type: "human",
      message: "HUMAN VERIFIED"
    };
  }

  // 3. Fallback to Corporate
  return {
    status: "allowed",
    type: "corporate",
    message: "CORPORATE SLAVE VERIFIED"
  };
}

export function EmailCapture() {
  const { theme } = useTheme();
  const isUtopian = theme === 'utopian';
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [isSubmitted, setIsSubmitted] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [isFocused, setIsFocused] = useState(false);
  const [placeholderIndex, setPlaceholderIndex] = useState(0);
  
  const placeholders = isUtopian
    ? ['SHARE YOUR VISION', 'ENTER EMAIL ADDRESS']
    : ['ENTER NEURAL ID', 'ENTER EMAIL ADDRESS'];
  
  // Flicker between placeholders
  useEffect(() => {
    const interval = setInterval(() => {
      setPlaceholderIndex((prev) => (prev + 1) % placeholders.length);
    }, 2000);
    return () => clearInterval(interval);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (email && !isSubmitting) {
      setIsSubmitting(true);
      setError('');
      
      try {
        // Validate email type
        const validation = validateEmailType(email);
        if (validation.status === "blocked") {
          setError(validation.message);
          setIsSubmitting(false);
          return;
        }

        // Try to insert email into Supabase waitlist table
        const { error: supabaseError } = await supabase
          .from('waitlist')
          .insert([{ email }]);

        if (supabaseError) {
          // If table doesn't exist, fallback to localStorage (silently)
          if (supabaseError.code === 'PGRST205') {
            const waitlist = JSON.parse(localStorage.getItem('waitlist') || '[]');
            waitlist.push({ email, timestamp: new Date().toISOString() });
            localStorage.setItem('waitlist', JSON.stringify(waitlist));
          } else {
            console.error('Error inserting email:', supabaseError);
            setError('DATABASE ERROR: ' + supabaseError.message);
            setIsSubmitting(false);
            return;
          }
        }

        console.log('Email captured:', email);
        
        // If corporate email, redirect to wage-cage page
        if (validation.type === 'corporate') {
          // Brief success message before redirect
          setIsSubmitted(true);
          setSuccessMessage(validation.message);
          
          setTimeout(() => {
            navigate('/wage-cage');
          }, 1500);
        } else {
          // Human verified - show success and reset
          setIsSubmitted(true);
          setSuccessMessage(validation.message);
          
          setTimeout(() => {
            setEmail('');
            setIsSubmitted(false);
            setIsSubmitting(false);
            setSuccessMessage('');
          }, 3000);
        }
      } catch (err) {
        console.error('Unexpected error:', err);
        setError('SYSTEM ERROR. TRY AGAIN.');
        setIsSubmitting(false);
      }
    }
  };

  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 1, delay: 0.8, ease: [0.22, 1, 0.36, 1] }}
      className="w-full max-w-md"
    >
      {!isSubmitted ? (
        <form onSubmit={handleSubmit} className="relative">
          {/* Neon glow effect on focus */}
          <motion.div
            className="absolute -inset-4 rounded-full blur-2xl transition-all duration-500"
            style={{ 
              background: isUtopian
                ? 'radial-gradient(circle, rgba(255,215,0,0.3) 0%, transparent 70%)'
                : 'radial-gradient(circle, rgba(0,255,255,0.4) 0%, transparent 70%)'
            }}
            animate={{
              opacity: isFocused ? 0.3 : 0,
            }}
            transition={{ duration: 0.5 }}
          />
          
          {/* Corner brackets - cyberpunk UI element */}
          <div className={`absolute -left-2 -top-2 w-4 h-4 border-l-2 border-t-2 opacity-60 transition-colors duration-500 ${
            isUtopian ? 'border-amber-400' : 'border-cyan-400'
          }`} />
          <div className={`absolute -right-2 -top-2 w-4 h-4 border-r-2 border-t-2 opacity-60 transition-colors duration-500 ${
            isUtopian ? 'border-amber-400' : 'border-cyan-400'
          }`} />
          <div className={`absolute -left-2 -bottom-2 w-4 h-4 border-l-2 border-b-2 opacity-60 transition-colors duration-500 ${
            isUtopian ? 'border-amber-400' : 'border-cyan-400'
          }`} />
          <div className={`absolute -right-2 -bottom-2 w-4 h-4 border-r-2 border-b-2 opacity-60 transition-colors duration-500 ${
            isUtopian ? 'border-amber-400' : 'border-cyan-400'
          }`} />
          
          <div className="relative flex items-center">
            <input
              type="email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              onFocus={() => setIsFocused(true)}
              onBlur={() => setIsFocused(false)}
              placeholder={placeholders[placeholderIndex]}
              required
              disabled={isSubmitting}
              aria-label="Email address"
              className={`w-full backdrop-blur-sm border-2 rounded-none px-6 py-4 pr-14 transition-all duration-500 tracking-wider uppercase text-sm font-light focus:outline-none disabled:opacity-70 disabled:cursor-not-allowed ${
                isUtopian
                  ? 'bg-white/60 border-amber-400/40 text-amber-900 placeholder:text-amber-600/50 focus:border-amber-500'
                  : 'bg-black/50 border-cyan-400/30 text-white placeholder:text-cyan-600/50 focus:border-cyan-400'
              }`}
              style={{
                textShadow: isFocused 
                  ? isUtopian ? '0 0 8px rgba(255,215,0,0.3)' : '0 0 8px rgba(0,255,255,0.5)'
                  : 'none',
              }}
            />
            
            <motion.button
              type="submit"
              disabled={isSubmitting}
              aria-label={isSubmitting ? "Submitting..." : "Submit email"}
              whileHover={{ scale: isSubmitting ? 1 : 1.05 }}
              whileTap={{ scale: isSubmitting ? 1 : 0.95 }}
              className={`absolute right-2 w-10 h-10 backdrop-blur-sm border flex items-center justify-center transition-all duration-500 group disabled:opacity-70 disabled:cursor-not-allowed ${
                isUtopian
                  ? 'bg-amber-400/10 border-amber-400/50 hover:bg-amber-400/20 hover:border-amber-500'
                  : 'bg-cyan-400/10 border-cyan-400/50 hover:bg-cyan-400/20 hover:border-cyan-400'
              }`}
              style={{
                boxShadow: isUtopian
                  ? '0 0 10px rgba(255,215,0,0.3)'
                  : '0 0 10px rgba(0,255,255,0.3)',
              }}
            >
              {isSubmitting ? (
                <Loader2 className={`w-4 h-4 animate-spin ${
                  isUtopian ? 'text-amber-500' : 'text-cyan-400'
                }`} />
              ) : (
                <ArrowRight className={`w-4 h-4 transition-colors ${
                  isUtopian ? 'text-amber-500 group-hover:text-amber-400' : 'text-cyan-400 group-hover:text-cyan-300'
                }`} />
              )}
            </motion.button>
          </div>
          
          {/* Scanning line effect */}
          {isFocused && (
            <motion.div
              className={`absolute left-0 right-0 h-[2px] transition-all duration-500 ${
                isUtopian
                  ? 'bg-gradient-to-r from-transparent via-amber-400 to-transparent'
                  : 'bg-gradient-to-r from-transparent via-cyan-400 to-transparent'
              }`}
              animate={{
                top: [0, '100%'],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: "linear",
              }}
              style={{
                boxShadow: isUtopian
                  ? '0 0 10px rgba(255,215,0,0.8)'
                  : '0 0 10px rgba(0,255,255,0.8)',
              }}
            />
          )}
          
          {/* Error message */}
          {error && (
            <motion.div
              initial={{ opacity: 0, y: -10 }}
              animate={{ opacity: 1, y: 0 }}
              className={`mt-2 text-xs tracking-wider uppercase font-light ${
                isUtopian ? 'text-red-600' : 'text-red-400'
              }`}
            >
              {error}
            </motion.div>
          )}
        </form>
      ) : (
        <motion.div
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center"
        >
          <motion.div
            animate={{ 
              opacity: [0.5, 1, 0.5],
            }}
            transition={{ duration: 2, repeat: Infinity }}
            className={`tracking-[0.3em] uppercase text-sm font-light transition-colors duration-500 ${
              isUtopian ? 'text-amber-500' : 'text-cyan-400'
            }`}
            style={{
              textShadow: isUtopian
                ? '0 0 10px rgba(255,215,0,0.6), 0 0 20px rgba(255,215,0,0.3)'
                : '0 0 10px rgba(0,255,255,0.8), 0 0 20px rgba(0,255,255,0.5)',
            }}
          >
            {isUtopian ? '✓ VISION RECEIVED' : '✓ SIGNAL RECEIVED'}
          </motion.div>
          
          {/* Verification Type Message */}
          {successMessage && (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3 }}
              className={`mt-4 text-xs tracking-[0.4em] uppercase font-light transition-colors duration-500 ${
                isUtopian ? 'text-amber-600' : 'text-cyan-500'
              }`}
              style={{
                textShadow: isUtopian
                  ? '0 0 8px rgba(255,215,0,0.4)'
                  : '0 0 8px rgba(0,255,255,0.4)',
              }}
            >
              // {successMessage} //
            </motion.div>
          )}
        </motion.div>
      )}
      
      <motion.p
        initial={{ opacity: 0 }}
        animate={{ opacity: 0.5 }}
        transition={{ duration: 1, delay: 1.2 }}
        className={`text-center text-xs mt-6 tracking-[0.3em] uppercase font-light transition-colors duration-500 ${
          isUtopian ? 'text-amber-600' : 'text-cyan-500'
        }`}
      >
        <motion.span
          animate={{
            opacity: [0.5, 0.8, 0.5],
          }}
          transition={{ duration: 3, repeat: Infinity }}
        >
          {isUtopian ? '// JOIN THE FUTURE //' : '// INITIATE CONNECTION //'}
        </motion.span>
      </motion.p>
    </motion.div>
  );
}