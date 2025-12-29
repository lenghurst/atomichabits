# Strategic Trust Audit: Week 1 Report

**Date**: 2025-12-29
**Status**: 🔴 STOP & FIX
**Auditor**: Antigravity AI

## Executive Summary
The "Nightmare Scenario" protocol (Phase 1) has been executed. We have identified a **Critical Vulnerability** in the Social Layer that requires immediate remediation before any further feature development.

## The Go/No-Go Decision
- [x] **Invite Codes Secure?** ✅ **PASS** (40 bits entropy)
- [ ] **Nudge Spam Protected?** ❌ **FAIL** (Vulnerability Confirmed)
- [x] **Psychometric Data Safe?** ⚠️ **CONDITIONAL PASS** (Safe by Omission)

**Decision**: 🛑 **STOP. Fix Immediately.**

---

## Detailed Findings

### 1. Invite Code Entropy (Brute-Force Resistance)
- **Test**: Generated 1,000 codes using `HabitContract.generateInviteCode()`.
- **Result**: 1,000 Unique Codes.
- **Analysis**: The algorithm uses a 32-character alphabet with length 8.
- **Entropy**: ~40 bits (1.09 Trillion combinations).
- **Verdict**: **SAFE**. Brute-forcing is computationally infeasible for a casual attacker.

### 2. Nudge Spam (Harassment Vector)
- **Test**: Static Analysis of `ContractService.sendNudge` (lines 396-455).
- **Result**: **CRITICAL FAILURE**.
- **Analysis**: The code updates `lastNudgeSentAt` but **never checks it** before allowing another nudge. A malicious witness could send infinite nudges, spamming the user's device and ruining the "supportive" experience.
- **Verdict**: **UNSAFE**. Must implement rate limiting (Max 3/day).

### 3. Psychometric Data Leakage (Privacy)
- **Test**: Code Structure Audit of `HabitContract`.
- **Result**: **Field Missing**.
- **Analysis**: `HabitContract` does not have a `sharePsychometrics` or `onboardingData` field. This means the "Resistance Lie" is not currently shared with witnesses *at all* via the contract model.
- **Verdict**: **SAFE BY OMISSION**, but **UNSAFE DESIGN**.
    - *Good*: Data isn't leaking *today*.
    - *Bad*: There is no granular consent mechanism if we *do* decide to share it. We rely on it "not being there" rather than "being protected".

---

## Remediation Plan (Immediate Priority)

### 1. Fix Nudge Spam (P0)
**Action**: Implement Rate Limiting explicitly in `ContractService`.

```dart
// Proposed Logic
if (contract.lastNudgeSentAt != null) {
  final lastNudge = contract.lastNudgeSentAt!;
  final timeSince = DateTime.now().difference(lastNudge);
  if (timeSince.inHours < 4) { // 4 hour cooldown
    throw SocialContractException('You can only nudge once every 4 hours.');
  }
}
```

### 2. Implement "Safety by Design" (P1)
**Action**: Add explicit consent fields to `HabitContract`.

```dart
// Proposed Schema Update
final bool sharePsychometrics; // defaults to FALSE
final bool allowNudges;        // defaults to TRUE
```

## Next Steps
1.  **PAUSE** all Phase 2 audit tasks.
2.  **EXECUTE** the "Nudge Spam Fix".
3.  **RE-RUN** `test_nightmare_scenario.dart` (Step 3) to verify fix.
