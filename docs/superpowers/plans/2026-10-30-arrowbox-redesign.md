# ArrowBox Gameplay Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Clean up the game board, remove persistent hint card and undo button, and add restart/hint controls to the bottom corners.

**Architecture:** Refactor `ArrowBoxLogic` to remove obstacle logic, update `ArrowBoxBoardWidgets` to render empty cells as subtle background, and modify `ArrowBoxScreen` to re-layout bottom controls.

**Tech Stack:** Flutter/Dart.

**Spec:** Provided in the prompt.

## Global Constraints

- Portrait mobile only.
- Dark gaming design: `#070D1A` background, `#101C31` cards, `#1685FF` electric blue, `#39D5FF` cyan.

## Review Focus

1. Solvability of levels after removing obstacles.
2. Responsiveness on small/narrow screens.
3. Persistence of progress after restarting/re-opening levels.
4. Correct behavior of hint functionality.
5. Absence of Undo functionality.

---

### Task 1: Clean Logic & Levels

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_logic.dart`
- Test: `test/arrowbox_logic_test.dart`

**Interfaces:**
- Consumes: N/A
- Produces: `ArrowBoxState` (modified to exclude obstacle generation).

- [ ] **Step 1: Inspect `ArrowBoxLogic` for obstacle generation and dotted cell logic**
- [ ] **Step 2: Remove or refactor obstacle-generation logic**
- [ ] **Step 3: Update `ArrowBoxLogic` ensuring empty cells remain logically empty but visually subtle**
- [ ] **Step 4: Run unit tests to ensure solvability**

### Task 2: Refactor Board Rendering

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_board_widgets.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Simplify `ArrowBoxBoardWidgets` to remove prominent obstacle rendering**
- [ ] **Step 2: Ensure empty cells are rendered as subtle background cells**

### Task 3: Refactor Gameplay Screen Layout

**Files:**
- Modify: `lib/features/arrowbox/arrowbox_screen.dart`
- Modify: `lib/core/widgets/arrowbox_widgets.dart`
- Test: `test/widget_test.dart`

- [ ] **Step 1: Remove hint card widget**
- [ ] **Step 2: Remove undo button logic/UI**
- [ ] **Step 3: Add Restart button (bottom-left) and Hint button (bottom-right)**
- [ ] **Step 4: Update `ArrowBoxScreen` layout for the two-button bottom row**
- [ ] **Step 5: Ensure correct positioning and no overlap**

### Task 4: Verification & Final Polish

- [ ] **Step 1: Run all tests**
- [ ] **Step 2: Verify APK/Web build**
- [ ] **Step 3: Final report**
