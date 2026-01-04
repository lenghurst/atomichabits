-- 20260104_evidence_logs.sql
-- Evidence Foundation: Logging behavioral signals

CREATE TABLE public.evidence_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    event_type TEXT NOT NULL,
    payload JSONB DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for performance
CREATE INDEX idx_evidence_user ON public.evidence_logs(user_id);
CREATE INDEX idx_evidence_type ON public.evidence_logs(event_type);
CREATE INDEX idx_evidence_time ON public.evidence_logs(occurred_at DESC);

-- RLS Policies
ALTER TABLE public.evidence_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can insert their own logs"
    ON public.evidence_logs
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own logs"
    ON public.evidence_logs
    FOR SELECT
    USING (auth.uid() = user_id);
