-- Population Learning Schema
-- Stores aggregated Beta parameters for Thompson Sampling priors
-- Privacy-preserving: Only stores (alpha, beta) counts, no user identifiers

-- Create archetype_priors table
CREATE TABLE IF NOT EXISTS archetype_priors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    archetype TEXT NOT NULL,
    arm_id TEXT NOT NULL,
    alpha DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    beta DOUBLE PRECISION NOT NULL DEFAULT 1.0,
    sample_count INTEGER NOT NULL DEFAULT 0,
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT now(),

    -- Unique constraint on archetype + arm combination
    CONSTRAINT unique_archetype_arm UNIQUE (archetype, arm_id)
);

-- Create indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_archetype_priors_archetype ON archetype_priors(archetype);
CREATE INDEX IF NOT EXISTS idx_archetype_priors_arm ON archetype_priors(arm_id);
-- Composite index for the common query pattern (archetype + arm_id lookup)
CREATE INDEX IF NOT EXISTS idx_archetype_priors_composite ON archetype_priors(archetype, arm_id);

-- Create contribution_log for rate limiting and privacy
-- Stores hashed user IDs to prevent duplicate contributions
-- Rate limit is per user+archetype (not per arm) to prevent gaming
CREATE TABLE IF NOT EXISTS contribution_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_hash TEXT NOT NULL,
    archetype TEXT NOT NULL,
    arm_id TEXT NOT NULL DEFAULT '_session_', -- Session marker for archetype-level rate limiting
    contributed_at TIMESTAMP WITH TIME ZONE DEFAULT now(),

    -- Prevent duplicate contribution sessions within 24 hours (per user+archetype)
    CONSTRAINT unique_contribution_session_24h UNIQUE (user_hash, archetype)
);

-- Create index for cleanup
CREATE INDEX IF NOT EXISTS idx_contribution_log_time ON contribution_log(contributed_at);

-- RLS Policies
ALTER TABLE archetype_priors ENABLE ROW LEVEL SECURITY;
ALTER TABLE contribution_log ENABLE ROW LEVEL SECURITY;

-- Allow anonymous read access to priors (public knowledge)
CREATE POLICY "Allow anonymous read" ON archetype_priors
    FOR SELECT
    USING (true);

-- Only Edge Functions can insert/update priors
CREATE POLICY "Only service role can modify" ON archetype_priors
    FOR ALL
    USING (auth.role() = 'service_role');

-- Only Edge Functions can access contribution log
CREATE POLICY "Only service role can access logs" ON contribution_log
    FOR ALL
    USING (auth.role() = 'service_role');

-- Function to clean old contribution logs (24h TTL)
CREATE OR REPLACE FUNCTION clean_old_contributions()
RETURNS void AS $$
BEGIN
    DELETE FROM contribution_log
    WHERE contributed_at < now() - INTERVAL '24 hours';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Insert default priors based on research (from population_learning.dart)
INSERT INTO archetype_priors (archetype, arm_id, alpha, beta) VALUES
    -- REBEL archetype
    ('REBEL', 'SHADOW_AUTONOMY', 8.0, 2.0),
    ('REBEL', 'SILENCE_TRUST', 7.0, 3.0),
    ('REBEL', 'ACT_STREAK', 4.0, 6.0),
    ('REBEL', 'ACT_IDENTITY', 5.0, 5.0),

    -- PERFECTIONIST archetype
    ('PERFECTIONIST', 'FRICTION_TINY', 9.0, 1.0),
    ('PERFECTIONIST', 'COG_ZOOM', 8.0, 2.0),
    ('PERFECTIONIST', 'ACT_TIMER', 3.0, 7.0),
    ('PERFECTIONIST', 'SHADOW_AUTONOMY', 4.0, 6.0),

    -- PROCRASTINATOR archetype
    ('PROCRASTINATOR', 'FRICTION_TINY', 8.0, 2.0),
    ('PROCRASTINATOR', 'ACT_TIMER', 7.0, 3.0),
    ('PROCRASTINATOR', 'ACT_STREAK', 6.0, 4.0),
    ('PROCRASTINATOR', 'SILENCE_TRUST', 3.0, 7.0),

    -- OVERTHINKER archetype
    ('OVERTHINKER', 'SILENCE_TRUST', 8.0, 2.0),
    ('OVERTHINKER', 'COG_ZOOM', 7.0, 3.0),
    ('OVERTHINKER', 'FRICTION_TINY', 6.0, 4.0),
    ('OVERTHINKER', 'ACT_IDENTITY', 5.0, 5.0),

    -- PLEASURE_SEEKER archetype
    ('PLEASURE_SEEKER', 'FRICTION_BUNDLE', 8.0, 2.0),
    ('PLEASURE_SEEKER', 'ACT_STREAK', 7.0, 3.0),
    ('PLEASURE_SEEKER', 'FRICTION_TINY', 5.0, 5.0),
    ('PLEASURE_SEEKER', 'SHADOW_AUTONOMY', 4.0, 6.0),

    -- PEOPLE_PLEASER archetype
    ('PEOPLE_PLEASER', 'SOC_WITNESS', 8.0, 2.0),
    ('PEOPLE_PLEASER', 'SOC_CONTRACT', 7.0, 3.0),
    ('PEOPLE_PLEASER', 'ACT_IDENTITY', 6.0, 4.0),
    ('PEOPLE_PLEASER', 'SILENCE_TRUST', 5.0, 5.0)
ON CONFLICT (archetype, arm_id) DO NOTHING;

-- Comment on tables
COMMENT ON TABLE archetype_priors IS 'Aggregated Thompson Sampling priors for each archetype-arm combination. Privacy-preserving: only stores (alpha, beta) counts.';
COMMENT ON TABLE contribution_log IS 'Rate-limiting log for population learning contributions. Stores hashed user IDs.';
