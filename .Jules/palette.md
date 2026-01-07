## 2025-05-23 - Accessibility in Custom Interactive Widgets
**Learning:** Custom interactive widgets like `_IdentityChip` often use `GestureDetector` which lacks default accessibility semantics (unlike `InkWell` or `ElevatedButton`). This leaves screen reader users without context on "selected" states or that the element is actionable.
**Action:** Always wrap custom `GestureDetector` widgets with `Semantics` providing `button: true`, `label`, and explicit `selected` state.

## 2025-05-23 - Icon-Only Button Affordance
**Learning:** `IconButton` widgets used for navigation (Back) or actions (Clear) often miss the `tooltip` property, which is critical for both mouse hover users (visual affordance) and screen readers.
**Action:** Enforce `tooltip` on all `IconButton`s, especially those without adjacent text labels.
