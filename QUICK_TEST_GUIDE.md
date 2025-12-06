# Quick Test Guide - AI Suggestions

## 🚀 Getting Started

**Run the app locally:**
```bash
flutter run -d chrome  # For web
flutter run            # For connected mobile device
```

---

## ⚡ 5-Minute Test

### 1. Clear Data & Start Fresh
- Press F12 > Application > IndexedDB > Delete all databases
- Refresh page

### 2. Test Onboarding "Ideas" Buttons

**Fill core fields**:
- Name: `Alex`
- Identity: `reads every day`
- Habit: `Read one page`
- Tiny version: `Open my book`
- Time: `22:00`
- Location: `In bed`

**Test each "Ideas" button**:

✅ **Temptation Bundle "Ideas"**:
- Click button → See 3 suggestions
- Expected: Tea, candles, music suggestions
- Tap first one → Field auto-fills
- Edit the text → Verify you can modify it

✅ **Pre-Habit Ritual "Ideas"**:
- Click button → See 3 suggestions
- Expected: Breathing, phone away suggestions
- Tap second one → Field populates

✅ **Environment Cue "Ideas"**:
- Click button → See 3 suggestions
- Expected: Book on pillow at 21:45, nightstand, phone charger
- Tap any → Field fills

✅ **Environment Distraction "Ideas"**:
- Click button → See 3 suggestions
- Expected: Charge phone in kitchen, log out of Netflix, disable Wi-Fi
- Close without selecting → Type custom text

**Complete onboarding**: Click "Start Building Habits"

---

### 3. Test Today Screen

✅ **Verify all fields display**:
- Pink box with temptation bundle
- Green box with environment cue/distraction
- "Start ritual" button visible

✅ **Test "Get optimization tips"**:
- Click button below complete section
- See combined dialog with 4 categories
- 2 suggestions per category
- Close dialog

✅ **Test habit completion**:
- Click "Mark as Complete"
- Confetti plays
- Investment question appears

---

## 🎯 Key Things to Verify

1. ✅ All 4 "Ideas" buttons work in onboarding
2. ✅ Suggestions are contextual (related to reading at night)
3. ✅ Tapping suggestion fills the field
4. ✅ Can edit text after auto-fill
5. ✅ Can close dialog without selecting
6. ✅ "Get optimization tips" shows combined suggestions
7. ✅ Original features work (complete, reward, streak)

---

## 🔄 Test Different Habits

**Exercise Habit**:
- Habit: `Walk 10 minutes`, Time: `07:00`
- Ideas should suggest: Podcasts, playlists, workout clothes

**Meditation Habit**:
- Habit: `Meditate 2 minutes`, Time: `19:00`
- Ideas should suggest: Incense, breathing, cushion placement

---

## 🛡️ Edge Cases

**Test empty form**:
- Click "Ideas" before filling any fields
- Should show generic suggestions (not crash)

**Test skipping suggestions**:
- Complete onboarding without clicking any "Ideas"
- Leave optional fields blank
- Everything should work normally

---

## 📖 Full Documentation

For detailed testing scenarios and technical details, see:
- `AI_SUGGESTIONS_GUIDE.md` - Comprehensive testing guide (22 KB)
- `IMPLEMENTATION_SUMMARY_AI.md` - Technical summary (9.5 KB)

---

**Ready to test! 🚀**
