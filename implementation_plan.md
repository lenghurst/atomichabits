# Disable Misalignment Guard

## User Review Required
> [!IMPORTANT]
> **Temporary Bypass:** This change explicitly disables the "Data Integrity Guard" (Holy Trinity Check) in `AppRouter`. This allows users to proceed to `Oracle` / `Screening` screens even if they haven't completed the full psychometric profile. This is intended for testing/refinement only.

## Proposed Changes

### Configuration
#### [MODIFY] [app_router.dart](file:///Users/oliverlonghurst/atomichabits/atomichabits-1/lib/config/router/app_router.dart)
- **Goal:** Unblock user from "Flashing Red Alignment Page".
- **Change:** Comment out or disable the `!psychProvider.profile.hasHolyTrinity` check in `_redirect`.
- **Logic:** Temporarily return `null` (allow access) instead of redirecting to `AppRoutes.misalignment`.

## Verification Plan

### Manual Verification
1. **Trigger:** Hot Restart (`R`).
2. **Action:** Navigate to screens that were previously blocked (e.g., Screening, Oracle).
3. **Observation:** Verify that the "User Commitment MISALIGNMENT DETECTED" screen no longer appears.
