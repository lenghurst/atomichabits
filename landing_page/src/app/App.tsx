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
import { Suspense, lazy } from 'react';
import { LoadingSpinner } from '../components/LoadingSpinner';

// Lazy loaded components for code splitting
// Using named export pattern for both components to be safe and consistent
const WageCage = lazy(() => import('./pages/WageCage').then(module => ({ default: module.WageCage })));
// InviteRedirector has both named and default exports, but using named export extraction ensures we get the right one
// consistent with WageCage handling and reviewing feedback.
const InviteRedirector = lazy(() => import('../components/InviteRedirector').then(module => ({ default: module.InviteRedirector })));

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
        <Suspense fallback={<LoadingSpinner />}>
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
