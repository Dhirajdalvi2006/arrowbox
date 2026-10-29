# Arrow Lab Minimal Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign Arrow Lab with a clean, minimal interface featuring a compact preview, 3-column style grid, and color swatches for surfaces.

**Architecture:** Refactor `ArrowLabScreen` to use a `ListView` with refined spacing and custom compact widgets. Use `ListenableBuilder` (inherited from `AppStore` access) for immediate preview updates. Filter `ArrowSkinRegistry` to show only the 6 specified styles.

**Tech Stack:** Flutter, `AppStore` (ChangeNotifier), `LayoutBuilder`.

**Spec:** Redesign Arrow Lab Using the Minimal Settings Style (User Prompt)

## Global Constraints

- Background: `#070D1A`
- Card background: `#101C31`
- Primary accent: `#1685FF` (Electric Blue)
- Spacing: 16–20px
- Default style: Classic
- Default surface: Midnight
- Persistence: Respect `AppStore` (arrowSkinId, boardThemeId)

## Review Focus

- **Layout Overflow:** Ensure the 3-column grid adapts to narrow viewports without clipping.
- **Bottom Clearance:** Verify content clears the `FloatingBottomNav` (which sits at the bottom).
- **Preview Accuracy:** Ensure `ArrowSkinPreviewBoard` updates immediately and reflects both skin and surface.
- **Persistence:** Verify `AppStore` correctly saves and restores preferences across sessions.
- **Visual Fidelity:** Match the dark theme tokens and "premium" feel.

---

### Task 1: Redesign Arrow Lab Layout and Header

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`
- Modify: `lib/core/theme/app_colors.dart` (if tokens are missing)

**Interfaces:**
- Consumes: `AppStore` for state and persistence.

- [ ] **Step 1: Update AppColors tokens**
Ensure `background`, `card`, and `primary` match the specified hex codes.

- [ ] **Step 2: Redesign the Header**
Left-aligned "Arrow Lab" with "Customize your game" subtitle. Reduce vertical spacing.

- [ ] **Step 3: Refactor the main ListView**
Set padding and background color. Ensure `SafeArea` is used.

- [ ] **Step 4: Commit**
```bash
git add lib/features/arrow_lab/arrow_lab_screen.dart lib/core/theme/app_colors.dart
git commit -m "design: update Arrow Lab header and base layout"
```

### Task 2: Implement Compact Board Preview

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`
- Modify: `lib/features/arrow_designs/preview/arrow_skin_preview_board.dart` (if needed for theme support)

**Interfaces:**
- Consumes: `AppStore.arrowSkinId`, `AppStore.boardThemeId`.

- [ ] **Step 1: Update ArrowSkinPreviewBoard to support BoardTheme**
Modify `ArrowSkinPreviewBoard` to accept a `BoardTheme` instead of hardcoded colors.

- [ ] **Step 2: Create _CompactPreview widget**
A centered card with a 1:1 aspect ratio preview board. Use `ListenableBuilder` on the `AppStore`.

- [ ] **Step 3: Run verification**
Verify the preview updates when `store.arrowSkinId` or `store.boardThemeId` changes.

- [ ] **Step 4: Commit**
```bash
git add lib/features/arrow_lab/arrow_lab_screen.dart lib/features/arrow_designs/preview/arrow_skin_preview_board.dart
git commit -m "feat: add compact functional board preview"
```

### Task 3: Implement Arrow Style Selector (3-column Grid)

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`

**Interfaces:**
- Consumes: `ArrowSkinRegistry.all` (filtered).

- [ ] **Step 1: Filter ArrowSkinRegistry**
Define a constant list of `ArrowSkinId`s to show: `classic`, `neon`, `glass`, `minimal`, `tech`, `fantasy`.

- [ ] **Step 2: Create _CompactSkinGrid**
Use `LayoutBuilder` and `GridView.builder` with `crossAxisCount: constraints.maxWidth > 500 ? 3 : 2` (or adaptive).

- [ ] **Step 3: Implement _CompactSkinCard**
Show a small arrow preview and short name. Selected state: electric-blue border and checkmark.

- [ ] **Step 4: Commit**
```bash
git add lib/features/arrow_lab/arrow_lab_screen.dart
git commit -m "feat: add compact 3-column arrow style selector"
```

### Task 4: Implement Board Surface Selector (Swatches)

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`

**Interfaces:**
- Consumes: `BoardThemeRegistry.all`.

- [ ] **Step 1: Create _CompactSurfaceGrid**
2-column grid of color swatches with labels.

- [ ] **Step 2: Implement _SurfaceSwatch**
Selected state: blue border/checkmark.

- [ ] **Step 3: Commit**
```bash
git add lib/features/arrow_lab/arrow_lab_screen.dart
git commit -m "feat: add compact board surface swatches"
```

### Task 5: Final Layout Refinement and Bottom Clearance

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`

- [ ] **Step 1: Add bottom padding**
Ensure the `ListView` has enough bottom padding (e.g., 140px) to clear the `FloatingBottomNav`.

- [ ] **Step 2: Responsive Check**
Verify no overflows on 360px width. Ensure preview scales.

- [ ] **Step 3: Commit**
```bash
git add lib/features/arrow_lab/arrow_lab_screen.dart
git commit -m "fix: refine spacing and ensure bottom navigation clearance"
```

### Task 6: Verification and Tests

**Files:**
- Modify: `test/appearance_test.dart`

- [ ] **Step 1: Update appearance_test.dart**
Add tests for default selection (Classic), saved preferences, and preview updates.

- [ ] **Step 2: Add responsive viewport tests**
Test 360x800, 390x844, 430x932, 768x1024.

- [ ] **Step 3: Run final verification**
```powershell
dart format lib test; flutter analyze; flutter test
```

- [ ] **Step 4: Commit**
```bash
git add test/appearance_test.dart
git commit -m "test: add comprehensive UI and responsiveness tests for Arrow Lab"
```
