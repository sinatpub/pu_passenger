# 01 — Design Direction

All values below are based on the analysis of the current `pu_passenger` codebase and the authoritative `taarraa-ui-prototype.html`.

---

## Redesign Goals

1. Modernize the visual identity while preserving the Taarraa brand (#FF4500)
2. Establish a consistent design language across all screens using the token system from the prototype
3. Improve usability through clearer visual hierarchy, purposeful spacing, and obvious primary actions
4. Add missing user flows (Rating, Receipt) and polish existing ones
5. Reduce visual noise and improve information density with card-based layouts

## Design Principles

### 1. Card-Based Information Architecture
Every content block lives inside a consistent card (16px radius, `shadowMd`, white bg). The current app mixes bordered containers, background-colored sections, and shadowed containers inconsistently.

### 2. Purposeful Color
Use #FF4500 (Taarraa Orange) as a strategic accent — CTAs, active states, selected items. Navy (#232838) for dark elements (status pill, promo bg, toast, plate badge). Use neutral tones (#F6F6F7 bg, #191C24 ink, #6B7588 sub) for content.

### 3. Clear Typography Hierarchy
Every screen has a clear reading order: Heading (24/800) → Title (17/700) → Body (15/400) → Caption (13/400). Buttons are 16/700. Badges are 12/700.

### 4. Consistent Spacing
4px base grid. Cards use 16px internal padding. Screens use 20px horizontal padding. Section gaps are 12-16px.

### 5. Obvious Primary Actions
One clear CTA per screen. Primary button is always orange with a colored shadow. Ghost buttons for secondary actions. Danger-ghost for destructive.

---

## Current Problems (Evidence from Source Code)

### P1 — No Skeleton Loading on Home
`home_view.dart:50` — Loading state is `SizedBox.shrink()`. User sees empty white space with no loading indicator.

### P2 — Home Vehicle Grid is Confusing
`home_view.dart:150-250` — 2×2 grid with center VIP circle that overlaps other cards. Red-tinted backgrounds reduce image legibility.

### P3 — Map Bottom Sheet is Overloaded
`map_view.dart:100-250` — Bottom sheet simultaneously shows search bar, pickup address, destination address, distance, fare, vehicle info, tariff button, and booking button.

### P4 — Map Search Entry Looks Disabled
`map_view.dart:170` — The "Where to go" search bar has grey background with no border, appearing disabled.

### P5 — Booking Has No Visual Progress
`booking_map_view.dart:50-150` — Status is text-only at the bottom. No visual progress indicator of ride status.

### P6 — History Cards Are Too Dense
`history_view.dart:80-200` — Each card contains avatar, invoice #, driver name, payment method, date, status badge, distance, duration, amount, vehicle type row, map placeholder, and two addresses.

### P7 — Profile Screen is Sparse
`profile_view.dart:30-80` — Name + 2 menu items + commented-out logout. Feels unfinished.

### P8 — No Rating or Receipt Screen
RateDriver library exists in `lib/presentation/widgets/rateDriver/` but is not wired up. No receipt screen exists.

### P9 — Bottom Nav Icons Don't Match Purpose
`bottom_nav_view.dart:30-50` — Uses `Icons.event` for "My Booking" (should be calendar/list). Uses `Icons.person` for Profile.

### P10 — Typography Lacks Hierarchy
`text_styles.dart` — Only Regular and SemiBold weights. No ExtraBold (800) or Bold (700). Misnamed `font10SemiBold` is actually 14pt.

---

## Redesign Opportunities (From Prototype)

### O1 — Floating Pill Tab Bar
Replace full-width Material BottomNav with a floating pill (radius 22, inset 12px, `shadowLg`, active tab = brand-50 pill). Matches modern ride-hailing apps.

### O2 — Vertical Vehicle List
Replace confusing 2×2 grid with a clean vertical list of vehicle rows (SVG art + name + seats/price + ETA). Each row is a tappable card.

### O3 — PROMO Banner on Home
Add a dark gradient promo card (navy bg, PROMO tag, title, code, chevron) above the "Where to?" search bar.

### O4 — Prominent "Where to?" Search Card
Replace grey disabled-looking search bar with a white tappable card (16px radius, `shadowMd`, brand icon, "Where to?" text) that navigates to full-screen search.

### O5 — Ride Progress Timeline
Replace text-only status with a 3-step timeline (Accepted → Arriving → On trip) + navy status-pill with pulse dot + driver card with plate badge.

### O6 — Rating Screen
Add star rating (5 stars) + tag chips (Polite, Clean car, Safe driving, Fast pickup) + textarea + Submit.

### O7 — Receipt Screen
Add "Thank you!" with green check + invoice card + "Back to Home" / "Book again" buttons.

### O8 — Tariff Detail Sheet
Keep the Tariff button + nested bottom sheet (Min fee / Price per km / Seats) — users need this information.

### O9 — Step Indicators on Auth
Add 3-dot step indicator across Login (1/3) → OTP (2/3) → Register (3/3) for clarity.

### O10 — Segmented Controls
Use segmented controls (`.seg` / `.tabs`) for language toggle and history tab switching instead of Material TabBar.
