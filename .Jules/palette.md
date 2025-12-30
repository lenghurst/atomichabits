## 2024-05-23 - [InkWell over Gradient Backgrounds]
**Learning:** `InkWell` (ripple effect) needs to be rendered on a `Material` widget. To have a ripple over a complex `BoxDecoration` (like a gradient), you cannot just wrap the Container in InkWell (ripple is behind) or InkWell inside Container (ripple is hidden by opacity/color).
**Action:** Use the `Container(decoration: ..., child: Material(color: Colors.transparent, child: InkWell(...)))` pattern. This layers the ripple *on top* of the decoration while preserving the background.
