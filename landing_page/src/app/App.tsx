/**
 * App.tsx
 * 
 * Phase 24.E: Updated with "The Trojan Horse" route
 * 
 * Routes:
 * - / : Main landing page (AppContent)
 * - /join/:inviteCode : Invite redirector (handles mobile → app store, desktop → landing page with banner)
 * - /wage-cage : Existing page
 */

import { ThemeProvider } from './context/ThemeContext';
import { AppContent } from './AppContent';
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { lazy, Suspense } from 'react';

// Lazy load routes to optimize initial bundle size
const WageCage = lazy(() => import('./pages/WageCage').then(module => ({ default: module.WageCage })));
const InviteRedirector = lazy(() => import('../components/InviteRedirector').then(module => ({ default: module.InviteRedirector })));

// Simple loading fallback
const PageLoader = () => (
  <div className="min-h-screen flex items-center justify-center bg-black text-white">
    <div className="w-8 h-8 border-t-2 border-white rounded-full animate-spin"></div>
  </div>
);

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        <Suspense fallback={<PageLoader />}>
          <Routes>
            {/* Main Landing Page */}
            <Route path="/" element={<AppContent />} />

            {/* Phase 24.E: The Trojan Horse Route
                - Mobile: Redirects to App Store with referrer
                - Desktop: Shows landing page with invite banner */}
            <Route
              path="/join/:inviteCode"
              element={<InviteRedirector MainContent={AppContent} />}
            />

            {/* Existing Routes */}
            <Route path="/wage-cage" element={<WageCage />} />
          </Routes>
        </Suspense>
      </ThemeProvider>
    </BrowserRouter>
  );
}
