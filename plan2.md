# Plan 2: Stunning Redesign of ArrowBox Homepage (WelcomeScreen)

## 1. Objective & Vision
Transform the current plain/bland homepage (`WelcomeScreen` in `lib/app.dart`) into an immersive, AAA mobile/web game landing page. The new homepage will feature dynamic ambient glowing radial gradients, floating animations, glassmorphic stats cards, a high-impact glowing CTA, quick game modes (Daily Challenge, Arrow Lab, Level Select), and exquisite typography.

---

## 2. Key Visual & Architectural Features

### A. Immersive Ambient Background & Header
- **Dynamic Background Gradients:** Rich radial glows (`AppColors.primary`, `AppColors.cyan`, and theme-aware surface colors) that adapt smoothly between dark and light mode.
- **Floating Hero Artwork (`ArrowBoxHeroArtwork`):** Enhanced with subtle breathing/floating animation and multi-layered glowing shadow effects.
- **Title & Tagline:** Crisp typography with subtle letter spacing, accent coloring ("Think. Aim. Escape."), and high visual hierarchy.

### B. Player Quick Stats & Profile Glass Card
- Glassmorphic container with frosted blur feel (`BackdropFilter` or translucent gradient borders).
- Live progress ring/bar for level completion (`X of 60 levels completed`, percentage badge).
- Streak / star counter badge.

### C. Action Hero Buttons
- **Primary Play Button:** Gradient fill (`primary` to `cyan`), glowing drop shadow, bounce/scale feedback, clear arrow icon and chevron.
- **Continue Saved Game Button:** Prominently displayed when `store.hasSavedGame` is true, showing exact level and progress.
- **Quick Modes Row:** Quick access chips/cards for **Arrow Lab** (skin customization), **Level Catalog**, and **How to Play**.

## 3. How to Play Section & Interactive Guide Design
- **Visual Mechanics Overview:**
  - Clear, animated step-by-step illustrations or interactive arrow grid cards showing how clicking/tapping an arrow makes it shoot in its pointing direction.
  - Explanation of obstacle clearing: arrows must escape the board without colliding with blocking walls or other arrows in their path.
- **Interactive Accordion / Card Layout:**
  - **Step 1: Inspect Direction:** Identify where each arrow is pointing (North, South, East, West, Diagonals).
  - **Step 2: Tap to Launch:** Tap an arrow to send it gliding along its vector path.
  - **Step 3: Clear the Grid:** Clear all arrows off the board to achieve 3 stars and conquer the level.
- **Accessibility & Quick Access:**
  - Accessible directly from the homepage quick modes grid and from level pauses.
  - Supports dark/light themes with glowing highlight indicators.

---

## 4. Implementation Steps

1. **Refactor `WelcomeScreen` in `lib/app.dart`**:
   - Add stateful or animated intro presentation (fade-in, slide-up animations using Flutter's animation controllers or built-in widget transitions).
   - Implement the immersive layered hero container with rich custom shadows and gradients.
   - Build a gorgeous quick-stats card with glowing progress metrics.
   - Add quick-launch mode cards (Daily Challenge, Arrow Lab preview, Settings shortcut).

2. **Refine Supporting Widgets (`lib/core/widgets/arrowbox_widgets.dart` or local helpers)**:
   - Ensure buttons have tactile pressed states, gorgeous hover shadows on web, and responsive sizing across compact and expanded viewports.

3. **Verify & Test**:
   - Run the app / verify responsiveness in both dark and light themes.
   - Ensure zero layout overflows or clipping.
