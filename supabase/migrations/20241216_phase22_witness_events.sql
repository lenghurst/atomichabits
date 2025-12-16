-- Phase 22: "The Witness" - Social Accountability Loop
-- 
-- This migration creates the witness_events table for real-time
-- accountability notifications between builders and witnesses.
--
-- Event Types:
-- - habit_completed: Builder completes habit -> Witness gets notified
-- - streak_milestone: Streak milestone achieved (7, 21, 30 days)
-- - high_five_received: Witness sends emoji reaction -> Builder gets dopamine
-- - nudge_received: Witness sends encouragement to Builder
-- - drift_warning: System warns Witness that Builder is about to miss
-- - witness_joined: Witness accepts contract invitation
-- - contract_accepted: Contract becomes active
-- - streak_broken: Builder's streak was broken
-- - contract_completed: Contract finished successfully
-- - contract_broken: Contract failed

-- Create witness_events table
CREATE TABLE IF NOT EXISTS public.witness_events (
    id TEXT PRIMARY KEY,
    contract_id TEXT NOT NULL REFERENCES public.habit_contracts(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    actor_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    target_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    habit_id TEXT,
    habit_name TEXT,
    identity TEXT,
    message TEXT,
    reaction JSONB,
    metadata JSONB,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL
);

-- Indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_witness_events_contract_id 
    ON public.witness_events(contract_id);

CREATE INDEX IF NOT EXISTS idx_witness_events_target_id 
    ON public.witness_events(target_id);

CREATE INDEX IF NOT EXISTS idx_witness_events_created_at 
    ON public.witness_events(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_witness_events_target_unread 
    ON public.witness_events(target_id, is_read) 
    WHERE is_read = FALSE;

-- Enable Row Level Security
ALTER TABLE public.witness_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users can read events where they are the target
CREATE POLICY "Users can read their own events"
    ON public.witness_events
    FOR SELECT
    USING (auth.uid() = target_id);

-- Users can read events they created
CREATE POLICY "Users can read events they created"
    ON public.witness_events
    FOR SELECT
    USING (auth.uid() = actor_id);

-- Users can create events for contracts they're part of
CREATE POLICY "Users can create events for their contracts"
    ON public.witness_events
    FOR INSERT
    WITH CHECK (
        auth.uid() = actor_id
        AND EXISTS (
            SELECT 1 FROM public.habit_contracts
            WHERE id = contract_id
            AND (builder_id = auth.uid() OR witness_id = auth.uid())
        )
    );

-- Users can update events they are the target of (mark as read)
CREATE POLICY "Users can update their own events"
    ON public.witness_events
    FOR UPDATE
    USING (auth.uid() = target_id)
    WITH CHECK (auth.uid() = target_id);

-- Enable Realtime for witness_events
-- This allows instant push notifications when events are created
ALTER PUBLICATION supabase_realtime ADD TABLE public.witness_events;

-- Comment on table
COMMENT ON TABLE public.witness_events IS 
    'Phase 22: Real-time witness events for social accountability notifications';

-- Comment on columns
COMMENT ON COLUMN public.witness_events.event_type IS 
    'Type of event: habit_completed, high_five_received, nudge_received, drift_warning, etc.';
COMMENT ON COLUMN public.witness_events.actor_id IS 
    'User who triggered/created the event';
COMMENT ON COLUMN public.witness_events.target_id IS 
    'User who should receive the notification';
COMMENT ON COLUMN public.witness_events.reaction IS 
    'JSON object containing emoji reaction data';
COMMENT ON COLUMN public.witness_events.metadata IS 
    'Additional event-specific data (streak count, milestone info, etc.)';
