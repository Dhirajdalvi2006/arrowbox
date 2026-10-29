# Splash Screen Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a premium, animated splash screen for the ArrowBox app matching the provided reference design, replacing the basic current implementation while maintaining existing startup functionality.

**Architecture:** The splash screen is built as a stateful widget (`_StartupSplash`) in `lib/startup.dart` using `AnimationController` to orchestrate entry animations for the logo, text, and floating arrow tiles. It uses a `Stack` to overlay the floating elements on the background grid, adhering to the existing design system.

**Tech Stack:** Flutter `AnimationController`, `Tween`, `CustomPainter` (for grid), `Stack`, `Positioned`, `Opacity`, `Transform`.

**Spec:** The task description in the conversation (`b6fb`).

## Global Constraints

- Background: `#070D1A`
- Primary Accents: Electric blue (`#247BFF`), Cyan (`#21D4FD`).
- Typography: "ArrowBox" (Bold, 30sp, White), Tagline (14sp, Cyan).
- Animation: Smooth entry, continuous floating for tiles, indeterminate progress.
- Compatibility: Must work on Android and Chrome (`flutter run -d chrome`).
- No new heavy dependencies.

## Review Focus

1.  **Stretching/Overflow:** Are the floating arrow tiles square? (Test: View on narrow mobile vs wide Chrome)
2.  **Performance:** Does the animation cause frame drops? (Test: Run with profiling)
3.  **Flow:** Does the transition to home work immediately after load? (Test: Mock slow load)
4.  **Responsiveness:** Does it fit without scrolling on all screen sizes? (Test: Window resizing)
5.  **Graceful failure:** Does it show the retry UI on error? (Test: Inject error)

---

### Task 1: Scaffolding and Assets Preparation

**Files:**
- Modify: `lib/startup.dart`

**Interfaces:**
- Produces: `_StartupSplash` widget structure with background and placeholder layout for components.

- [ ] **Step 1: Define the background grid painter**

Create a `CustomPainter` for the deep navy grid background in `lib/startup.dart` (as a helper class).

- [ ] **Step 2: Update `_StartupSplash` layout**

Replace the current `Column` layout with a `Stack` to enable positioning of floating arrow tiles around the logo.

- [ ] **Step 3: Commit**

```bash
git add lib/startup.dart
git commit -m "feat: scaffold splash screen stack layout and grid painter"
```

### Task 2: Implementing Animated Logo and Text

**Files:**
- Modify: `lib/startup.dart`

**Interfaces:**
- Consumes: `_StartupSplash` scaffold.
- Produces: Centered, animated ArrowBox logo and typography.

- [ ] **Step 1: Create the animated logo component**

Implement the 3D-effect central arrow tile using `Container` with decoration (beveled edges, glow).

- [ ] **Step 2: Implement entrance animations**

Use `AnimationController` for fade-in and scale-up of logo and text.

- [ ] **Step 3: Commit**

```bash
git add lib/startup.dart
git commit -m "feat: add animated logo and title/tagline"
```

### Task 3: Implementing Animated Floating Arrow Tiles

**Files:**
- Modify: `lib/startup.dart`

**Interfaces:**
- Consumes: `_StartupSplash` layout.
- Produces: Floating 3D arrow tiles around the central logo.

- [ ] **Step 1: Define tile component**

Create a `_FloatingArrowTile` widget that handles its own internal glow and shadow properties.

- [ ] **Step 2: Implement floating logic**

Use `AnimatedBuilder` to create continuous floating movement (sine-wave based animation) for tiles, with offset variations.

- [ ] **Step 3: Commit**

```bash
git add lib/startup.dart
git commit -m "feat: add floating arrow tiles animation"
```

### Task 4: Implementing Animated Progress Indicator and Integration

**Files:**
- Modify: `lib/startup.dart`

**Interfaces:**
- Consumes: The UI created in Tasks 1-3.
- Produces: Working splash screen integrated with app initialization.

- [ ] **Step 1: Implement progress indicator**

Replace current progress indicator with the required horizontal rounded progress track with animation.

- [ ] **Step 2: Integrate into startup**

Ensure the `FutureBuilder` correctly transitions from the new `_StartupSplash` to `_ReadyApp`.

- [ ] **Step 3: Commit**

```bash
git add lib/startup.dart
git commit -m "feat: integrate splash screen and progress animation"
```

### Task 5: Final Review and Verification

- [ ] **Step 1: Run analyze**

Run: `flutter analyze`
Expected: 0 issues.

- [ ] **Step 2: Run tests**

Run: `flutter test`
Expected: All tests pass.

- [ ] **Step 3: Build Web**

Run: `flutter build web`
Expected: Success.

- [ ] **Step 4: Commit**

```bash
git commit -am "chore: finalize splash screen implementation and verify"
```
