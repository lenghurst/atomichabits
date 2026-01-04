-- 20260105_vector_memory.sql
-- Vector Memory Layer: RAG for Persona Intelligence
--
-- This migration enables semantic search over user behavioral data,
-- allowing AI personas (Sherlock, Oracle, Stoic) to recall relevant
-- past events when coaching the user.

-- =======================
-- 1. ENABLE VECTOR EXTENSION
-- =======================

CREATE EXTENSION IF NOT EXISTS vector;

-- =======================
-- 2. ADD EMBEDDING COLUMNS
-- =======================

-- Add to evidence_logs (behavioral signals)
ALTER TABLE public.evidence_logs
ADD COLUMN IF NOT EXISTS embedding vector(768);

-- Add to conversation_turns (past dialogues)
ALTER TABLE public.conversation_turns
ADD COLUMN IF NOT EXISTS embedding vector(768);

-- Add searchable text column to evidence_logs (derived from payload)
-- This makes searching more efficient than parsing JSONB every time
ALTER TABLE public.evidence_logs
ADD COLUMN IF NOT EXISTS searchable_text TEXT;

-- =======================
-- 3. CREATE INDEXES FOR FAST SIMILARITY SEARCH
-- =======================

-- IVFFlat index for evidence_logs
-- Note: Run AFTER you have some data, or use HNSW for small datasets
CREATE INDEX IF NOT EXISTS idx_evidence_embedding
ON public.evidence_logs
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- IVFFlat index for conversation_turns
CREATE INDEX IF NOT EXISTS idx_turns_embedding
ON public.conversation_turns
USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);

-- Text index for fallback keyword search
CREATE INDEX IF NOT EXISTS idx_evidence_searchable_text
ON public.evidence_logs
USING gin(to_tsvector('english', searchable_text));

-- =======================
-- 4. UNIFIED MEMORY SEARCH FUNCTION
-- =======================

-- Single function to search all memory sources
-- Returns combined results from evidence_logs and conversation_turns
CREATE OR REPLACE FUNCTION search_memory(
  p_user_id UUID,
  p_query_embedding vector(768),
  p_match_threshold FLOAT DEFAULT 0.65,
  p_match_count INT DEFAULT 10
)
RETURNS TABLE (
  id UUID,
  source TEXT,
  content TEXT,
  occurred_at TIMESTAMPTZ,
  similarity FLOAT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  (
    -- Search evidence logs
    SELECT
      e.id,
      'evidence'::TEXT AS source,
      COALESCE(e.searchable_text, e.event_type || ': ' || e.payload::text) AS content,
      e.occurred_at,
      1 - (e.embedding <=> p_query_embedding) AS similarity
    FROM public.evidence_logs e
    WHERE e.user_id = p_user_id
      AND e.embedding IS NOT NULL
      AND 1 - (e.embedding <=> p_query_embedding) > p_match_threshold
  )
  UNION ALL
  (
    -- Search conversation turns
    SELECT
      t.id,
      'conversation'::TEXT AS source,
      'You said: "' || LEFT(t.user_transcript, 200) || '" → AI: "' || LEFT(t.ai_response, 200) || '"' AS content,
      t.created_at AS occurred_at,
      1 - (t.embedding <=> p_query_embedding) AS similarity
    FROM public.conversation_turns t
    WHERE t.user_id = p_user_id
      AND t.embedding IS NOT NULL
      AND 1 - (t.embedding <=> p_query_embedding) > p_match_threshold
  )
  ORDER BY similarity DESC
  LIMIT p_match_count;
END;
$$;

-- =======================
-- 5. HELPER: GENERATE SEARCHABLE TEXT FROM PAYLOAD
-- =======================

-- Trigger function to auto-generate searchable_text from payload
CREATE OR REPLACE FUNCTION generate_searchable_text()
RETURNS TRIGGER AS $$
BEGIN
  -- Extract meaningful text from the JSONB payload
  NEW.searchable_text := NEW.event_type || ': ' ||
    COALESCE(NEW.payload->>'habit_id', '') || ' ' ||
    COALESCE(NEW.payload->>'emotion', '') || ' ' ||
    COALESCE(NEW.payload->>'app_name', '') || ' ' ||
    COALESCE(NEW.payload->>'completed_at', '') || ' ' ||
    COALESCE(NEW.payload::text, '');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Attach trigger to evidence_logs
DROP TRIGGER IF EXISTS trigger_generate_searchable_text ON public.evidence_logs;
CREATE TRIGGER trigger_generate_searchable_text
  BEFORE INSERT OR UPDATE ON public.evidence_logs
  FOR EACH ROW
  EXECUTE FUNCTION generate_searchable_text();

-- =======================
-- 6. BACKFILL SEARCHABLE TEXT FOR EXISTING DATA
-- =======================

UPDATE public.evidence_logs
SET searchable_text = event_type || ': ' ||
  COALESCE(payload->>'habit_id', '') || ' ' ||
  COALESCE(payload->>'emotion', '') || ' ' ||
  COALESCE(payload->>'app_name', '') || ' ' ||
  COALESCE(payload->>'completed_at', '') || ' ' ||
  COALESCE(payload::text, '')
WHERE searchable_text IS NULL;

-- =======================
-- 7. COMMENTS
-- =======================

COMMENT ON COLUMN public.evidence_logs.embedding IS 'Gemini text-embedding-004 vector (768 dimensions)';
COMMENT ON COLUMN public.evidence_logs.searchable_text IS 'Flattened text for embedding and fallback search';
COMMENT ON COLUMN public.conversation_turns.embedding IS 'Gemini text-embedding-004 vector (768 dimensions)';
COMMENT ON FUNCTION search_memory IS 'RAG: Unified semantic search across all memory sources';
