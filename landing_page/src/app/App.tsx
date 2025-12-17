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
import { WageCage } from './pages/WageCage';
import { InviteRedirector } from '../components/InviteRedirector';

export default function App() {
  return (
    <BrowserRouter>
      <ThemeProvider>
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
      </ThemeProvider>
    </BrowserRouter>
  );
}
