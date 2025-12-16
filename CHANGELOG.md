# Changelog

All notable changes to the Atomic Habits Hook App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [5.7.0] - 2024-12-16

### Added - Phase 22: "The Witness" - Social Accountability Loop

This release transforms the app from a **Single Player Tool** to a **Multiplayer Network**.

#### The Core Loop
1. **Builder** completes habit
2. **Witness** gets instant notification: "User just cast a vote for [Identity]!"
3. **Witness** sends High Five (emoji reaction)
4. **Builder** gets SECOND dopamine hit (social validation)
5. **If drifting**: Witness can send preemptive nudge before failure

#### New Features
- **WitnessService**: Real-time accountability relationship management
  - Supabase Realtime subscriptions for instant notifications
  - Completion pings to all active witnesses
  - Streak milestone celebrations (7, 21, 30 days)
  
- **WitnessEvent Model**: Comprehensive event system
  - `habitCompleted`: Builder completes -> Witness notified
  - `highFiveReceived`: Witness reacts -> Builder dopamine hit
  - `nudgeReceived`: Witness sends encouragement
  - `driftWarning`: Pre-failure intervention system
  - `streakMilestone`: Celebration notifications

- **High Five System**: Quick emoji reactions
  - 6 pre-defined reactions (fire, high-five, flex, etc.)
  - Custom message support
  - Celebratory animation on receipt

- **Witness Dashboard**: Central hub for accountability
  - "My Witnesses" tab (people watching me)
  - "I Witness" tab (people I'm watching)
  - Activity feed with all recent events

- **Deep Link Integration**: Seamless invite flow
  - `atomichabits.app/witness/accept/:code`
  - In-app acceptance screen with contract details
  - Auth-required flow for witnesses

- **Enhanced Notifications**: Witness-specific channels
  - Completion notifications to witnesses
  - High-five received celebrations
  - Drift warning alerts
  - Nudge received prompts

#### Database
- New `witness_events` table with RLS policies
- Realtime enabled for instant push notifications
- Efficient indexes for read performance

#### Architecture
- Integration with existing ContractService
- Extension of NotificationService for witness channels
- Provider setup for WitnessService

### Philosophy
> "Social features are the best way to test if your Viral Engine actually works. 
> Monetization is easier to add once you have retention; Social creates retention."

---

## [5.5.0] - Previous Release

### Phase 21: The Viral Engine (Deep Links)
- Universal Links and App Links infrastructure
- Contract invite URLs
- Niche landing pages for side door acquisition

### Phase 20: Destroyer Defense (Feedback System)
- Bug report system
- Feature request collection
- App review prompts

### Phase 19: The Intelligent Nudge
- Pattern detection for drift analysis
- Optimized notification timing
- Context-aware nudge copywriting

### Phase 18: The Pulse (Sound & Haptics)
- "The Clunk" completion sound
- Haptic feedback system
- Sound service with volume control

### Earlier Phases
See commit history for Phases 1-17.
