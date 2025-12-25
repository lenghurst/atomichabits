# Sprint 24: "The Red Carpet" - Viral Engine Optimization

> **Version:** 1.0.0
> **Last Updated:** December 2025
> **Status:** In Progress
> **Prerequisite:** Phase 22 "The Witness" (v5.7.0-RC1) merged to main

---

## Executive Summary

**Goal:** Zero-friction onboarding for Invited Witnesses. Maximize conversion of shared invite links.

**Platform Focus:** Android First (Intent Handling)

**Constraint:** Low operational cost (Minimize Edge Functions, $0 compute for previews)

**Philosophy:** "Revenue = f(Viral Coefficient)². Optimize virality BEFORE monetization."

---

## Strategic Rulings

### 1. "Socially Binding Pact" vs. "Legally Binding"

**Risk:** Using "Legally Binding" exposes us to lawsuits if a user fails a habit and claims "Breach of Contract."

**The Pivot:** Use the term **"Socially Binding Pact"**.

**The UI:** Lean heavily into the *visuals* of a legal contract:
- Wax Seal animation (stamp effect)
- Signature gesture (tap and hold)
- Old paper texture background
- Heavy Haptic "Thud" on acceptance
- Official document layout

**Result:** It *feels* binding without the legal headache.

### 2. Cost-Effective Dynamic Images

**The Problem:** Generating images on the server (Edge Functions) costs money per click.

**The Solution:** Generate the image **client-side** on User A's phone before they share.

**Implementation:**
1. User A taps "Share Contract"
2. App renders preview card as an off-screen Widget
3. App captures Widget as PNG (using `RenderRepaintBoundary`)
4. App uploads PNG to Supabase Storage (`public/invites/{invite_code}.png`)
5. Share link metadata (Open Graph) references static image URL

**Cost:** $0 compute. Storage only (negligible).

### 3. Retrospective Logging ("The Graceful Recovery")

**The Decision:** Allow logging habits completed yesterday, but with visual distinction.

**The Design:**
| Completion Type | Sound | Visual | Color | Confetti |
|-----------------|-------|--------|-------|----------|
| Standard (Today) | "The Clunk" | Full celebration | Gold/Green | Yes |
| Retrospective (Yesterday) | "Soft Click" | Subdued | Silver/Grey | No |

**Data Model:**
```dart
// In habit_completions table
is_retrospective: bool // true if logged after the fact
```

**Philosophy:** Saves the streak (Retention) but denies the full "Juice" (Behavioral Shaping). It's an "Admin Task," not a "Victory."

---

## 1. The "Side Door" Architecture (Context-Aware Onboarding)

### Concept

If User B installs the app via a "Contract Link," they skip the marketing fluff and land directly on the "Accept Contract" screen.

### The "Clipboard Bridge" (Cost-Effective Deferred Deep Linking)

Since we cannot pay for Branch.io yet, we use a heuristic:

```
┌─────────────────────────────────────────────────────────────────┐
│                    USER A (Inviter)                              │
├─────────────────────────────────────────────────────────────────┤
│ 1. Taps "Share Contract"                                        │
│ 2. App copies invite text to clipboard:                         │
│    "I need a witness! Join my pact: atomichabits.app/join/xyz"  │
│ 3. Share Sheet opens (WhatsApp, SMS, etc.)                      │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    USER B (Invitee)                              │
├─────────────────────────────────────────────────────────────────┤
│ 1. Clicks link → App Store (if not installed)                   │
│ 2. Installs app → Opens for first time                          │
│ 3. OnboardingOrchestrator runs detection:                       │
│    a. Check getInitialLink() (Standard Deep Link)               │
│    b. FALLBACK: Check System Clipboard for regex:               │
│       atomichabits\.app/join/([a-zA-Z0-9]+)                     │
│ 4. If code found → Route to WitnessAcceptScreen                 │
│    If not → Standard onboarding                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Implementation

```dart
// lib/data/services/deep_link_service.dart

/// Checks system clipboard for invite codes (Deferred Deep Link fallback)
/// Returns invite code if found, null otherwise
Future<String?> checkClipboardForInvite() async {
  try {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData?.text == null) return null;
    
    final text = clipboardData!.text!;
    
    // Match patterns:
    // - atomichabits.app/join/CODE
    // - atomichabits.app/c/CODE
    // - atomichabits://invite?c=CODE
    final patterns = [
      RegExp(r'atomichabits\.app/join/([a-zA-Z0-9]+)'),
      RegExp(r'atomichabits\.app/c/([a-zA-Z0-9]+)'),
      RegExp(r'atomichabits://invite\?c=([a-zA-Z0-9]+)'),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1); // Return the invite code
      }
    }
    
    return null;
  } catch (e) {
    debugPrint('Clipboard check failed: $e');
    return null;
  }
}
```

---

## 2. The "Social Contract" UI

### Goal

Make the acceptance feel weighty and serious without actual legal liability.

### Visual Design

```
┌─────────────────────────────────────────────────────────────────┐
│                    📜 SOCIALLY BINDING PACT                     │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                                                         │   │
│  │   [User A Avatar]                                       │   │
│  │   @username invites you to witness their journey        │   │
│  │                                                         │   │
│  │   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │   │
│  │                                                         │   │
│  │   📖 Read 10 pages daily                                │   │
│  │   🎯 Identity: "I am a reader"                          │   │
│  │   ⏰ Duration: 21 days                                  │   │
│  │                                                         │   │
│  │   ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │   │
│  │                                                         │   │
│  │   As a witness, you agree to:                           │   │
│  │   • Receive notifications when they complete            │   │
│  │   • Send High Fives for encouragement                   │   │
│  │   • (Optional) Send nudges if they drift                │   │
│  │                                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                 │
│           ┌─────────────────────────────────────┐               │
│           │                                     │               │
│           │   [HOLD TO SIGN]                    │   ← Long press│
│           │   ═══════════════                   │               │
│           │                                     │               │
│           └─────────────────────────────────────┘               │
│                                                                 │
│                    [Maybe Later]                                │
└─────────────────────────────────────────────────────────────────┘
```

### Interaction Flow

1. **Entry:** User arrives via deep link or clipboard detection
2. **Preview:** Contract terms displayed in "official" styling
3. **Commitment Gesture:** 
   - User must **tap and hold** the "Sign" button for 1.5 seconds
   - Progress indicator fills during hold
   - Heavy haptic feedback throughout
4. **Completion:**
   - Wax seal "stamp" animation drops onto document
   - "SEALED" text appears
   - Celebratory sound + confetti
5. **Transition:** Navigate to Witness Dashboard

### Haptic + Sound Pattern

```dart
// lib/data/services/sound_service.dart

/// The "Contract Sign" feedback pattern
static Future<void> contractSign() async {
  // Build-up ticks during hold
  for (int i = 0; i < 3; i++) {
    HapticFeedback.selectionClick();
    await Future.delayed(Duration(milliseconds: 400));
  }
  
  // Final "stamp" thud
  HapticFeedback.heavyImpact();
  await _playSound('sign.mp3'); // Deep thud sound
}
```

---

## 3. Retrospective Logging ("The Graceful Recovery")

### Goal

Allow users to log habits they completed yesterday but forgot to track.

### Logic

```dart
// lib/features/today/controllers/today_screen_controller.dart

/// Check if retrospective logging is available
bool canLogRetrospectively(Habit habit) {
  final yesterday = DateTime.now().subtract(Duration(days: 1));
  final yesterdayKey = _dateKey(yesterday);
  
  // Can only log retrospectively if:
  // 1. Yesterday is not already logged
  // 2. Today is not yet logged (prevent abuse)
  return !habit.completionHistory.containsKey(yesterdayKey);
}

/// Log a retrospective completion
Future<void> logRetrospectiveCompletion(Habit habit) async {
  final yesterday = DateTime.now().subtract(Duration(days: 1));
  
  await appState.completeHabitForDate(
    habit,
    yesterday,
    isRetrospective: true,
  );
  
  // Subdued feedback (not the full "Juice")
  HapticFeedback.lightImpact();
  await soundService.playSoftClick();
  
  // Show subdued confirmation
  _showRetrospectiveConfirmation();
}
```

### UI Distinction

```dart
// Visual distinction for retrospective completions

Widget _buildCompletionIndicator(DateTime date, bool isComplete, bool isRetrospective) {
  if (!isComplete) return _emptyDot();
  
  return Container(
    decoration: BoxDecoration(
      color: isRetrospective 
        ? Colors.grey.shade400  // Silver for retrospective
        : Colors.green,         // Green for same-day
      shape: BoxShape.circle,
    ),
    child: Icon(
      isRetrospective 
        ? Icons.history        // Clock icon for retrospective
        : Icons.check,         // Check for same-day
      color: Colors.white,
      size: 12,
    ),
  );
}
```

### UI Entry Point

Add a subtle "Forgot yesterday?" option on the Today screen:

```
┌─────────────────────────────────────────────────────────────────┐
│  📖 Read 10 pages                           [Mark Complete ✓]   │
│                                                                 │
│  ─────────────────────────────────────────────────────────────  │
│                                                                 │
│                    💭 Forgot yesterday?                         │
│                    [Log it now →]                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 4. Guest Mode "Truth"

### Goal

Guests (anonymous users) must understand their witness data is local-only.

### UI Implementation

```dart
// lib/features/witness/witness_dashboard.dart

Widget _buildGuestWarningBanner(BuildContext context) {
  final authService = context.read<AuthService>();
  
  if (authService.state != AuthState.anonymous) {
    return SizedBox.shrink();
  }
  
  return Container(
    margin: EdgeInsets.all(16),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.amber.shade50,
      border: Border.all(color: Colors.amber.shade200),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, color: Colors.amber.shade700),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Guest Mode',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your witness streaks live on this phone only. '
                'Link your Google Account to save them.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: () => _showSignUpSheet(context),
          child: Text('Link'),
        ),
      ],
    ),
  );
}
```

---

## 5. Client-Side Image Generation

### Goal

Generate share preview images on the user's device instead of server-side.

### Implementation

```dart
// lib/widgets/share_contract_sheet.dart

class ShareContractSheet extends StatefulWidget {
  final HabitContract contract;
  
  // ...
}

class _ShareContractSheetState extends State<ShareContractSheet> {
  final GlobalKey _previewKey = GlobalKey();
  
  /// Renders the preview card off-screen and captures as PNG
  Future<Uint8List?> _capturePreviewImage() async {
    try {
      final boundary = _previewKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to capture preview: $e');
      return null;
    }
  }
  
  /// Uploads preview image to Supabase Storage
  Future<String?> _uploadPreviewImage(Uint8List imageData) async {
    try {
      final fileName = '${widget.contract.inviteCode}.png';
      final path = 'invites/$fileName';
      
      await Supabase.instance.client.storage
          .from('public')
          .uploadBinary(path, imageData);
      
      // Return public URL
      return Supabase.instance.client.storage
          .from('public')
          .getPublicUrl(path);
    } catch (e) {
      debugPrint('Failed to upload preview: $e');
      return null;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Off-screen preview card (for capture)
        Offstage(
          offstage: true,
          child: RepaintBoundary(
            key: _previewKey,
            child: ContractPreviewCard(
              contract: widget.contract,
              size: Size(1200, 630), // Open Graph dimensions
            ),
          ),
        ),
        
        // Visible share UI
        _buildShareButtons(),
      ],
    );
  }
}
```

### Preview Card Design (Open Graph Optimized)

```dart
// lib/widgets/contract_preview_card.dart

class ContractPreviewCard extends StatelessWidget {
  final HabitContract contract;
  final Size size;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildBackgroundPattern(),
          
          // Content
          Padding(
            padding: EdgeInsets.all(48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App logo
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      'Atomic Habits',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                Spacer(),
                
                // Contract invitation
                Text(
                  '${contract.builderDisplayName} needs a witness',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Habit details
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        contract.habitEmoji,
                        style: TextStyle(fontSize: 48),
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contract.habitName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${contract.durationDays} day commitment',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Spacer(),
                
                // Call to action
                Text(
                  'Tap to join the pact',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 6. Analytics Events (Witness Loop Tracking)

### Required Events

| Event | Trigger | Properties |
|-------|---------|------------|
| `invite_created` | User creates contract | `contract_id`, `habit_type`, `duration_days` |
| `invite_shared` | User shares contract link | `contract_id`, `share_method` |
| `invite_clicked` | Deep link accessed | `invite_code`, `referrer` |
| `invite_accepted` | Witness accepts contract | `contract_id`, `witness_is_new_user` |
| `witness_nudge_sent` | Witness sends nudge | `contract_id`, `nudge_type` |
| `high_five_sent` | Witness sends high five | `contract_id`, `reaction_type` |

### Implementation

```dart
// lib/data/services/analytics_service.dart

class WitnessAnalytics {
  static void trackInviteCreated(HabitContract contract) {
    _track('invite_created', {
      'contract_id': contract.id,
      'habit_type': contract.habitType.name,
      'duration_days': contract.durationDays,
    });
  }
  
  static void trackInviteShared(String contractId, String shareMethod) {
    _track('invite_shared', {
      'contract_id': contractId,
      'share_method': shareMethod, // 'clipboard', 'whatsapp', 'sms', etc.
    });
  }
  
  static void trackInviteClicked(String inviteCode, String? referrer) {
    _track('invite_clicked', {
      'invite_code': inviteCode,
      'referrer': referrer ?? 'unknown',
    });
  }
  
  static void trackInviteAccepted(String contractId, bool isNewUser) {
    _track('invite_accepted', {
      'contract_id': contractId,
      'witness_is_new_user': isNewUser,
    });
  }
}
```

---

## Technical Tasks Checklist

### A. Deep Link Infrastructure

- [ ] Implement `DeepLinkService.checkClipboardForInvite()`
- [ ] Update `OnboardingOrchestrator` to handle "Side Door" routing
- [ ] Android Manifest: Ensure `autoVerify` is true for App Links
- [ ] Test clipboard detection on fresh install

### B. UI/UX

- [ ] Design "Contract Acceptance" screen with Wax Seal animation
- [ ] Implement "Socially Binding Pact" terminology throughout
- [ ] Implement Retrospective Logging in `TodayScreenController`
- [ ] Add "Guest Data Warning" banner to `WitnessDashboard`
- [ ] Add "Forgot yesterday?" option to Today screen

### C. Client-Side Image Generation

- [ ] Create `ContractPreviewCard` widget (Open Graph dimensions)
- [ ] Implement `_capturePreviewImage()` in `ShareContractSheet`
- [ ] Implement Supabase Storage upload for previews
- [ ] Update share flow to use generated image URL

### D. Analytics

- [ ] Implement `WitnessAnalytics` class
- [ ] Add tracking to all witness flow touchpoints
- [ ] Create dashboard for monitoring viral metrics

### E. Testing

- [ ] Integration test: Deep link → Accept flow
- [ ] Integration test: Clipboard fallback
- [ ] Integration test: Retrospective logging
- [ ] Manual test: Share preview appearance

---

## Success Metrics

| Metric | Current | Target | Notes |
|--------|---------|--------|-------|
| Invite → Install Rate | Unknown | Track | Need attribution |
| Install → Accept Rate | Unknown | > 50% | Side Door is key |
| Time to Accept | Unknown | < 60s | Frictionless flow |
| Retrospective Log Rate | N/A | < 20% | Should be exception, not rule |
| Guest → Signed Up | Unknown | > 30% | After witnessing value |

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Clipboard permission denied | Medium | High | Show manual code entry fallback |
| Image upload fails | Low | Medium | Share text-only with fallback |
| Retrospective abuse | Low | Low | Visual distinction reduces "gaming" incentive |
| Legal confusion despite wording | Low | High | Disclaimer in fine print |

---

## Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| Phase 22 (The Witness) | ✅ Complete | Core witness infrastructure |
| Supabase Storage | ✅ Configured | For preview image uploads |
| Deep Link Config | ✅ Complete | Universal/App Links ready |
| Sound Service | ✅ Complete | For contract signing feedback |

---

## Timeline

| Week | Focus | Deliverables |
|------|-------|--------------|
| 1 | Deep Links | Clipboard Bridge, Side Door routing |
| 2 | UI/UX | Contract acceptance, Retrospective logging |
| 3 | Polish | Image generation, Analytics, Testing |

---

*"Make joining feel like a ceremony, not a checkbox."*

*Sprint 24 Specification v1.0.0 - December 2025*
