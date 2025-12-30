-- Phase 2: Storage Infrastructure
-- Fixes: PostgrestException for missing public.profiles
-- Adds: Full conversation history storage with all required fields

-- =======================
-- 1. PUBLIC.PROFILES TABLE
-- =======================
-- Fixes the app startup crash

CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  display_name TEXT,
  
  -- User tier for AI features
  tier TEXT DEFAULT 'free' CHECK (tier IN ('free', 'premium', 'pro')),
  
  -- Subscription
  subscription_status TEXT,
  subscription_end_date TIMESTAMPTZ,
  
  -- Preferences
  store_transcripts BOOLEAN DEFAULT true,
  store_audio_locally BOOLEAN DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_seen_at TIMESTAMPTZ,
  
  -- Psychometric profile (JSON for flexibility)
  psychometric_profile JSONB DEFAULT '{}'::jsonb
);

-- Indexes for profiles
CREATE INDEX IF NOT EXISTS idx_profiles_username ON public.profiles(username);
CREATE INDEX IF NOT EXISTS idx_profiles_tier ON public.profiles(tier);

-- RLS for profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON public.profiles FOR UPDATE
  USING (auth.uid() = id);

-- Trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- =======================
-- 2. CONVERSATIONS TABLE
-- =======================
-- Groups related voice exchanges

CREATE TABLE IF NOT EXISTS public.conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  habit_id UUID REFERENCES public.habits(id) ON DELETE SET NULL,
  
  -- Metadata
  started_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  ended_at TIMESTAMPTZ,
  turn_count INTEGER DEFAULT 0,  -- ✅ REQUIRED by ConversationRepository
  
  -- Context
  session_type TEXT CHECK (session_type IN ('coaching', 'checkin', 'reflection', 'break_habit', 'onboarding')),
  trigger_event TEXT,
  
  -- Status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned'))
);

-- Indexes for conversations
CREATE INDEX IF NOT EXISTS idx_conversations_user_id ON public.conversations(user_id);
CREATE INDEX IF NOT EXISTS idx_conversations_started_at ON public.conversations(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_conversations_habit_id ON public.conversations(habit_id) WHERE habit_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_conversations_status ON public.conversations(status);

-- RLS for conversations
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own conversations"
  ON public.conversations FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own conversations"
  ON public.conversations FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own conversations"
  ON public.conversations FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own conversations"
  ON public.conversations FOR DELETE
  USING (auth.uid() = user_id);

-- =======================
-- 3. CONVERSATION_TURNS TABLE
-- =======================
-- Individual exchanges (user + AI response)
-- TEXT ONLY - audio files stay on device

CREATE TABLE IF NOT EXISTS public.conversation_turns (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Content (TEXT ONLY - audio stays local)
  user_transcript TEXT NOT NULL,  -- ✅ REQUIRED
  ai_response TEXT NOT NULL,      -- ✅ REQUIRED
  
  -- Local audio references (device file paths, NOT cloud URLs)
  local_user_audio_path TEXT,    -- ✅ REQUIRED
  local_ai_audio_path TEXT,      -- ✅ REQUIRED
  
  -- Audio metadata (stored but files are local)
  user_audio_duration_ms INTEGER,
  ai_audio_duration_ms INTEGER,
  
  -- Turn metadata
  turn_number INTEGER NOT NULL,  -- ✅ REQUIRED
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  
  -- AI metadata (for debugging/analytics)
  model_transcription TEXT NOT NULL,  -- ✅ REQUIRED
  model_reasoning TEXT NOT NULL,      -- ✅ REQUIRED
  model_tts TEXT
);

-- Indexes for conversation_turns
CREATE INDEX IF NOT EXISTS idx_turns_conversation_id ON public.conversation_turns(conversation_id);
CREATE INDEX IF NOT EXISTS idx_turns_user_id ON public.conversation_turns(user_id);
CREATE INDEX IF NOT EXISTS idx_turns_created_at ON public.conversation_turns(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_turns_turn_number ON public.conversation_turns(conversation_id, turn_number);

-- Full-text search indexes
CREATE INDEX IF NOT EXISTS idx_turns_user_transcript_search 
  ON public.conversation_turns 
  USING gin(to_tsvector('english', user_transcript));

CREATE INDEX IF NOT EXISTS idx_turns_ai_response_search 
  ON public.conversation_turns 
  USING gin(to_tsvector('english', ai_response));

-- RLS for conversation_turns
ALTER TABLE public.conversation_turns ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own turns"
  ON public.conversation_turns FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own turns"
  ON public.conversation_turns FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own turns"
  ON public.conversation_turns FOR DELETE
  USING (auth.uid() = user_id);

-- =======================
-- 4. HELPER FUNCTIONS
-- =======================

-- Function to search transcripts (full-text search)
CREATE OR REPLACE FUNCTION search_transcripts(
  p_user_id UUID,
  p_query TEXT,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  id UUID,
  conversation_id UUID,
  user_transcript TEXT,
  ai_response TEXT,
  created_at TIMESTAMPTZ,
  turn_number INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    t.id,
    t.conversation_id,
    t.user_transcript,
    t.ai_response,
    t.created_at,
    t.turn_number
  FROM public.conversation_turns t
  WHERE t.user_id = p_user_id
    AND (
      to_tsvector('english', t.user_transcript) @@ plainto_tsquery('english', p_query)
      OR to_tsvector('english', t.ai_response) @@ plainto_tsquery('english', p_query)
    )
  ORDER BY t.created_at DESC
  LIMIT p_limit;
END;
$$;

-- =======================
-- 5. AUTO-CREATE PROFILE TRIGGER
-- =======================

-- Function to automatically create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, username, tier)
  VALUES (
    NEW.id, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email),
    'free'
  )
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =======================
-- 6. BACKFILL EXISTING USERS
-- =======================

-- Create profiles for any existing users
INSERT INTO public.profiles (id, tier, created_at)
SELECT 
  id, 
  'free' as tier,
  created_at
FROM auth.users
ON CONFLICT (id) DO NOTHING;

-- =======================
-- 7. COMMENTS
-- =======================

COMMENT ON TABLE public.profiles IS 'User profiles and preferences';
COMMENT ON TABLE public.conversations IS 'Voice coaching conversation sessions';
COMMENT ON TABLE public.conversation_turns IS 'Individual exchanges within conversations (text only, audio files stored locally)';
COMMENT ON COLUMN public.conversation_turns.local_user_audio_path IS 'Device file path, not cloud URL';
COMMENT ON COLUMN public.conversation_turns.local_ai_audio_path IS 'Device file path, not cloud URL';
COMMENT ON COLUMN public.conversations.turn_count IS 'Cached count of turns for efficient pagination';
