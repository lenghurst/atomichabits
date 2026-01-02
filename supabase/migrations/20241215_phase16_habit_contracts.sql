-- Phase 16.2: Habit Contracts - Social Accountability System
--
-- This migration creates the habit_contracts and contract_events tables
-- for "The Witness" accountability partnership feature.
--
-- Lifecycle:
-- 1. draft     - Builder is creating the contract
-- 2. pending   - Invite sent, waiting for witness to join
-- 3. active    - Witness joined, contract is running
-- 4. completed - Contract finished successfully
-- 5. broken    - Builder missed too many days
-- 6. cancelled - Manually cancelled by either party
--
-- Dependencies: None (must run before witness_events migration)

-- =============================================================================
-- HABIT_CONTRACTS TABLE
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.habit_contracts (
    -- Primary key (client-generated)
    id TEXT PRIMARY KEY,

    -- Parties
    builder_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    witness_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    habit_id TEXT NOT NULL,  -- References local habit, not cloud table

    -- Invite mechanism (Phase 16.4 Deep Links)
    invite_code TEXT UNIQUE NOT NULL,
    invite_url TEXT,

    -- Contract terms
    title TEXT NOT NULL,
    commitment_statement TEXT,
    duration_days INTEGER DEFAULT 21 CHECK (duration_days > 0 AND duration_days <= 365),
    start_date DATE,
    end_date DATE,

    -- Status lifecycle
    status TEXT DEFAULT 'draft' CHECK (status IN (
        'draft',
        'pending',
        'active',
        'completed',
        'broken',
        'cancelled'
    )),

    -- Success criteria
    minimum_completion_rate INTEGER DEFAULT 80 CHECK (minimum_completion_rate >= 0 AND minimum_completion_rate <= 100),
    grace_period_days INTEGER DEFAULT 2,

    -- Nudge settings
    nudge_enabled BOOLEAN DEFAULT TRUE,
    nudge_frequency TEXT DEFAULT 'daily' CHECK (nudge_frequency IN ('never', 'daily', 'onMiss', 'weekly')),
    nudge_style TEXT DEFAULT 'encouraging' CHECK (nudge_style IN ('encouraging', 'firm', 'playful', 'dataOnly')),

    -- Progress tracking (denormalized for quick access)
    days_completed INTEGER DEFAULT 0,
    days_missed INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,

    -- Phase 21.3: Nudge Effectiveness Tracking
    last_nudge_sent_at TIMESTAMPTZ,
    last_nudge_response_at TIMESTAMPTZ,
    nudges_received_count INTEGER DEFAULT 0,
    nudges_responded_count INTEGER DEFAULT 0,

    -- Phase 61: Safety by Design
    share_psychometrics BOOLEAN DEFAULT FALSE,
    allow_nudges BOOLEAN DEFAULT TRUE,
    nudge_history JSONB DEFAULT '{}'::jsonb,
    nudge_quiet_start TEXT,  -- HH:MM format
    nudge_quiet_end TEXT,    -- HH:MM format
    blocked_witness_ids TEXT[] DEFAULT '{}',
    allow_emergency_exit BOOLEAN DEFAULT TRUE,
    is_under_review BOOLEAN DEFAULT FALSE,
    reported_at TIMESTAMPTZ,

    -- Phase 4: Identity Privacy
    alternative_identity TEXT,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
    invite_sent_at TIMESTAMPTZ,
    accepted_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,

    -- Messages
    builder_message TEXT,
    witness_message TEXT
);

-- =============================================================================
-- INDEXES FOR HABIT_CONTRACTS
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_contracts_builder_id
    ON public.habit_contracts(builder_id);

CREATE INDEX IF NOT EXISTS idx_contracts_witness_id
    ON public.habit_contracts(witness_id);

CREATE INDEX IF NOT EXISTS idx_contracts_habit_id
    ON public.habit_contracts(habit_id);

CREATE INDEX IF NOT EXISTS idx_contracts_invite_code
    ON public.habit_contracts(invite_code);

CREATE INDEX IF NOT EXISTS idx_contracts_status
    ON public.habit_contracts(status);

CREATE INDEX IF NOT EXISTS idx_contracts_created_at
    ON public.habit_contracts(created_at DESC);

-- Composite index for finding active contracts by user
CREATE INDEX IF NOT EXISTS idx_contracts_builder_active
    ON public.habit_contracts(builder_id, status)
    WHERE status IN ('active', 'pending');

CREATE INDEX IF NOT EXISTS idx_contracts_witness_active
    ON public.habit_contracts(witness_id, status)
    WHERE status = 'active' AND witness_id IS NOT NULL;

-- =============================================================================
-- RLS POLICIES FOR HABIT_CONTRACTS
-- =============================================================================

ALTER TABLE public.habit_contracts ENABLE ROW LEVEL SECURITY;

-- Builders can view their own contracts
CREATE POLICY "Builders can view own contracts"
    ON public.habit_contracts
    FOR SELECT
    USING (auth.uid() = builder_id);

-- Witnesses can view contracts they're part of
CREATE POLICY "Witnesses can view their contracts"
    ON public.habit_contracts
    FOR SELECT
    USING (auth.uid() = witness_id);

-- Anyone can view pending contracts by invite code (for join flow)
-- This enables the invite link flow where a user scans/clicks link
CREATE POLICY "Anyone can view pending contracts by invite"
    ON public.habit_contracts
    FOR SELECT
    USING (status = 'pending' AND invite_code IS NOT NULL);

-- Builders can create contracts
CREATE POLICY "Builders can create contracts"
    ON public.habit_contracts
    FOR INSERT
    WITH CHECK (auth.uid() = builder_id);

-- Builders can update their own contracts
CREATE POLICY "Builders can update own contracts"
    ON public.habit_contracts
    FOR UPDATE
    USING (auth.uid() = builder_id);

-- Witnesses can update (accept) contracts where they're the witness
-- or contracts that are pending and have no witness yet (accepting invite)
CREATE POLICY "Witnesses can accept and update contracts"
    ON public.habit_contracts
    FOR UPDATE
    USING (
        auth.uid() = witness_id
        OR (status = 'pending' AND witness_id IS NULL)
    );

-- Builders can delete their own draft/cancelled contracts
CREATE POLICY "Builders can delete own contracts"
    ON public.habit_contracts
    FOR DELETE
    USING (auth.uid() = builder_id AND status IN ('draft', 'cancelled'));

-- =============================================================================
-- CONTRACT_EVENTS TABLE (Activity Log)
-- =============================================================================

CREATE TABLE IF NOT EXISTS public.contract_events (
    id TEXT PRIMARY KEY,
    contract_id TEXT NOT NULL REFERENCES public.habit_contracts(id) ON DELETE CASCADE,

    -- Event type
    event_type TEXT NOT NULL CHECK (event_type IN (
        'created',
        'inviteSent',
        'witnessJoined',
        'started',
        'dayCompleted',
        'dayMissed',
        'nudgeSent',
        'message',
        'completed',
        'broken',
        'cancelled',
        'updated'
    )),

    -- Who triggered the event
    actor_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    actor_role TEXT CHECK (actor_role IN ('builder', 'witness', 'system')),

    -- Event data
    message TEXT,
    metadata JSONB DEFAULT '{}'::jsonb,

    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- =============================================================================
-- INDEXES FOR CONTRACT_EVENTS
-- =============================================================================

CREATE INDEX IF NOT EXISTS idx_contract_events_contract_id
    ON public.contract_events(contract_id);

CREATE INDEX IF NOT EXISTS idx_contract_events_event_type
    ON public.contract_events(event_type);

CREATE INDEX IF NOT EXISTS idx_contract_events_actor_id
    ON public.contract_events(actor_id);

CREATE INDEX IF NOT EXISTS idx_contract_events_created_at
    ON public.contract_events(created_at DESC);

-- Composite index for fetching recent events for a contract
CREATE INDEX IF NOT EXISTS idx_contract_events_contract_recent
    ON public.contract_events(contract_id, created_at DESC);

-- =============================================================================
-- RLS POLICIES FOR CONTRACT_EVENTS
-- =============================================================================

ALTER TABLE public.contract_events ENABLE ROW LEVEL SECURITY;

-- Contract parties can view events for their contracts
CREATE POLICY "Contract parties can view events"
    ON public.contract_events
    FOR SELECT
    USING (
        contract_id IN (
            SELECT id FROM public.habit_contracts
            WHERE builder_id = auth.uid() OR witness_id = auth.uid()
        )
    );

-- Contract parties can insert events for their contracts
CREATE POLICY "Contract parties can insert events"
    ON public.contract_events
    FOR INSERT
    WITH CHECK (
        contract_id IN (
            SELECT id FROM public.habit_contracts
            WHERE builder_id = auth.uid() OR witness_id = auth.uid()
        )
    );

-- =============================================================================
-- UPDATED_AT TRIGGER
-- =============================================================================

-- Function to auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for habit_contracts
DROP TRIGGER IF EXISTS update_habit_contracts_updated_at ON public.habit_contracts;
CREATE TRIGGER update_habit_contracts_updated_at
    BEFORE UPDATE ON public.habit_contracts
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

-- =============================================================================
-- ENABLE REALTIME (optional, for live updates)
-- =============================================================================

-- Enable realtime for habit_contracts
-- This allows the app to receive live updates when contracts change
ALTER PUBLICATION supabase_realtime ADD TABLE public.habit_contracts;

-- Enable realtime for contract_events
ALTER PUBLICATION supabase_realtime ADD TABLE public.contract_events;

-- =============================================================================
-- COMMENTS
-- =============================================================================

COMMENT ON TABLE public.habit_contracts IS
    'Phase 16.2: Accountability contracts between Builders and Witnesses';

COMMENT ON TABLE public.contract_events IS
    'Phase 16.2: Activity log for contract events (nudges, completions, messages)';

COMMENT ON COLUMN public.habit_contracts.invite_code IS
    'Unique 8-character alphanumeric code for invite links (e.g., ABC12345)';

COMMENT ON COLUMN public.habit_contracts.status IS
    'Lifecycle: draft -> pending -> active -> completed/broken/cancelled';

COMMENT ON COLUMN public.habit_contracts.nudge_history IS
    'Phase 61: JSON map of witness_id -> list of nudge timestamps for rate limiting';

COMMENT ON COLUMN public.habit_contracts.blocked_witness_ids IS
    'Phase 61: Array of user IDs blocked by this contract owner';

COMMENT ON COLUMN public.habit_contracts.allow_emergency_exit IS
    'Phase 61: Safety flag allowing immediate contract dissolution';

COMMENT ON COLUMN public.habit_contracts.is_under_review IS
    'Phase 61: Admin flag for contracts flagged for abuse review';

COMMENT ON COLUMN public.habit_contracts.last_nudge_sent_at IS
    'Phase 21.3: Timestamp of last nudge sent by witness';

COMMENT ON COLUMN public.habit_contracts.nudges_responded_count IS
    'Phase 21.3: Count of nudges that led to habit completion (effectiveness tracking)';
