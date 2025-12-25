# AI Suggestion System Implementation Guide

## Overview

I've implemented a **local, offline AI suggestion system** that provides contextual recommendations for strengthening habits based on Atomic Habits principles. The system uses intelligent heuristics to suggest temptation bundling, pre-habit rituals, environment cues, and distraction removal strategies.

---

## 🧠 What is AiSuggestionService?

**File:** `lib/data/ai_suggestion_service.dart`

AiSuggestionService is a pure Dart class that generates personalized habit optimization suggestions **without any network calls**. It analyzes:

- **Habit name** (e.g., "read", "exercise", "meditate")
- **Implementation time** (morning, afternoon, evening, night)
- **Implementation location** (bedroom, desk, kitchen, etc.)
- **User identity** (for personalized messaging)

### How It Works

The service uses **contextual heuristics** to match habits with appropriate suggestions:

1. **Pattern Matching**: Detects habit type from keywords (read, walk, meditate, write, clean, etc.)
2. **Time Analysis**: Parses implementation time to determine time of day
3. **Location Awareness**: Uses location to suggest placement strategies for cues
4. **Fallback Logic**: Provides generic suggestions if specific patterns don't match

### Methods Overview

#### 1. `getTemptationBundleSuggestions()`
**Purpose**: Pair habits with enjoyable activities (James Clear's "Make it Attractive" law)

**Logic**:
- Reading habits → Tea, candles, music (varies by time of day)
- Exercise habits → Podcasts, playlists, TV shows
- Meditation → Incense, nature sounds, soft lighting
- Writing → Hot beverages, café settings, candles
- Cleaning → Upbeat music, podcasts, gamification
- Time-based fallbacks → Morning (coffee), Evening (calming beverages)

**Example Output**:
```dart
For "Read every day" at 21:00 in bedroom:
[
  "Have a cup of herbal tea while reading",
  "Light a candle and read with soft lighting",
  "Listen to a calm instrumental playlist while you read"
]
```

#### 2. `getPreHabitRitualSuggestions()`
**Purpose**: Provide 10-30 second rituals to prime mental state before habit

**Logic**:
- Reading → Deep breaths, put phone away, write curiosity note
- Exercise → Wear workout clothes, fill water bottle, jumping jacks
- Meditation → Close eyes, breathe, light candle
- Writing → Do Not Disturb mode, close tabs, breathe
- Generic → "Take 3 slow breaths", "Phone on airplane mode", "Say identity aloud"

**Example Output**:
```dart
For "Walk 10 minutes" habit:
[
  "Put on your workout clothes immediately when you decide to exercise",
  "Fill your water bottle and take 3 deep breaths",
  "Play your workout playlist and do 5 jumping jacks"
]
```

#### 3. `getEnvironmentCueSuggestions()`
**Purpose**: Make habits obvious with visual triggers (James Clear's 1st Law)

**Logic**:
- **Habit-specific cues**:
  - Reading → Book on pillow, nightstand, TV remote
  - Exercise → Workout clothes laid out, shoes by door, yoga mat visible
  - Meditation → Cushion visible, reminder note, timer in sight
- **Location-based cues**:
  - Bedroom → Item on pillow/nightstand
  - Desk → Item on keyboard/monitor
  - Kitchen → Item on counter/fridge
- **Time-based cues**: Uses implementation time to suggest precise timing (e.g., "Put book on pillow at 21:45")

**Example Output**:
```dart
For "Read" habit at 22:00 in bed:
[
  "Put your book on your pillow at 21:45",
  "Leave your book open on your nightstand",
  "Place your book on top of your phone charger"
]
```

#### 4. `getEnvironmentDistractionSuggestions()`
**Purpose**: Remove friction and competing stimuli

**Logic**:
- **Focus habits** (read, write, study, meditate) → Phone in another room, log out of social media, TV off
- **Exercise habits** → Do Not Disturb, remove seating, hide remote
- **Evening habits** → Charge phone in kitchen, log out of Netflix, disable Wi-Fi at set time
- **Morning habits** → Phone across room, delete social apps, physical alarm clock
- **Location-specific**:
  - Bedroom → Charge phone outside, remove/cover TV
  - Desk → Website blockers, close tabs, phone in drawer

**Example Output**:
```dart
For reading habit at night:
[
  "Charge your phone in the kitchen overnight",
  "Log out of Netflix and YouTube on weeknights",
  "Set your router to disable Wi-Fi at 22:00"
]
```

---

## 🔌 Integration with AppState

**File:** `lib/data/app_state.dart`

### How Suggestions Are Exposed to UI

AppState wraps the AiSuggestionService and provides convenient methods:

```dart
// Single instance of service
final AiSuggestionService _aiSuggestionService = AiSuggestionService();

// Wrapper methods that read current habit context
List<String> getTemptationBundleSuggestionsForCurrentHabit()
List<String> getPreHabitRitualSuggestionsForCurrentHabit()
List<String> getEnvironmentCueSuggestionsForCurrentHabit()
List<String> getEnvironmentDistractionSuggestionsForCurrentHabit()

// Combined suggestions for "Improve this habit" feature
Map<String, List<String>> getAllSuggestionsForCurrentHabit()
```

### Why This Architecture?

1. **UI Simplicity**: UI widgets don't need to pass habit data around - just call AppState methods
2. **Error Handling**: AppState catches exceptions and returns empty lists gracefully
3. **Context Awareness**: AppState has access to current habit and profile automatically
4. **Future-Proofing**: Easy to replace local heuristics with real LLM API calls later

---

## 🎨 UI Integration

### 1. Onboarding Screen (`lib/features/onboarding/onboarding_screen.dart`)

**Added "Get ideas" buttons** next to each optional field:

#### Temptation Bundle Field
```dart
Row(
  children: [
    Expanded(child: TextFormField(...)),
    OutlinedButton.icon(
      onPressed: _showTemptationBundleSuggestions,
      icon: Icon(Icons.lightbulb_outline),
      label: Text('Ideas'),
    ),
  ],
)
```

**User Flow**:
1. User clicks "Ideas" button next to temptation bundle field
2. App creates temporary habit from current form values
3. App calls `appState.getTemptationBundleSuggestionsForCurrentHabit()`
4. Shows `SuggestionDialog` with 3 suggestions
5. User taps a suggestion → TextField is populated
6. User can still edit or overwrite the suggestion

**Same pattern for**:
- Pre-habit ritual
- Environment cue
- Environment distraction

#### Smart Temporary Habit Creation

Since users are still filling the onboarding form, we create a **temporary habit** from current form values:

```dart
final tempHabit = Habit(
  id: 'temp',
  name: _habitNameController.text.isEmpty ? 'your habit' : _habitNameController.text,
  identity: _identityController.text.isEmpty ? 'achieves their goals' : _identityController.text,
  implementationTime: _formatTime(_selectedTime),
  implementationLocation: _locationController.text.isEmpty ? 'at home' : _locationController.text,
);
```

This allows suggestions to be contextual even before the habit is saved.

---

### 2. Suggestion Dialog (`lib/widgets/suggestion_dialog.dart`)

**New reusable widget** for displaying suggestions:

#### Features:
- **Numbered list**: Suggestions shown in clean, numbered cards
- **Tap to select**: User taps any suggestion to auto-fill the field
- **Graceful fallback**: Shows friendly message if suggestions are empty
- **Close without selecting**: User can close dialog and type their own text

#### Visual Design:
- Purple theme with lightbulb icon
- Numbered badges (1, 2, 3) for each suggestion
- Arrow icons indicating tap action
- Helper text: "Tap any suggestion to use it, or close to write your own"

---

### 3. Today Screen (`lib/features/today/today_screen.dart`)

**Added "Get optimization tips" button** below the complete/completed section.

#### Features:
- **Shows combined suggestions**: Pulls 2 suggestions from each category
- **Organized by category**: 💗 Temptation Bundling, 🧘 Pre-Habit Ritual, 💡 Environment Cue, 🚫 Remove Distractions
- **Non-intrusive**: Just a nudge, doesn't allow editing from this screen
- **Helper text**: "Tip: You can adjust your habit setup in Settings."

#### User Flow:
1. User clicks "Get optimization tips" button
2. App calls `appState.getAllSuggestionsForCurrentHabit()`
3. Shows dialog with 2 suggestions per category
4. User reads suggestions and dismisses dialog
5. To apply suggestions, user would go to Settings (future feature)

---

## 🧪 How to Test

### **🌐 Live Web Preview**
**URL:** https://5060-i7bourjpm740ju7sjx1pf-cc2fbc16.sandbox.novita.ai

---

### **Test 1: "Get ideas" Buttons in Onboarding**

#### Steps:
1. **Clear existing data**:
   - Open DevTools (F12) > Application > IndexedDB
   - Delete all Hive databases
   - Refresh page

2. **Start onboarding**:
   - Enter name: `"Alex"`
   - Enter identity: `"reads every day"`
   - Habit name: `"Read one page"`
   - Tiny version: `"Open my book"`
   - Time: `"22:00"` (10 PM)
   - Location: `"In bed"`

3. **Test Temptation Bundle suggestions**:
   - Click **"Ideas"** button next to temptation bundle field
   - Observe dialog appears with 3 suggestions
   - Expected suggestions (for reading at night):
     - "Have a cup of herbal tea while reading"
     - "Light a candle and read with soft lighting"
     - "Listen to a calm instrumental playlist while you read"
   - **Tap first suggestion**
   - Verify field is populated with: "Have a cup of herbal tea while reading"

4. **Test Pre-Habit Ritual suggestions**:
   - Click **"Ideas"** button next to pre-habit ritual field
   - Expected suggestions:
     - "Take 3 slow breaths and open your book to the bookmark"
     - "Put your phone in another room, then sit in your reading chair"
     - "Write down one thing you're curious about, then start reading"
   - **Tap second suggestion**
   - Verify field is populated

5. **Test Environment Cue suggestions**:
   - Click **"Ideas"** button next to environment cue field
   - Expected suggestions (bedroom location):
     - "Put your book on your pillow at 21:45" (15 min before 22:00)
     - "Leave your book open on your nightstand"
     - "Place your book on top of your phone charger"
   - **Tap first suggestion**
   - Verify field is populated

6. **Test Environment Distraction suggestions**:
   - Click **"Ideas"** button next to distraction field
   - Expected suggestions (reading at night):
     - "Charge your phone in the kitchen overnight"
     - "Log out of Netflix and YouTube on weeknights"
     - "Set your router to disable Wi-Fi at 22:00"
   - **Tap third suggestion**
   - Verify field is populated

7. **Test editing after suggestion**:
   - Modify any populated field (e.g., change "kitchen" to "living room")
   - Verify you can edit the text freely

8. **Test skipping suggestions**:
   - Click **"Ideas"** for any field
   - Click **"Close"** button without selecting
   - Type your own custom text
   - Verify this works fine

9. **Complete onboarding**:
   - Click "Start Building Habits"
   - Verify navigation to Today screen

✅ **Expected Results**:
- All 4 "Ideas" buttons work
- Suggestions are contextual to habit type and time
- Tapping suggestion auto-fills field
- Can edit or overwrite suggestions
- Can close dialog without selecting

---

### **Test 2: Contextual Suggestions Based on Habit Type**

Test that suggestions change based on habit characteristics.

#### Scenario A: Exercise Habit (Morning)

1. **Clear data and restart onboarding**
2. **Enter**:
   - Identity: `"stays active"`
   - Habit: `"Walk 10 minutes"`
   - Tiny version: `"Put on walking shoes"`
   - Time: `"07:00"` (morning)
   - Location: `"Neighborhood"`

3. **Click "Ideas" for temptation bundle**:
   - Expected:
     - "Listen to your favourite podcast while exercising"
     - "Create a pump-up playlist for your workout"
     - "Watch an episode of your favourite show while on the treadmill"

4. **Click "Ideas" for pre-habit ritual**:
   - Expected:
     - "Put on your workout clothes immediately when you decide to exercise"
     - "Fill your water bottle and take 3 deep breaths"
     - "Play your workout playlist and do 5 jumping jacks"

5. **Click "Ideas" for environment cue**:
   - Expected:
     - "Lay out your workout clothes the night before"
     - "Put your running shoes by the door where you'll see them"
     - "Leave your yoga mat unrolled in the middle of the room"

✅ **Expected**: Suggestions are specific to **exercise habits**, not reading

---

#### Scenario B: Meditation Habit (Evening)

1. **Clear data and restart onboarding**
2. **Enter**:
   - Identity: `"is calm and mindful"`
   - Habit: `"Meditate 2 minutes"`
   - Tiny version: `"Sit on cushion"`
   - Time: `"19:00"` (evening)
   - Location: `"Living room corner"`

3. **Test all "Ideas" buttons**:
   - **Temptation bundle**: Incense, calming music, soft lighting
   - **Pre-habit ritual**: Close eyes, breathe, light candle
   - **Environment cue**: Meditation cushion visible, reminder note
   - **Distraction**: Phone in another room, log out of social media

✅ **Expected**: Suggestions are specific to **meditation habits**

---

#### Scenario C: Generic/Unknown Habit

1. **Enter unusual habit**: `"Practice calligraphy"`
2. **Test suggestions**:
   - Should receive **generic fallback suggestions**
   - Based on time of day (morning/evening) and location
   - Still useful, just not habit-specific

✅ **Expected**: Graceful fallback to generic suggestions

---

### **Test 3: "Get Optimization Tips" Button on Today Screen**

#### Steps:

1. **Complete onboarding** with any habit (use reading example from Test 1)

2. **Navigate to Today screen**

3. **Locate "Get optimization tips" button**:
   - Should be below the "Mark as Complete" or "Completed" section
   - Outlined button with lightbulb icon

4. **Click "Get optimization tips"**

5. **Observe dialog**:
   - Title: "Strengthen Your Habit" with tips icon
   - Organized by categories:
     - 💗 Temptation Bundling (2 suggestions)
     - 🧘 Pre-Habit Ritual (2 suggestions)
     - 💡 Environment Cue (2 suggestions)
     - 🚫 Remove Distractions (2 suggestions)
   - Footer: "Tip: You can adjust your habit setup in Settings."

6. **Verify suggestions are contextual**:
   - Should match the habit you created
   - Should show 2 suggestions per category (not all 3)

7. **Click "Close"**:
   - Dialog dismisses
   - Return to Today screen
   - No changes made (this is just a nudge)

✅ **Expected Results**:
- Button visible on Today screen
- Dialog shows combined suggestions
- Organized by category with icons
- Close button works
- No errors if suggestions are empty

---

### **Test 4: Empty/Missing Data Handling**

Test graceful degradation when habit data is incomplete.

#### Scenario: Click "Ideas" Before Filling Form

1. **Start fresh onboarding**
2. **Click "Ideas"** button **immediately** (before filling any fields)
3. **Observe suggestions**:
   - Should still generate suggestions using defaults:
     - Habit name: "your habit"
     - Identity: "achieves their goals"
     - Location: "at home"
   - Should NOT crash or show empty dialog

✅ **Expected**: Suggestions generated with sensible defaults

---

#### Scenario: Invalid/Empty Time

1. **Don't select a time** (use default 09:00)
2. **Click "Ideas"**
3. **Verify**: Suggestions use "morning" time of day category

✅ **Expected**: Graceful handling of default values

---

### **Test 5: Suggestions Don't Break Existing Functionality**

Verify all original features still work:

#### Test A: Onboarding Without Using Suggestions

1. **Complete onboarding** without clicking any "Ideas" buttons
2. **Leave all optional fields blank**
3. **Click "Start Building Habits"**
4. **Verify**:
   - Today screen loads normally
   - No temptation bundle, ritual, or environment sections visible
   - Can complete habit normally

✅ **Expected**: Optional suggestions don't break required onboarding flow

---

#### Test B: Today Screen Without Suggestions

1. **Use habit created in Test A** (no optional fields)
2. **Click "Get optimization tips"**
3. **Verify**:
   - Dialog still shows suggestions (based on core habit data)
   - No errors from missing optional fields

✅ **Expected**: Suggestions work even for minimal habits

---

#### Test C: Reward Flow Still Works

1. **Create any habit** (with or without suggestions)
2. **Click "Mark as Complete"**
3. **Verify**:
   - Confetti animation plays
   - Investment question appears
   - Streak updates correctly

✅ **Expected**: Reward + Investment flow unaffected

---

#### Test D: Notifications Still Work

1. **Complete onboarding** with any habit
2. **Grant notification permission**
3. **Check console** for "Notification scheduled" message
4. **Verify**:
   - Notification scheduling succeeds
   - No errors related to suggestion features

✅ **Expected**: Notification system unaffected

---

## 🛡️ Error Handling

### Graceful Degradation

The system is designed to fail gracefully:

1. **Empty suggestions**: SuggestionDialog shows friendly "No suggestions available" message
2. **Missing habit data**: Returns empty list instead of crashing
3. **Invalid time format**: Falls back to generic time-based suggestions
4. **Unknown habit type**: Provides generic suggestions based on time/location

### Debug Logging

AppState methods include debug logging (only in development):

```dart
if (kDebugMode) {
  debugPrint('Error getting temptation bundle suggestions: $e');
}
```

---

## 🔮 Future Enhancement Path

**NOTE**: The current implementation uses **pure Dart heuristics** with no network calls. To upgrade to real LLM-based suggestions:

### Step 1: Add API Client

```dart
// lib/data/llm_api_client.dart
class LlmApiClient {
  Future<List<String>> generateSuggestions({
    required String promptTemplate,
    required Map<String, String> context,
  }) async {
    // Call OpenAI/Gemini/Claude API here
  }
}
```

### Step 2: Replace Heuristic Methods

```dart
// In AiSuggestionService
Future<List<String>> getTemptationBundleSuggestions(...) async {
  // Option A: Keep heuristics as fallback
  try {
    return await _llmClient.generateSuggestions(...);
  } catch (e) {
    return _heuristicTemptationSuggestions(...); // Fallback
  }
  
  // Option B: Replace entirely with LLM
  return await _llmClient.generateSuggestions(...);
}
```

### Step 3: Update UI to Handle Async

```dart
// Onboarding screen methods become async
Future<void> _showTemptationBundleSuggestions() async {
  // Show loading indicator
  final suggestions = await appState.getTemptationBundleSuggestionsForCurrentHabit();
  // Show suggestions dialog
}
```

---

## 📊 Files Created/Modified

### **New Files Created**:

1. **`lib/data/ai_suggestion_service.dart`** (15 KB)
   - Pure Dart suggestion engine
   - 4 main methods + 2 helper methods
   - Comprehensive heuristics for all habit types

2. **`lib/widgets/suggestion_dialog.dart`** (6.5 KB)
   - Reusable dialog for displaying suggestions
   - Clean numbered list UI
   - Graceful empty state handling

### **Files Modified**:

3. **`lib/data/app_state.dart`**
   - Added `AiSuggestionService` instance
   - Added 5 new methods for UI integration
   - Total additions: ~100 lines

4. **`lib/features/onboarding/onboarding_screen.dart`**
   - Added 4 "Get ideas" buttons (one per optional field)
   - Added 4 helper methods to show suggestion dialogs
   - Added temporary habit creation logic
   - Total additions: ~200 lines

5. **`lib/features/today/today_screen.dart`**
   - Added "Get optimization tips" button
   - Added `_showImprovementSuggestions()` method
   - Total additions: ~120 lines

---

## 📝 Summary

### What AiSuggestionService Does

A local, offline suggestion engine that:
- Analyzes habit characteristics (name, time, location, identity)
- Generates 3 contextual suggestions per category
- Uses pattern matching and time/location heuristics
- Provides fallback suggestions for unknown patterns
- **No network calls** - completely local and fast

### How Its Methods Work

- **`getTemptationBundleSuggestions()`**: Pairs habits with enjoyable activities
- **`getPreHabitRitualSuggestions()`**: Creates 10-30 second mental preparation rituals
- **`getEnvironmentCueSuggestions()`**: Designs visual triggers based on location/time
- **`getEnvironmentDistractionSuggestions()`**: Removes competing stimuli

All methods:
1. Parse habit name for keywords (read, walk, meditate, etc.)
2. Analyze time of day (morning, afternoon, evening, night)
3. Consider location for placement strategies
4. Return 3 specific suggestions or generic fallbacks

### How the UI Uses It

**Onboarding Screen**:
- 4 "Ideas" buttons next to optional fields
- Creates temporary habit from current form values
- Calls AppState wrapper methods
- Shows SuggestionDialog with 3 options
- User taps to auto-fill or closes to type custom text

**Today Screen**:
- "Get optimization tips" button below complete section
- Calls `getAllSuggestionsForCurrentHabit()`
- Shows combined dialog with 2 suggestions per category
- Read-only nudge (doesn't allow editing)

**AppState Integration**:
- Wraps AiSuggestionService instance
- Provides convenient methods that read current habit
- Handles errors gracefully (returns empty lists)
- Ready for future LLM API replacement

---

## 🎯 Key Achievements

✅ **Zero network calls** - completely offline and fast  
✅ **Contextual intelligence** - suggestions vary by habit type, time, location  
✅ **Graceful degradation** - handles empty data without crashing  
✅ **Non-intrusive** - optional suggestions don't block workflow  
✅ **Future-proof** - easy to replace heuristics with LLM APIs later  
✅ **Preserves all existing features** - onboarding, today screen, rewards, notifications all work  
✅ **Production-ready** - no errors, only minor info-level warnings  

---

**🎉 All requirements met! The AI suggestion system is ready for testing.**
