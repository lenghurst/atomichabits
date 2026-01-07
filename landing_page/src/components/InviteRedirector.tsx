/**
 * InviteRedirector.tsx
 * 
 * Phase 24.E: "The Trojan Horse"
 * 
 * This component handles the viral loop entry point:
 * - Mobile users: Redirected to App Store (Android/iOS)
 * - Desktop users: See landing page with invite banner + copy code button
 * 
 * Strategic Purpose:
 * - Convert "failed redirects" (desktop) into email signups
 * - Provide seamless mobile app store redirect with referrer tracking
 * - Maintain brand consistency with polished UI
 */

import { useEffect, useState } from 'react';
import { useParams } from 'react-router-dom';
import { motion } from 'motion/react';
import { Download } from 'lucide-react';
// import { supabase } from '../lib/supabaseClient'; // Uncomment when analytics enabled

// --- CONFIGURATION ---
const IOS_APP_STORE_URL = ""; // e.g., "https://apps.apple.com/app/id123456789"

interface InviteRedirectorProps {
  MainContent?: React.ComponentType<any>;
}

export function InviteRedirector({ MainContent }: InviteRedirectorProps) {
  const { inviteCode } = useParams();
  const [isMobile, setIsMobile] = useState(false);
  const [copySuccess, setCopySuccess] = useState(false);
  const [iosCopySuccess, setIosCopySuccess] = useState(false);
  const [platform, setPlatform] = useState<'android' | 'ios' | 'desktop'>('desktop');

  useEffect(() => {
    const userAgent = navigator.userAgent || navigator.vendor;
    const isAndroid = /android/i.test(userAgent);
    const isIOS = /iPad|iPhone|iPod/.test(userAgent) && !(window as any).MSStream;

    // Determine platform
    const detectedPlatform = isAndroid ? 'android' : isIOS ? 'ios' : 'desktop';
    setPlatform(detectedPlatform);

    // --- Analytics Tracking (Uncomment when Supabase is configured) ---
    /*
    if (inviteCode) {
      supabase.from('invite_clicks').insert({
        invite_code: inviteCode,
        platform: detectedPlatform,
        user_agent: navigator.userAgent,
        referrer: document.referrer,
        timestamp: new Date().toISOString(),
      }).then(() => {
        console.log('Invite click tracked');
      });
    }
    */

    if (isAndroid) {
      setIsMobile(true);
      
      // 1. Try Market Link (Standard Protocol - passes referrer to Play Store)
      window.location.href = `market://details?id=co.thepact.app&referrer=invite_code%3D${inviteCode}`;
      
      // 2. Fallback to Web Play Store after 2.5s (if market:// fails)
      setTimeout(() => {
        window.location.href = `https://play.google.com/store/apps/details?id=co.thepact.app&referrer=invite_code%3D${inviteCode}`;
      }, 2500);
    } 
    else if (isIOS) {
      setIsMobile(true);
      // Logic split:
      // If URL exists: Stay on "Mobile" screen to show button.
      // If URL missing: Stay on "Mobile" screen to show "Coming Soon".
      // console.log("iOS user detected.");
    } 
    else {
      // Desktop: Stay on landing page with banner
      console.log("Desktop user detected. Showing landing page with invite banner.");
    }
  }, [inviteCode]);

  const handleCopy = async () => {
    if (inviteCode) {
      try {
        await navigator.clipboard.writeText(inviteCode);
        setCopySuccess(true);
        setTimeout(() => setCopySuccess(false), 2000);
      } catch (err) {
        fallbackCopy(inviteCode);
      }
    }
  };

  const handleIOSDownload = async () => {
    if (inviteCode) {
      try {
        await navigator.clipboard.writeText(inviteCode);
        setIosCopySuccess(true);
        setTimeout(() => {
          setIosCopySuccess(false);
          // Only redirect if URL is set
          if (IOS_APP_STORE_URL) {
              window.location.href = IOS_APP_STORE_URL;
          }
        }, 1000);
      } catch (err) {
        fallbackCopy(inviteCode);
        setIosCopySuccess(true);
        setTimeout(() => {
             setIosCopySuccess(false);
             if (IOS_APP_STORE_URL) {
                 window.location.href = IOS_APP_STORE_URL;
             }
        }, 1000);
      }
    } else {
        // No invite code, just redirect
        if (IOS_APP_STORE_URL) {
            window.location.href = IOS_APP_STORE_URL;
        }
    }
  };

  const fallbackCopy = (text: string) => {
    const textArea = document.createElement('textarea');
    textArea.value = text;
    document.body.appendChild(textArea);
    textArea.select();
    document.execCommand('copy');
    document.body.removeChild(textArea);
    setCopySuccess(true);
    setTimeout(() => setCopySuccess(false), 2000);
  }

  // Mobile View: Clean "Redirecting" Screen
  if (isMobile) {
    return (
      <div className="flex h-screen w-screen flex-col items-center justify-center bg-black text-white">
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          transition={{ duration: 0.5, ease: 'easeOut' }}
          className="text-center px-6"
        >
          {/* Animated Rocket */}
          <motion.div 
            className="mb-6 text-7xl"
            animate={{ y: [0, -10, 0] }}
            transition={{ duration: 1.5, repeat: Infinity, ease: 'easeInOut' }}
          >
            🚀
          </motion.div>
          
          <h2 className="text-2xl font-bold tracking-tight">
            Opening The Pact...
          </h2>
          
          <p className="mt-4 text-gray-400">
            {platform === 'ios' ? 'Redirecting to App Store' : 'Redirecting to Play Store'}
          </p>
          
          {/* Invite Code Badge */}
          <div className="mt-4 inline-flex items-center gap-2 rounded-full bg-zinc-900 px-4 py-2">
            <span className="text-gray-400 text-sm">Invite:</span>
            <span className="font-mono text-emerald-400 font-medium">
              {inviteCode}
            </span>
          </div>
          
          {/* Loading indicator - Show only if NOT iOS or if iOS but NO URL (Coming Soon state) */}
          {/* If iOS AND URL exists, we hide the spinner and show the button instead to be less confusing */}
          {/* FIX: Use platform !== 'ios' instead of !isIOS to avoid ReferenceError */}
          {(platform !== 'ios' || (platform === 'ios' && !IOS_APP_STORE_URL)) && (
             <motion.div
               className="mt-8 h-1 w-48 mx-auto bg-zinc-800 rounded-full overflow-hidden"
             >
               <motion.div
                 className="h-full bg-gradient-to-r from-cyan-500 to-purple-500"
                 initial={{ width: '0%' }}
                 animate={{ width: '100%' }}
                 transition={{ duration: 2.5, ease: 'linear' }}
               />
             </motion.div>
          )}
          
          {/* iOS Handling */}
          {platform === 'ios' && (
            <div className="mt-8">
                {IOS_APP_STORE_URL ? (
                    // URL AVAILABLE: Show Button
                    <motion.button
                        initial={{ opacity: 0, y: 10 }}
                        animate={{ opacity: 1, y: 0 }}
                        onClick={handleIOSDownload}
                        className={`
                            group relative flex items-center justify-center gap-3
                            px-8 py-4 rounded-xl font-bold text-lg
                            transition-all duration-300 transform active:scale-95
                            ${iosCopySuccess
                                ? 'bg-emerald-500 text-white shadow-[0_0_20px_rgba(16,185,129,0.5)]'
                                : 'bg-white text-black hover:bg-gray-100 shadow-[0_0_20px_rgba(255,255,255,0.3)]'
                            }
                        `}
                    >
                         {iosCopySuccess ? (
                            <>
                                <span>✓ Code Copied!</span>
                            </>
                         ) : (
                            <>
                                <Download className="w-6 h-6" />
                                <span>Download on App Store</span>
                            </>
                         )}
                    </motion.button>
                ) : (
                    // URL MISSING: Show "Coming Soon"
                    <motion.p
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        transition={{ delay: 1 }}
                        className="mt-6 text-sm text-amber-400"
                    >
                        iOS app coming soon! Sign up below to get notified.
                    </motion.p>
                )}
            </div>
          )}
        </motion.div>
      </div>
    );
  }

  // Desktop View: Render Main Content with "Sticky Banner"
  return (
    <div className="relative">
      {/* Invite Banner */}
      <motion.div 
        initial={{ y: -100, opacity: 0 }}
        animate={{ y: 0, opacity: 1 }}
        transition={{ duration: 0.5, ease: 'easeOut' }}
        className="fixed top-0 left-0 right-0 z-50 bg-gradient-to-r from-amber-500 to-orange-500 shadow-lg"
      >
        <div className="flex flex-wrap items-center justify-center gap-2 sm:gap-4 px-4 py-3">
          {/* Message */}
          <span className="font-bold text-black text-sm sm:text-base">
            🎉 You've been invited!
          </span>
          
          {/* Code + Copy Button */}
          <div className="flex items-center gap-2 rounded-lg bg-black/20 px-3 py-1.5">
            <span className="font-mono text-sm text-black/80">
              {inviteCode}
            </span>
            <button 
              onClick={handleCopy}
              className={`
                rounded px-3 py-1 text-xs font-bold transition-all duration-200
                ${copySuccess 
                  ? 'bg-emerald-500 text-white' 
                  : 'bg-black text-white hover:bg-zinc-800'
                }
              `}
            >
              {copySuccess ? '✓ COPIED!' : 'COPY CODE'}
            </button>
          </div>
          
          {/* Instructions */}
          <span className="hidden sm:inline text-sm text-black/70">
            ← Use this code in the mobile app
          </span>
        </div>
      </motion.div>
      
      {/* Spacer to prevent content from being hidden under fixed banner */}
      <div className="h-14 sm:h-12" />
      
      {/* Render the actual Landing Page underneath */}
      {MainContent && <MainContent />}
    </div>
  );
}

export default InviteRedirector;
