# Supabase Database Schema

> **Phase 16.2 + 16.4: Habit Contracts & Deep Links**
> **Last Updated:** December 2025 (v4.13.0)

This document defines the Supabase database schema for the Atomic Habits Hook App cloud sync feature.

## Overview

The schema supports:
- User identity and authentication
- Habit data backup and sync
- Completion history tracking
- **Habit Contracts** (Phase 16.2) - Accountability partnerships
- **Deep Links** (Phase 16.4) - Viral invite mechanism

## Tables

### users

Primary user identity table.

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE,
  username TEXT UNIQUE,
  tier TEXT DEFAULT 'free' CHECK (tier IN ('free', 'builder', 'pro')),
  avatar_url TEXT,
  display_name TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active_at TIMESTAMPTZ,
  
  -- Metadata
  app_version TEXT,
  platform TEXT,  -- 'ios', 'android', 'web'
  
  -- Settings (optional cloud backup)
  settings JSONB DEFAULT '{}'::jsonb
);

-- RLS Policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON users FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON users FOR INSERT
  WITH CHECK (auth.uid() = id);
```

### habits

Habit data with cloud backup support.

```sql
CREATE TABLE habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Core habit data
  name TEXT NOT NULL,
  identity TEXT,
  tiny_version TEXT,
  implementation_intention TEXT,
  scheduled_time TEXT,  -- HH:MM format
  
  -- Habit type
  is_break_habit BOOLEAN DEFAULT FALSE,
  
  -- Visual
  habit_emoji TEXT,
  
  -- Motivation
  motivation TEXT,
  recovery_plan TEXT,
  
  -- Stacking
  anchor_habit_id UUID REFERENCES habits(id),
  anchor_event TEXT,
  stack_position TEXT DEFAULT 'after' CHECK (stack_position IN ('before', 'after')),
  
  -- Break habit specific
  replaces_habit TEXT,
  root_cause TEXT,
  substitution_plan TEXT,
  
  -- Advanced
  temptation_bundle TEXT,
  environment_cues TEXT,
  distraction_guardrails TEXT,
  
  -- State
  is_active BOOLEAN DEFAULT TRUE,
  is_paused BOOLEAN DEFAULT FALSE,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  deleted_at TIMESTAMPTZ,
  
  -- Backup data (JSON for complete local state)
  completion_history JSONB DEFAULT '[]'::jsonb,
  recovery_history JSONB DEFAULT '[]'::jsonb,
  miss_history JSONB DEFAULT '[]'::jsonb
);

-- Indexes
CREATE INDEX idx_habits_user_id ON habits(user_id);
CREATE INDEX idx_habits_anchor ON habits(anchor_habit_id);
CREATE INDEX idx_habits_active ON habits(user_id, is_active);

-- RLS Policies
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own habits"
  ON habits FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits"
  ON habits FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits"
  ON habits FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits"
  ON habits FOR DELETE
  USING (auth.uid() = user_id);
```

### habit_completions

Individual completion records for detailed analytics.

```sql
CREATE TABLE habit_completions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  
  -- Completion data
  completion_date DATE NOT NULL,
  is_recovery BOOLEAN DEFAULT FALSE,
  used_tiny_version BOOLEAN DEFAULT FALSE,
  
  -- Optional context
  notes TEXT,
  mood_score INTEGER CHECK (mood_score >= 1 AND mood_score <= 5),
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Prevent duplicate completions
  UNIQUE(habit_id, completion_date)
);

-- Indexes
CREATE INDEX idx_completions_habit ON habit_completions(habit_id);
CREATE INDEX idx_completions_user ON habit_completions(user_id);
CREATE INDEX idx_completions_date ON habit_completions(completion_date DESC);

-- RLS Policies
ALTER TABLE habit_completions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own completions"
  ON habit_completions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own completions"
  ON habit_completions FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

### habit_contracts (Phase 16.2 - LIVE)

Accountability partnerships between Builders and Witnesses.

```sql
CREATE TABLE habit_contracts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Parties
  builder_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
  witness_id UUID REFERENCES users(id) ON DELETE SET NULL,  -- NULL until witness joins
  habit_id UUID REFERENCES habits(id) ON DELETE CASCADE NOT NULL,
  
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
CREATE INDEX idx_contracts_builder ON habit_contracts(builder_id);
CREATE INDEX idx_contracts_witness ON habit_contracts(witness_id);
CREATE INDEX idx_contracts_habit ON habit_contracts(habit_id);
CREATE INDEX idx_contracts_invite_code ON habit_contracts(invite_code);
CREATE INDEX idx_contracts_status ON habit_contracts(status);

-- RLS Policies
ALTER TABLE habit_contracts ENABLE ROW LEVEL SECURITY;

-- Builders can view and manage their own contracts
CREATE POLICY "Builders can view own contracts"
  ON habit_contracts FOR SELECT
  USING (auth.uid() = builder_id);

CREATE POLICY "Builders can insert own contracts"
  ON habit_contracts FOR INSERT
  WITH CHECK (auth.uid() = builder_id);

CREATE POLICY "Builders can update own contracts"
  ON habit_contracts FOR UPDATE
  USING (auth.uid() = builder_id);

-- Witnesses can view contracts they're part of
CREATE POLICY "Witnesses can view their contracts"
  ON habit_contracts FOR SELECT
  USING (auth.uid() = witness_id);

-- Witnesses can update (accept) contracts they're invited to
CREATE POLICY "Witnesses can accept contracts"
  ON habit_contracts FOR UPDATE
  USING (auth.uid() = witness_id OR witness_id IS NULL);

-- Anyone can view pending contracts by invite code (for join flow)
CREATE POLICY "Anyone can view pending contracts by invite"
  ON habit_contracts FOR SELECT
  USING (status = 'pending' AND invite_code IS NOT NULL);
```

### contract_events (Phase 16.2 - LIVE)

Activity log for contracts (nudges, completions, messages).

```sql
CREATE TABLE contract_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id UUID REFERENCES habit_contracts(id) ON DELETE CASCADE NOT NULL,
  
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
  actor_id UUID REFERENCES users(id),
  actor_role TEXT CHECK (actor_role IN ('builder', 'witness', 'system')),
  
  -- Event data
  message TEXT,
  metadata JSONB DEFAULT '{}'::jsonb,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_events_contract ON contract_events(contract_id);
CREATE INDEX idx_events_type ON contract_events(event_type);
CREATE INDEX idx_events_created ON contract_events(created_at DESC);

-- RLS Policies
ALTER TABLE contract_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Contract parties can view events"
  ON contract_events FOR SELECT
  USING (
    contract_id IN (
      SELECT id FROM habit_contracts 
      WHERE builder_id = auth.uid() OR witness_id = auth.uid()
    )
  );

CREATE POLICY "Contract parties can insert events"
  ON contract_events FOR INSERT
  WITH CHECK (
    contract_id IN (
      SELECT id FROM habit_contracts 
      WHERE builder_id = auth.uid() OR witness_id = auth.uid()
    )
  );
```

## Future Tables (Phase 16.3+)

### witness_relationships (Phase 16.3)

Extended witness dashboard data (deferred - contracts work without this).

```sql
-- To be implemented in Phase 16.3
CREATE TABLE witness_relationships (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  witness_id UUID REFERENCES users(id) NOT NULL,
  builder_id UUID REFERENCES users(id) NOT NULL,
  contract_id UUID REFERENCES habit_contracts(id),
  
  -- Relationship status
  status TEXT DEFAULT 'active',
  
  -- Permissions
  can_view_history BOOLEAN DEFAULT TRUE,
  can_send_nudges BOOLEAN DEFAULT TRUE,
  
  -- Timestamps
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Setup Instructions

### 1. Create Supabase Project

1. Go to https://supabase.com
2. Create a new project
3. Note your project URL and anon key

### 2. Run Schema Migrations

Copy the SQL from each table section above and run in the Supabase SQL Editor.

### 3. Configure Flutter App

Add to your build command:
```bash
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Or set environment variables:
```bash
export SUPABASE_URL=https://your-project.supabase.co
export SUPABASE_ANON_KEY=your-anon-key
```

### 4. Enable Auth Providers

In Supabase Dashboard > Authentication > Providers:
- Enable Anonymous sign-ins (for friction-free onboarding)
- Enable Email (for account upgrades)
- Enable Google (for OAuth upgrades)

### 5. Configure Deep Links (for OAuth)

For Google Sign-In, configure:
- Android: Add `io.supabase.atomichabits` URL scheme
- iOS: Add URL scheme to Info.plist

## Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                      Local (Hive)                            │
│   Habits, Completions, Settings stored locally first        │
└─────────────────────────────────────────────────────────────┘
                         │
                         │ SyncService (on events)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                    Cloud (Supabase)                          │
│   Backup of habits, completions for multi-device sync       │
│   Future: Real-time sync, contracts, witnesses              │
└─────────────────────────────────────────────────────────────┘
```

## Security Notes

1. **RLS Enabled**: All tables have Row Level Security
2. **User Isolation**: Users can only access their own data
3. **Anon Key Safe**: Public key is safe to expose (RLS protects data)
4. **Service Key Never**: Never expose service role key in client apps

## Tier System

| Tier | Price | Features |
|------|-------|----------|
| Free | $0 | Witness mode, view builder progress |
| Builder | $X/mo | Single habit, basic AI coaching |
| Pro | $Y/mo | Unlimited stacks, AI voice, priority support |

## Deep Links Configuration (Phase 16.4)

### URL Structure

```
Production:  https://atomichabits.app/invite?c={invite_code}
Development: atomichabits://invite?c={invite_code}
```

### Android Setup (AndroidManifest.xml)

```xml
<!-- Deep Links for contract invites -->
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <!-- Production domain -->
    <data android:scheme="https" android:host="atomichabits.app" android:pathPrefix="/invite" />
</intent-filter>

<!-- Custom scheme fallback -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="atomichabits" android:host="invite" />
</intent-filter>
```

### iOS Setup (Info.plist)

```xml
<!-- Universal Links -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>atomichabits</string>
        </array>
    </dict>
</array>

<!-- Associated Domains (for Universal Links) -->
<key>com.apple.developer.associated-domains</key>
<array>
    <string>applinks:atomichabits.app</string>
</array>
```

### Invite Code Generation

```dart
// Generate 8-character alphanumeric code
String generateInviteCode() {
  const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // Avoid ambiguous: I,O,0,1
  final random = Random.secure();
  return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
}
```

---

*Schema version: 2.0.0*
*Last updated: December 2025 (Phase 16.2 + 16.4)*
