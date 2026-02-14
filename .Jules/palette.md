## 2024-05-23 - Accessibility of Dynamic Toggles
**Learning:** For toggle buttons that change state and label dynamically (e.g., "Switch to Utopian" vs "Switch to Dystopian"), using `aria-label` with the *action* (what will happen) is clearer than just the state. However, pairing it with `role="switch"` and `aria-checked` provides the best screen reader experience.
**Action:** Always wrap ambiguous icon-only or state-switching buttons in a Tooltip for mouse users, and ensure `aria-label` + `role` attributes are synchronized for screen readers.
