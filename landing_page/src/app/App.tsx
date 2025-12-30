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
import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { Suspense, lazy } from 'react';

// ⚡ Bolt: Route-based code splitting to reduce initial bundle size
const AppContent = lazy(() => import('./AppContent').then(module => ({ default: module.AppContent })));
const WageCage = lazy(() => import('./pages/WageCage').then(module => ({ default: module.WageCage })));
const InviteRedirector = lazy(() => import('../components/InviteRedirector').then(module => ({ default: module.InviteRedirector })));

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        {/* ⚡ Bolt: Suspense boundary for lazy-loaded routes */}
        <Suspense fallback={<div className="min-h-screen bg-black" />}>
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
