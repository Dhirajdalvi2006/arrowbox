# Arrow Lab Workbench Redesign Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the Arrow Lab screen into an immersive "Workbench" experience.

**Architecture:** Replace the current grid-based catalog with a Hero Workbench (for the active selection) and a Variant Tray (for quick swapping).

**Tech Stack:** Flutter, existing project design tokens/widgets.

**Spec:** Redesign the Arrow Lab screen from a grid catalog to a showroom/workbench experience where the selected items are showcased and variants can be swapped.

## Global Constraints

- Preserve existing ArrowBox design system (midnight navy, electric blue accent).
- No changes to gameplay logic, levels, or persistence.
- Responsive design for mobile and web.

## Review Focus

1. **Selection Feedback:** Ensure the transition between the tray variant and the hero workbench feels immediate and satisfying.
2. **Hero Viewport:** Ensure the large workbench preview doesn't overflow or cause layout shifts on smaller devices.
3. **Tray Responsiveness:** Ensure the horizontal tray behaves correctly on different screen widths (mobile vs. desktop).
4. **Consistency:** Verify that the "workbench" aesthetic maintains the dark gaming vibe.
5. **Accessibility:** Confirm that all interactive elements in the tray remain reachable and clearly labeled.

---

### Task 1: Create Workbench Layout Components

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`

**Interfaces:**
- Consumes: Existing `ArrowSkin`, `BoardTheme`, `AppStore`.
- Produces: `WorkbenchHeroPanel` (showcase area), `VariantTray` (swappable samples).

- [ ] **Step 1: Implement `WorkbenchHeroPanel`**
  - Create a central widget that displays the currently selected skin and board theme in a larger, high-fidelity view.

- [ ] **Step 2: Implement `VariantTray`**
  - Create a horizontal, scrollable list (or a compact grid) that shows the available skins and themes, styled as "swappable samples".

- [ ] **Step 3: Update `ArrowLabScreen`**
  - Replace current grid layout with the new Workbench layout (Hero Panel + Variant Tray).

- [ ] **Step 4: Commit**
  ```bash
  git add lib/features/arrow_lab/arrow_lab_screen.dart
  git commit -m "feat: implement workbench layout for Arrow Lab"
  ```

### Task 2: Implement Selection Logic and Animations

**Files:**
- Modify: `lib/features/arrow_lab/arrow_lab_screen.dart`

**Interfaces:**
- Consumes: `WorkbenchHeroPanel`, `VariantTray`.
- Produces: State changes for skin/theme selection.

- [ ] **Step 1: Add animation to selection**
  - Add a subtle transition effect when a variant is selected from the tray.

- [ ] **Step 2: Connect state**
  - Ensure selecting an item in the tray updates the `AppStore` and updates the `WorkbenchHeroPanel`.

- [ ] **Step 3: Commit**
  ```bash
  git add lib/features/arrow_lab/arrow_lab_screen.dart
  git commit -m "feat: add selection logic and animation to workbench"
  ```

### Task 3: Final Verification

**Files:**
- Modify: None (verification only).
- Test: `test/appearance_test.dart`

- [ ] **Step 1: Run tests and verify functionality**
  - Check for any layout overflows on small mobile screens.
  - Verify that the workbench correctly reflects the selected theme/skin.

- [ ] **Step 2: Run formatter and analyzer**
  - `dart format .`
  - `flutter analyze`

- [ ] **Step 3: Commit**
  ```bash
  git commit -m "refactor: verify and finalize workbench UI"
  ```
