-- Create lexicon_entries table
create table lexicon_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references auth.users not null,
  word text not null,
  definition text,
  etymology text,
  identity_tag text, -- e.g., 'Stoic', 'Builder', 'Athlete'
  mastery_level int default 0, -- 0=New, 1=Seen, 3=Used, 5=Mastered
  last_practiced_at timestamptz,
  created_at timestamptz default now()
);

-- Enable RLS
alter table lexicon_entries enable row level security;

-- RLS Policies

-- Users can view their own lexicon
create policy "Users can view their own lexicon" on lexicon_entries
  for select using (auth.uid() = user_id);

-- Users can insert into their own lexicon
create policy "Users can insert into their own lexicon" on lexicon_entries
  for insert with check (auth.uid() = user_id);

-- Users can update their own lexicon
create policy "Users can update their own lexicon" on lexicon_entries
  for update using (auth.uid() = user_id);

-- Users can delete from their own lexicon
create policy "Users can delete from their own lexicon" on lexicon_entries
  for delete using (auth.uid() = user_id);

-- Witnesses can view friend's lexicon (Social Feature)
-- Assumes a 'contracts' table exists with owner_id and witness_id
create policy "Witnesses can view friend's lexicon" on lexicon_entries
  for select using (
    exists (
      select 1 from habit_contracts
      where (builder_id = lexicon_entries.user_id and witness_id = auth.uid())
      or (witness_id = lexicon_entries.user_id and builder_id = auth.uid())
    )
  );
