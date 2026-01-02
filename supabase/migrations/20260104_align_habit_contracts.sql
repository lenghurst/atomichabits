-- Phase 22 Repair: Align Habit Contracts Schema with Dart Model
-- Addresses mismatch between deployed UUID schema and Dart's String IDs
-- Adds missing fields from Phase 21.3 (Nudge Effectiveness) and Phase 61 (Safety)
-- Handles Policy dependencies to prevent "cannot alter type" errors

BEGIN;

-- 1. Drop Dependent Policies (Blocking ALTER)
-- contract_events policies (referencing habit_contracts.id in subquery)
DROP POLICY IF EXISTS "Contract parties can view events" ON public.contract_events;
DROP POLICY IF EXISTS "Contract parties can insert events" ON public.contract_events;

-- witness_events policies (referencing habit_contracts.id in subquery)
DROP POLICY IF EXISTS "Users can create events for their contracts" ON public.witness_events;

-- 2. Drop Foreign Key Dependencies
-- We need to drop constraints referencing habit_contracts.id before changing its type
ALTER TABLE public.witness_events
  DROP CONSTRAINT IF EXISTS witness_events_contract_id_fkey;

ALTER TABLE public.contract_events
  DROP CONSTRAINT IF EXISTS contract_events_contract_id_fkey;

-- 3. Alter IDs to TEXT
-- Dart model generates "contract_${hash}" (String), not UUID.
ALTER TABLE public.habit_contracts
  ALTER COLUMN id DROP DEFAULT, -- Remove gen_random_uuid() default
  ALTER COLUMN id TYPE TEXT,
  ALTER COLUMN habit_id TYPE TEXT; -- Dart model uses String for habitId

-- Update dependent tables to match
ALTER TABLE public.witness_events
  ALTER COLUMN contract_id TYPE TEXT;

ALTER TABLE public.contract_events
  ALTER COLUMN contract_id TYPE TEXT;

-- 4. Re-add Foreign Key Constraints
ALTER TABLE public.witness_events
  ADD CONSTRAINT witness_events_contract_id_fkey
  FOREIGN KEY (contract_id) REFERENCES public.habit_contracts(id)
  ON DELETE CASCADE;

ALTER TABLE public.contract_events
  ADD CONSTRAINT contract_events_contract_id_fkey
  FOREIGN KEY (contract_id) REFERENCES public.habit_contracts(id)
  ON DELETE CASCADE;

-- 5. Add Missing Columns
ALTER TABLE public.habit_contracts
  -- Display fields
  ADD COLUMN IF NOT EXISTS builder_display_name TEXT,
  ADD COLUMN IF NOT EXISTS habit_emoji TEXT,
  
  -- Phase 4: Identity Privacy
  ADD COLUMN IF NOT EXISTS alternative_identity TEXT,
  
  -- Phase 21.3: Nudge Effectiveness
  ADD COLUMN IF NOT EXISTS last_nudge_sent_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS last_nudge_response_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS nudges_received_count INTEGER DEFAULT 0,
  ADD COLUMN IF NOT EXISTS nudges_responded_count INTEGER DEFAULT 0,
  
  -- Phase 61: Safety & Settings
  ADD COLUMN IF NOT EXISTS share_psychometrics BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS allow_nudges BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS nudge_history JSONB DEFAULT '{}'::jsonb,
  ADD COLUMN IF NOT EXISTS nudge_quiet_start TEXT, -- Format: "HH:MM"
  ADD COLUMN IF NOT EXISTS nudge_quiet_end TEXT,   -- Format: "HH:MM"
  ADD COLUMN IF NOT EXISTS blocked_witness_ids TEXT[] DEFAULT '{}',
  ADD COLUMN IF NOT EXISTS allow_emergency_exit BOOLEAN DEFAULT TRUE,
  ADD COLUMN IF NOT EXISTS is_under_review BOOLEAN DEFAULT FALSE,
  ADD COLUMN IF NOT EXISTS reported_at TIMESTAMPTZ;

-- 6. Re-create Dropped Policies
-- contract_events
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

-- witness_events
CREATE POLICY "Users can create events for their contracts"
  ON public.witness_events FOR INSERT
  WITH CHECK (
      auth.uid() = actor_id
      AND EXISTS (
          SELECT 1 FROM public.habit_contracts
          WHERE id = contract_id
          AND (builder_id = auth.uid() OR witness_id = auth.uid())
      )
  );

COMMIT;
