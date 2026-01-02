-- Identity Seeds: Core psychometric profile for cloud analysis
-- Created: 2026-01-02
-- Part of Phase 63 (Psychometric Cloud Sync)

CREATE TABLE public.identity_seeds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- === HOLY TRINITY (Sherlock Protocol) ===
  anti_identity_label TEXT,
  anti_identity_context TEXT,
  failure_archetype TEXT,
  failure_trigger_context TEXT,
  resistance_lie_label TEXT,
  resistance_lie_context TEXT,
  
  -- === CORE DRIVERS ===
  core_values TEXT[] DEFAULT '{}',
  big_why TEXT,
  inferred_fears TEXT[] DEFAULT '{}',
  resonance_words TEXT[] DEFAULT '{}',
  avoid_words TEXT[] DEFAULT '{}',

  -- === COMMUNICATION MATRIX ===
  coaching_style TEXT DEFAULT 'supportive',
  verbosity_preference INTEGER DEFAULT 3,
  
  -- === SYNC METADATA ===
  hive_last_updated TIMESTAMPTZ,  -- Last update timestamp from device (client-side truth)
  sync_status TEXT DEFAULT 'synced' CHECK (sync_status IN ('pending', 'synced', 'conflict')),
  
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT one_seed_per_user UNIQUE (user_id)
);

-- Indexes for performance
CREATE INDEX idx_identity_seeds_user ON public.identity_seeds(user_id);
CREATE INDEX idx_identity_seeds_archetype ON public.identity_seeds(failure_archetype);

-- RLS (CRITICAL - sensitive psychological data)
ALTER TABLE public.identity_seeds ENABLE ROW LEVEL SECURITY;

-- Policy: Users can view their own identity data
CREATE POLICY "Users can view own identity"
  ON public.identity_seeds FOR SELECT
  USING (auth.uid() = user_id);

-- Policy: Users can insert their own identity data
CREATE POLICY "Users can insert own identity"
  ON public.identity_seeds FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Policy: Users can update their own identity data
CREATE POLICY "Users can update own identity"
  ON public.identity_seeds FOR UPDATE
  USING (auth.uid() = user_id);

-- Auto-update timestamp trigger
-- Note: Assuming update_updated_at_column() function exists from previous migrations. 
-- If not, it should be created. We'll add a safer check/creation just in case, 
-- or rely on standard Supabase conventions.
-- For robustness, we'll try to use the existing trigger function or create it if missing.

CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_identity_seeds_updated_at
  BEFORE UPDATE ON public.identity_seeds
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
