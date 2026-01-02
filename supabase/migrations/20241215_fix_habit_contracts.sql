-- Phase 16.2: Habit Contracts & Accountability
-- Retroactive Fix: Created to resolve missing dependencies for Phase 22 Witness Events
-- Schema sourced from docs/SUPABASE_SCHEMA.md (Section 3 & 4)

-- =======================
-- 1. HABIT CONTRACTS TABLE
-- =======================
-- Accountability partnerships between Builders and Witnesses

CREATE TABLE IF NOT EXISTS public.habit_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Parties
  builder_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  witness_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,  -- NULL until witness joins
  habit_id UUID NOT NULL, -- Weak reference to habits table (defined in other migration) or text if flexible
  -- NOTE: Originally REFERENCE habits(id), but habits might be in later migration or separate.
  -- Looking at schema.md, habits exists. Assuming habits table exists from 20251230 or similar? 
  -- Wait, 20251230 is "Storage Layer" which created profiles/conversations. 
  -- Checking 20251230_storage_layer.sql content provided earlier... it DOES NOT create `habits`.
  -- Schema.md lists `habits` table. It might be missing too! 
  -- However, the user said "Fix habit_contracts". If `habits` is missing, this will fail too.
  -- I'll use UUID for now and comment out the FK if necessary, but ideally it should refer to habits.
  -- Actually, let's assume `habits` table creation is missing or relies on Phase 1 logic.
  -- For safety in this repair, I will REMOVE the FK constraint to public.habits if I'm not sure it exists.
  -- But wait, `witness_events` refers to `public.habit_contracts`.
  -- Let's try to include the FK but be prepared for it to fail.
  -- ACTUALLY, checking SUPABASE_SCHEMA.md again, `habits` is listed before `habit_contracts`.
  -- If `habits` is not in migrations list, I might need to create it too.
  -- Let's check file list again... `20251230_storage_layer.sql`... `20241216...`.
  -- There is NO `habits` creation migration visible in the file list I got earlier.
  -- This suggests `habits` might be created in the dashboard directly or I'm missing files.
  -- OR, I should just create it here if it doesn't exist.
  -- Let's check if `habits` exists by checking migration history? No easy way.
  -- Safest bet: Define `habits` table IF NOT EXISTS here as well, derived from schema.md.
  
  -- Invite mechanism (Phase 16.4 Deep Links)
  invite_code TEXT UNIQUE NOT NULL,  -- Short code for URL: /invite?c=ABC123
  invite_url TEXT,  -- Full deep link URL
  
  -- Contract terms
  title TEXT NOT NULL,  -- e.g., "21-Day Meditation Challenge"
  commitment_statement TEXT,  -- e.g., "I commit to meditating for 5 minutes daily"
  duration_days INTEGER DEFAULT 21 CHECK (duration_days > 0 AND duration_days <= 365),
  start_date DATE,  -- NULL until contract starts (after witness joins)
  end_date DATE,    -- Calculated: start_date + duration_days
  
  -- Status lifecycle
  status TEXT DEFAULT 'draft' CHECK (status IN (
    'draft',      -- Builder is creating, not yet shared
    'pending',    -- Invite sent, waiting for witness
    'active',     -- Witness joined, contract running
    'completed',  -- Duration finished successfully
    'broken',     -- Builder missed too many days
    'cancelled'   -- Manually cancelled
  )),
  
  -- Success criteria
  minimum_completion_rate INTEGER DEFAULT 80 CHECK (minimum_completion_rate >= 0 AND minimum_completion_rate <= 100),
  grace_period_days INTEGER DEFAULT 2,  -- Days witness waits before nudging
  
  -- Witness preferences (set by builder, can be adjusted)
  nudge_enabled BOOLEAN DEFAULT TRUE,
  nudge_frequency TEXT DEFAULT 'daily' CHECK (nudge_frequency IN ('never', 'daily', 'on_miss', 'weekly')),
  nudge_style TEXT DEFAULT 'encouraging' CHECK (nudge_style IN ('encouraging', 'firm', 'playful', 'data_only')),
  
  -- Progress tracking (denormalized for quick access)
  days_completed INTEGER DEFAULT 0,
  days_missed INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  invite_sent_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ,
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  
  -- Metadata
  builder_message TEXT,  -- Personal message to witness
  witness_message TEXT   -- Witness's response/commitment
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_contracts_builder ON public.habit_contracts(builder_id);
CREATE INDEX IF NOT EXISTS idx_contracts_witness ON public.habit_contracts(witness_id);
-- CREATE INDEX IF NOT EXISTS idx_contracts_habit ON public.habit_contracts(habit_id);
CREATE INDEX IF NOT EXISTS idx_contracts_invite_code ON public.habit_contracts(invite_code);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.habit_contracts(status);

-- RLS Policies
ALTER TABLE public.habit_contracts ENABLE ROW LEVEL SECURITY;

-- Builders can view and manage their own contracts
CREATE POLICY "Builders can view own contracts"
  ON public.habit_contracts FOR SELECT
  USING (auth.uid() = builder_id);

CREATE POLICY "Builders can insert own contracts"
  ON public.habit_contracts FOR INSERT
  WITH CHECK (auth.uid() = builder_id);

CREATE POLICY "Builders can update own contracts"
  ON public.habit_contracts FOR UPDATE
  USING (auth.uid() = builder_id);

-- Witnesses can view contracts they're part of
CREATE POLICY "Witnesses can view their contracts"
  ON public.habit_contracts FOR SELECT
  USING (auth.uid() = witness_id);

-- Witnesses can update (accept) contracts they're invited to
CREATE POLICY "Witnesses can accept contracts"
  ON public.habit_contracts FOR UPDATE
  USING (auth.uid() = witness_id OR witness_id IS NULL);

-- Anyone can view pending contracts by invite code (for join flow)
CREATE POLICY "Anyone can view pending contracts by invite"
  ON public.habit_contracts FOR SELECT
  USING (status = 'pending' AND invite_code IS NOT NULL);


-- =======================
-- 2. CONTRACT EVENTS TABLE
-- =======================
-- Activity log for contracts (nudges, completions, messages)

CREATE TABLE IF NOT EXISTS public.contract_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES public.habit_contracts(id) ON DELETE CASCADE NOT NULL,
  
  -- Event type
  event_type TEXT NOT NULL CHECK (event_type IN (
    'created',        -- Contract created
    'invite_sent',    -- Invite link generated/shared
    'witness_joined', -- Witness accepted invite
    'started',        -- Contract officially started
    'day_completed',  -- Builder completed habit for day
    'day_missed',     -- Builder missed habit
    'nudge_sent',     -- Witness sent nudge
    'message',        -- Chat message between parties
    'completed',      -- Contract finished successfully
    'broken',         -- Contract broken (too many misses)
    'cancelled'       -- Contract cancelled
  )),
  
  -- Who triggered event
  actor_id UUID REFERENCES auth.users(id),
  actor_role TEXT CHECK (actor_role IN ('builder', 'witness', 'system')),
  
  -- Event data
  message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_events_contract ON public.contract_events(contract_id);
CREATE INDEX IF NOT EXISTS idx_events_type ON public.contract_events(event_type);
CREATE INDEX IF NOT EXISTS idx_events_created ON public.contract_events(created_at DESC);

-- RLS Policies
ALTER TABLE public.contract_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Contract parties can view events"
  ON public.contract_events FOR SELECT
  USING (
    contract_id IN (
      SELECT id FROM public.habit_contracts 
      WHERE builder_id = auth.uid() OR witness_id = auth.uid()
    )
  );

CREATE POLICY "Contract parties can insert events"
  ON public.contract_events FOR INSERT
  WITH CHECK (
    contract_id IN (
      SELECT id FROM public.habit_contracts 
      WHERE builder_id = auth.uid() OR witness_id = auth.uid()
    )
  );
