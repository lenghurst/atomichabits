# Testing Guide: "Make it Attractive" Features

## Overview
This guide shows you how to test the new Atomic Habits features implemented in v1.1:
- **Temptation bundling** (pair your habit with something you enjoy)
- **Pre-habit rituals** (prepare mentally before your habit)
- **Environment design** (cues and distraction guardrails)

All features are **optional** and **backward compatible** with existing habit data.

---

## 🔗 Live Preview
**Web Preview URL:** https://5060-i7bourjpm740ju7sjx1pf-cc2fbc16.sandbox.novita.ai

---

## ✅ Test 1: New Onboarding Fields

### What to Test
The onboarding flow now includes two new optional sections after the core habit fields:
1. **✨ Make it Attractive** (temptation bundle + pre-habit ritual)
2. **🏠 Design Your Environment** (cue + distraction guardrail)

### Steps
1. **Clear existing data** (to restart onboarding):
   - Open browser DevTools (F12)
   - Go to Application > IndexedDB > Delete all Hive databases
   - Refresh the page

2. **Complete basic onboarding**:
   - Enter your identity: `"reads every day"`
   - Habit name: `"Read one page"`
   - Tiny version: `"Open my book"`
   - Implementation time: `"21:00"`
   - Implementation location: `"Living room"`

3. **Fill optional "Make it Attractive" section**:
   - **Temptation bundle** (optional): `"Have herbal tea while reading"`
   - **Pre-habit ritual** (optional): `"Take 3 deep breaths"`
   - Note: The helper text shows examples like "Listen to a podcast while walking"

4. **Fill optional "Design Your Environment" section**:
   - **Environment cue** (optional): `"Put book on pillow at 21:45"`
   - **Distraction guardrail** (optional): `"Charge phone in kitchen"`

5. **Click "Start Your Journey"**

### Expected Results
✅ App navigates to Today screen  
✅ No validation errors (all fields are optional)  
✅ If you left fields blank, they don't appear on Today screen  
✅ Filled fields appear in their respective sections

---

## ✅ Test 2: Today Screen Display

### What to Test
The Today screen now shows all four new fields (when present) in dedicated UI sections.

### Steps
1. **Check temptation bundle display** (after tiny version):
   - Look for a **pink-themed box** with 💗 icon
   - Text should read: `"Bundled with: Have herbal tea while reading"`

2. **Check environment design section**:
   - Look for a **green-bordered box** with title "Environment"
   - Should show both:
     - `"Cue: Put book on pillow at 21:45"` (💡 icon)
     - `"Distraction guardrail: Charge phone in kitchen"` (🚫 icon)

3. **Check "Start ritual" button**:
   - Should appear **below the main habit card**
   - Only visible if:
     - Habit is **not completed today**
     - Pre-habit ritual exists (`"Take 3 deep breaths"`)
   - Button text: `"Start ritual"` with 🧘 icon

4. **Verify button disappears after completion**:
   - Click "Mark as Complete"
   - Complete the reward flow (investment dialogue)
   - Verify "Start ritual" button is **hidden** (already completed)

### Expected Results
✅ Temptation bundle appears in pink box with favorite icon  
✅ Environment section shows cue and distraction in green-bordered box  
✅ "Start ritual" button visible before completion  
✅ Button hidden after habit is completed for today

---

## ✅ Test 3: "Start Ritual" Modal Behavior

### What to Test
The pre-habit ritual modal creates a focused moment before habit execution.

### Steps
1. **Navigate to Today screen** (habit not completed yet)

2. **Click "Start ritual" button**

3. **Observe modal dialog**:
   - Purple-themed UI with 🧘 icon
   - Title: "Pre-Habit Ritual"
   - Your ritual text displayed: `"Take 3 deep breaths"`
   - Countdown timer starts at **30 seconds** (soft guidance, not enforced)
   - Two action buttons:
     - Primary: `"Done – I'm ready"` (purple button)
     - Secondary: `"Skip ritual"` (text button)

4. **Test "Skip ritual"**:
   - Click "Skip ritual"
   - Modal closes immediately
   - Habit remains **not completed** (ritual doesn't auto-complete habit)

5. **Test "Done – I'm ready"**:
   - Click "Start ritual" again
   - Wait for countdown (or click immediately)
   - Click "Done – I'm ready"
   - Modal closes
   - Habit remains **not completed** (just primes you to do the habit)

6. **Complete the actual habit**:
   - After closing ritual, click "Mark as Complete"
   - Verify reward flow triggers normally

### Expected Results
✅ Modal displays ritual text in highlighted purple box  
✅ Countdown runs for 30 seconds (non-blocking)  
✅ "Skip ritual" immediately closes modal  
✅ "Done – I'm ready" closes modal after countdown  
✅ **Ritual modal does NOT complete the habit** (user must still click "Mark as Complete")  
✅ Habit completion triggers reward flow as usual

---

## ✅ Test 4: Hive Persistence

### What to Test
New fields survive app restarts and are properly stored in Hive.

### Steps
1. **Complete onboarding** with all optional fields filled (as in Test 1)

2. **Verify data is visible** on Today screen

3. **Hard refresh the browser**:
   - Press `Ctrl+Shift+R` (Windows/Linux) or `Cmd+Shift+R` (Mac)
   - Or close and reopen the browser tab

4. **Check Today screen** after reload:
   - Temptation bundle still visible
   - Environment cue/distraction still visible
   - If you had completed the habit, streak should persist
   - If ritual button was visible before, it should still be visible

5. **Inspect Hive storage** (DevTools):
   - Open DevTools > Application > IndexedDB
   - Find Hive database > `habit` box
   - Verify JSON contains all 4 new fields:
     ```json
     {
       "temptationBundle": "Have herbal tea while reading",
       "preHabitRitual": "Take 3 deep breaths",
       "environmentCue": "Put book on pillow at 21:45",
       "environmentDistraction": "Charge phone in kitchen"
     }
     ```

### Expected Results
✅ All fields persist after hard refresh  
✅ Hive database contains all 4 new fields in habit JSON  
✅ Fields with empty strings are stored as `null` (not saved)  
✅ Backward compatibility: Old habits without new fields load successfully

---

## ✅ Test 5: Notification Copy Changes

### What to Test
Daily notifications now include temptation bundle in the body text (when present).

### ⚠️ Limitation: Web Testing
**Web browsers don't support real local notifications.** You'll see:
- Notification permission request dialog
- Notification scheduling succeeds
- But actual notification won't appear

**For full notification testing, you need an Android APK build.**

### Steps (Web Preview - Limited)
1. **Complete onboarding** with temptation bundle: `"Have herbal tea while reading"`

2. **Check console for notification scheduling**:
   - Open DevTools Console (F12)
   - Look for log: `"Notification scheduled for [time]"`

3. **Expected notification body** (see code, can't test on web):
   ```
   Title: "Time for your 2-minute Read one page"
   Body: "You're becoming the type of person who reads every day (and Have herbal tea while reading)."
   ```

### Steps (Android APK - Full Testing)
1. **Build APK**:
   ```bash
   cd /home/user/flutter_app
   flutter build apk --release
   ```

2. **Install on Android device**:
   - Transfer APK to phone
   - Install and grant notification permission
   - Complete onboarding with temptation bundle

3. **Wait for scheduled notification** (at implementation time)

4. **Verify notification body includes**:
   - `"(and Have herbal tea while reading)"`
   - If no temptation bundle, body should be: `"You're becoming the type of person who reads every day."`

### Expected Results
✅ Web: Notification permission granted, scheduling logs appear  
✅ Android: Notification appears at scheduled time  
✅ Android: Body includes temptation bundle when present  
✅ Android: Action buttons ("Complete" / "Later") work as before

---

## 🔄 Testing Edge Cases

### Test 6: Partial Optional Fields
**Scenario**: User fills only some optional fields

**Steps**:
1. Clear data and restart onboarding
2. Fill only temptation bundle: `"Listen to podcast"`
3. Leave ritual, cue, and distraction **blank**
4. Complete onboarding

**Expected**:
✅ Only temptation bundle appears on Today screen  
✅ No environment section (both cue and distraction empty)  
✅ No "Start ritual" button (ritual is null)

---

### Test 7: Empty Strings Handling
**Scenario**: User enters spaces or empty strings

**Steps**:
1. In onboarding, enter `"   "` (just spaces) in ritual field
2. Complete onboarding

**Expected**:
✅ `.trim().isEmpty` converts spaces to `null`  
✅ No "Start ritual" button appears  
✅ Hive doesn't store empty string (stores `null`)

---

### Test 8: Backward Compatibility
**Scenario**: Existing user with old habit data (no new fields)

**Steps**:
1. Load app with old habit JSON (manually edit Hive in DevTools)
2. Remove the 4 new fields from habit object
3. Refresh app

**Expected**:
✅ App loads successfully (no crashes)  
✅ Today screen shows only old fields  
✅ No temptation bundle, environment section, or ritual button  
✅ `fromJson()` handles missing fields gracefully with `as String?`

---

## 📊 Files Changed Summary

### Core Data Model
- **`lib/data/models/habit.dart`**: Added 4 nullable fields + updated serialization

### UI Screens
- **`lib/features/onboarding/onboarding_screen.dart`**: Added 2 optional sections with 4 text fields
- **`lib/features/today/today_screen.dart`**: Added displays for temptation bundle, environment, and ritual button

### New Widget
- **`lib/widgets/pre_habit_ritual_dialog.dart`**: Created new modal dialog with countdown timer

### Services
- **`lib/data/notification_service.dart`**: Updated notification body to include temptation bundle

---

## 🐛 Known Issues

### flutter analyze Warnings (Non-Critical)
1. **Unnecessary import** (`flutter/foundation.dart` in today_screen.dart)
   - INFO level, doesn't affect functionality
   - Can be removed for cleaner code

2. **BuildContext across async gap** (line 486 in today_screen.dart)
   - Guarded by `if (mounted)` check
   - Acceptable pattern, safe to use

---

## 📱 Next Steps for Full Testing

1. **Build Android APK**:
   ```bash
   flutter build apk --release
   ```

2. **Test on real Android device**:
   - Notification body with temptation bundle
   - Full daily notification flow
   - Performance on mobile hardware

3. **Optional enhancements**:
   - Remove `flutter/foundation.dart` import
   - Add unit tests for new Habit fields
   - Test with multiple users (reset onboarding multiple times)

---

## ✨ Summary of Implementation

### What Was Added
1. ✅ **4 new optional fields** in Habit model (temptationBundle, preHabitRitual, environmentCue, environmentDistraction)
2. ✅ **Onboarding extended** with 2 new sections (Make it Attractive + Design Your Environment)
3. ✅ **Today screen enhanced** to display all new fields with themed UI sections
4. ✅ **"Start ritual" button** that opens modal dialog with 30-second countdown
5. ✅ **Notification copy updated** to include temptation bundle when present
6. ✅ **Full Hive persistence** with backward compatibility (old habits still work)

### What Was Preserved
✅ All existing streak logic (currentStreak, lastCompletedDate)  
✅ Reward & Investment flow (confetti + investment question)  
✅ Notification scheduling with action buttons  
✅ Single-habit assumption (no habit list feature)  
✅ Identity-based messaging throughout  
✅ 2-minute rule tiny version implementation

---

**Happy Testing! 🎉**

If you encounter any issues, check the console logs in DevTools for detailed error messages.
