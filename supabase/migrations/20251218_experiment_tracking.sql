-- Phase 25.3: The Lab 2.0 - Experiment Tracking Tables
-- 
-- This migration creates the tables required for A/B test analytics:
-- 1. experiment_assignments - Stores user bucket assignments (sticky)
-- 2. experiment_events - Time-series events for analysis
-- 3. ai_token_usage - Tracks ephemeral token generation (for cost monitoring)
-- 4. wallet_passes - Tracks Google Wallet pass creation

-- ============================================================
-- EXPERIMENT ASSIGNMENTS (Sticky Bucketing)
-- ============================================================
CREATE TABLE IF NOT EXISTS experiment_assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  experiment_name TEXT NOT NULL,
  variant TEXT NOT NULL,
  assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  is_new_assignment BOOLEAN DEFAULT TRUE,
  app_version TEXT,
  
  -- Ensure one assignment per user per experiment
  CONSTRAINT unique_user_experiment UNIQUE (user_id, experiment_name)
);

-- Index for querying by experiment
CREATE INDEX IF NOT EXISTS idx_experiment_assignments_experiment 
  ON experiment_assignments(experiment_name, variant);

-- Index for querying by user
CREATE INDEX IF NOT EXISTS idx_experiment_assignments_user 
  ON experiment_assignments(user_id);

-- Enable RLS
ALTER TABLE experiment_assignments ENABLE ROW LEVEL SECURITY;

-- Users can only read their own assignments
CREATE POLICY "Users can view own assignments" 
  ON experiment_assignments FOR SELECT 
  USING (auth.uid() = user_id);

-- Service role can insert/update (via Edge Functions)
CREATE POLICY "Service role can manage assignments" 
  ON experiment_assignments FOR ALL 
  USING (auth.role() = 'service_role');

-- Authenticated users can insert their own assignments
CREATE POLICY "Users can insert own assignments" 
  ON experiment_assignments FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- EXPERIMENT EVENTS (Time-Series Analytics)
-- ============================================================
CREATE TABLE IF NOT EXISTS experiment_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  experiment_name TEXT NOT NULL,
  variant TEXT NOT NULL,
  event_type TEXT NOT NULL, -- 'assignment', 'exposure', 'conversion'
  conversion_type TEXT, -- e.g., 'onboarding_complete', 'first_checkin'
  metadata JSONB,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Index for time-series queries
CREATE INDEX IF NOT EXISTS idx_experiment_events_time 
  ON experiment_events(experiment_name, created_at DESC);

-- Index for conversion analysis
CREATE INDEX IF NOT EXISTS idx_experiment_events_conversion 
  ON experiment_events(experiment_name, variant, event_type);

-- Enable RLS
ALTER TABLE experiment_events ENABLE ROW LEVEL SECURITY;

-- Users can only insert their own events
CREATE POLICY "Users can insert own events" 
  ON experiment_events FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Service role can read all events (for analytics)
CREATE POLICY "Service role can read all events" 
  ON experiment_events FOR SELECT 
  USING (auth.role() = 'service_role');

-- ============================================================
-- AI TOKEN USAGE (Cost Monitoring)
-- ============================================================
CREATE TABLE IF NOT EXISTS ai_token_usage (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  model TEXT NOT NULL,
  token_type TEXT NOT NULL, -- 'ephemeral', 'standard'
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ
);

-- Index for usage queries
CREATE INDEX IF NOT EXISTS idx_ai_token_usage_user 
  ON ai_token_usage(user_id, created_at DESC);

-- Index for cost analysis
CREATE INDEX IF NOT EXISTS idx_ai_token_usage_model 
  ON ai_token_usage(model, created_at DESC);

-- Enable RLS
ALTER TABLE ai_token_usage ENABLE ROW LEVEL SECURITY;

-- Service role can manage (Edge Functions)
CREATE POLICY "Service role can manage token usage" 
  ON ai_token_usage FOR ALL 
  USING (auth.role() = 'service_role');

-- ============================================================
-- WALLET PASSES (Google Wallet Integration)
-- ============================================================
CREATE TABLE IF NOT EXISTS wallet_passes (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  pact_id UUID NOT NULL, -- References the habit/pact
  pass_object_id TEXT NOT NULL, -- Google Wallet object ID
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  
  -- One pass per user per pact
  CONSTRAINT unique_user_pact_pass UNIQUE (user_id, pact_id)
);

-- Index for user queries
CREATE INDEX IF NOT EXISTS idx_wallet_passes_user 
  ON wallet_passes(user_id);

-- Enable RLS
ALTER TABLE wallet_passes ENABLE ROW LEVEL SECURITY;

-- Users can view their own passes
CREATE POLICY "Users can view own passes" 
  ON wallet_passes FOR SELECT 
  USING (auth.uid() = user_id);

-- Service role can manage (Edge Functions)
CREATE POLICY "Service role can manage passes" 
  ON wallet_passes FOR ALL 
  USING (auth.role() = 'service_role');

-- ============================================================
-- ANALYTICS VIEWS (For Dashboard Queries)
-- ============================================================

-- View: Experiment conversion rates by variant
CREATE OR REPLACE VIEW experiment_conversion_rates AS
SELECT 
  e.experiment_name,
  e.variant,
  COUNT(DISTINCT e.user_id) AS total_users,
  COUNT(DISTINCT CASE WHEN e.event_type = 'conversion' THEN e.user_id END) AS converted_users,
  ROUND(
    COUNT(DISTINCT CASE WHEN e.event_type = 'conversion' THEN e.user_id END)::NUMERIC / 
    NULLIF(COUNT(DISTINCT e.user_id), 0) * 100, 
    2
  ) AS conversion_rate_pct
FROM experiment_events e
GROUP BY e.experiment_name, e.variant
ORDER BY e.experiment_name, e.variant;

-- View: Daily experiment assignments
CREATE OR REPLACE VIEW daily_experiment_assignments AS
SELECT 
  DATE(assigned_at) AS assignment_date,
  experiment_name,
  variant,
  COUNT(*) AS assignments
FROM experiment_assignments
WHERE is_new_assignment = TRUE
GROUP BY DATE(assigned_at), experiment_name, variant
ORDER BY assignment_date DESC, experiment_name, variant;

-- ============================================================
-- COMMENTS (Documentation)
-- ============================================================
COMMENT ON TABLE experiment_assignments IS 'Stores sticky bucket assignments for A/B tests';
COMMENT ON TABLE experiment_events IS 'Time-series events for experiment analysis';
COMMENT ON TABLE ai_token_usage IS 'Tracks AI token generation for cost monitoring';
COMMENT ON TABLE wallet_passes IS 'Tracks Google Wallet pass creation per user/pact';
