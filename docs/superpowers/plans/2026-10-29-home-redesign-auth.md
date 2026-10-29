# ArrowBox Home Redesign and Auth Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the ArrowBox Home screen to integrate Firebase Authentication, a new hero artwork, and a simplified navigation structure, while preserving offline game functionality.

**Architecture:** Implement a reactive `LoginProfileButton` in the Home header that interfaces with the existing `AuthService`. Introduce a new `LoginScreen` for Google/Email auth and a profile overlay for session management. Maintain offline game state persistence via the existing `AppStore` and `SharedPreferences`.

**Tech Stack:** Flutter, Firebase Authentication (`firebase_auth`, `google_sign_in`).

**Spec:** The design requirements and flow specifications are derived from the project's existing UI/UX patterns and the provided Home redesign requirements.

## Global Constraints

- Android-only mobile focus (do not add iOS dependencies).
- Offline game state must be preserved and remain fully functional.
- Authentication is strictly optional (app usable without sign-in).
- UI must adhere to existing `AppTheme` and `AppColors` systems.

## Review Focus

- Sign-in flow interrupted by app backgrounding/closing (expected: state restoration).
- Firebase Authentication initialization failure (expected: gracefull fallback to offline mode).
- Google Sign-In cancellation (expected: return to previous screen without error).
- Offline-only user attempting to sign in (expected: network error handling).
- Authentication state changes not reflecting in UI (expected: `StreamBuilder` reactivity).

---

### Task 1: Scaffolding and Auth Integration

**Files:**
- Modify: `lib/core/services/auth_service.dart` (ensure initialization safety)
- Create: `lib/features/auth/login_screen.dart`
- Create: `lib/features/auth/profile_menu.dart`

**Interfaces:**
- Consumes: `AuthService` (existing)
- Produces: `LoginScreen`, `ProfileMenu`

- [ ] **Step 1: Verify `AuthService` safety**
  - Read `lib/core/services/auth_service.dart` to confirm it handles initialization failures gracefully without crashing.

- [ ] **Step 2: Write failing test for `LoginScreen`**
  - Create `test/auth_login_test.dart` to test `LoginScreen` UI components.

- [ ] **Step 3: Implement `LoginScreen`**
  - Create `lib/features/auth/login_screen.dart` with UI for Google Sign-In and Email form.

- [ ] **Step 4: Implement `ProfileMenu`**
  - Create `lib/features/auth/profile_menu.dart` as a modal overlay.

- [ ] **Step 5: Commit**
  - `git add lib/core/services/auth_service.dart lib/features/auth/login_screen.dart lib/features/auth/profile_menu.dart test/auth_login_test.dart`
  - `git commit -m "feat: implement login screen and profile menu"`

---

### Task 2: Home Screen Header Redesign

**Files:**
- Modify: `lib/app.dart`

**Interfaces:**
- Consumes: `AuthService`, `LoginScreen`, `ProfileMenu`
- Produces: Updated `WelcomeScreen` header

- [ ] **Step 1: Write failing test for header redesign**
  - Add test case in `test/appearance_test.dart` to verify `LoginProfileButton` visibility in `WelcomeScreen`.

- [ ] **Step 2: Implement `LoginProfileButton` in `WelcomeScreen`**
  - Modify `lib/app.dart` to replace settings button with `LoginProfileButton`.
  - Use `StreamBuilder` on `AuthService.instance.authStateChanges` to toggle icon/photo.

- [ ] **Step 3: Run tests and verify**
  - `flutter test test/appearance_test.dart`
  - Expected: PASS

- [ ] **Step 4: Commit**
  - `git add lib/app.dart test/appearance_test.dart`
  - `git commit -m "feat: redesign home header with auth button"`

---

### Task 3: Hero and UI Cleanup

**Files:**
- Modify: `lib/app.dart`

**Interfaces:**
- Consumes: None (UI cleanup)
- Produces: Finalized `WelcomeScreen`

- [ ] **Step 1: Update Hero section**
  - Replace `ArrowBoxLogoMark` with new central artwork in `lib/app.dart`.

- [ ] **Step 2: Simplify Navigation**
  - Remove secondary "Progress" and "About" cards from Home.
  - Update `WelcomeScreen` layout to clean up button styling.

- [ ] **Step 3: Verify visually**
  - Manually check UI in emulator for layout regressions.

- [ ] **Step 4: Commit**
  - `git add lib/app.dart`
  - `git commit -m "feat: update home hero and simplify navigation"`

---

### Task 4: Regression Audit and Final Verification

**Files:**
- Modify: `test/audit_regression_test.dart` (if needed)

- [ ] **Step 1: Run full test suite**
  - `flutter test`
  - Expected: ALL PASS (including `audit_regression_test.dart`).

- [ ] **Step 2: Fix any regression**
  - Fix any failures arising from UI changes.

- [ ] **Step 3: Commit**
  - `git commit -m "chore: regression test verification"`
