# 06 — Implementation Plan

Based on the prototype at `taarraa-ui-prototype.html`. 20 screens, 32 components.

---

## Phase 1: Design Tokens

**Goal:** Create the token system. Zero visual changes to any screen.

**Duration:** 1 day

### Files to Create
```
lib/core/theme/ta_colors.dart       — all semantic color tokens
lib/core/theme/ta_text_styles.dart  — 12 named text styles
lib/core/theme/ta_spacing.dart      — spacing scale
lib/core/theme/ta_radius.dart       — radius tokens
lib/core/theme/ta_shadow.dart       — 3 shadow levels
lib/core/theme/ta_theme.dart        — ThemeData from new tokens
```

### Files to Modify
```
lib/core/theme/colors.dart          — @Deprecated comments on old tokens
lib/core/theme/text_styles.dart     — @Deprecated comments on old tokens
```

### Validation
- `flutter analyze` passes
- All screens look identical (no visual changes)

---

## Phase 2: Core Components

**Goal:** Build all 32 components from the spec. Self-contained, no screen logic.

**Duration:** 4-5 days

**Depends on:** Phase 1

### Priority Order (dependency-based)

**Tier 1 — Primitives (no dependencies)**
```
ta_button.dart           (primary, ghost, dark, danger-ghost, sm)
ta_icon_button.dart      (square, dot indicator)
ta_text_field.dart       (prefix, error)
ta_otp_field.dart        (4-digit, auto-advance)
ta_avatar.dart           (driver, history, profile, register variants)
ta_badge.dart            (success, error, warning, brand)
```

**Tier 2 — Composites (depend on Tier 1)**
```
ta_card.dart
ta_segment.dart          (language toggle, tabs)
ta_step_indicator.dart   (auth progress dots)
ta_kv_row.dart
ta_search_card.dart      (home "Where to?")
ta_search_result.dart    (place card)
ta_note_field.dart
ta_chip.dart
ta_star_rating.dart
ta_skeleton.dart
ta_toast.dart
ta_dialog.dart
ta_bottom_sheet.dart
ta_loading_overlay.dart
```

**Tier 3 — Compound (depend on Tier 1+2)**
```
ta_bottom_nav.dart       (floating pill)
ta_address_row.dart      (pickup/dest dots)
ta_stat_row.dart
ta_vehicle_row.dart      (full and compact)
ta_driver_card.dart
ta_total_box.dart
ta_promo_banner.dart
ta_timeline.dart
ta_status_pill.dart
ta_history_card.dart     (uses avatar, badge, address_row)
ta_profile_row.dart      (uses icon_button)
ta_minimax_sheet.dart    (tariff detail)
```

**Barrel export:**
```
widgets.dart
```

### Validation
- Each component renders correctly in isolation
- `flutter analyze` passes

---

## Phase 3: Auth Flow (Low Risk)

**Goal:** Migrate Splash, Login, OTP, Register.

**Duration:** 2-3 days

**Depends on:** Phase 1, Phase 2

### Files to Modify
```
lib/presentation/screens/splash/view/splash_view.dart
lib/presentation/screens/login/view/login_view.dart
lib/presentation/screens/login/logic/login_logic.dart
lib/presentation/screens/otp/view/otp_view.dart
lib/presentation/screens/otp/logic/otp_logic.dart
lib/presentation/screens/register/view/register_view.dart
lib/presentation/screens/register/logic/register_logic.dart
```

### Tasks
1. **Splash:** Orange-gradient logo badge (96×96, radius 28), star icon, brand name (30/800), subtitle "តារា · Taxi" (15/700, brand), loading bar animation, "Skip →" link, auto-navigate 2200ms
2. **Login:** Step indicator (3 dots, current=0), segmented language toggle, "Welcome back" title, phone field with +855 prefix, "Next" button, validation on press (≥8 digits, shake+haptic)
3. **OTP:** Step indicator (current=1), back icon-btn, "OTP Verification" title, 4 individual OTP inputs (64px, 26/800, radius 14), timer pill (30s), "Send again" link, "New here?" link
4. **Register:** Step indicator (current=2), segmented lang, "Complete profile", avatar picker (120px, camera btn), "Create" (disabled<2) + "Skip" ghost, "or" divider

### Validation
- Full auth flow works: Login → OTP → Register → Home
- Language toggle works
- Error states display correctly

---

## Phase 4: Navigation + Home (Low Risk)

**Goal:** Migrate BottomNav and Home screen.

**Duration:** 2-3 days

**Depends on:** Phase 1, Phase 2, Phase 3

### Files to Modify
```
lib/presentation/screens/bottom_nav/view/bottom_nav_view.dart
lib/presentation/screens/home/view/home_view.dart
lib/presentation/screens/home/logic/home_logic.dart
```

### Tasks
1. **BottomNav:** Replace Material BottomNav with floating pill (radius 22, inset 12, shadowLg), SVG icons from assets, active = brand-50 pill, 11/600 labels
2. **Home Header:** Brand row "TAARRAA" (24/800) + "តារា · Ride with trust" (km word in brand), bell icon-btn with dot indicator, language text toggle
3. **PROMO Banner:** Dark gradient card, PROMO tag pill, title, subtitle, chevron, tap → toast
4. **Search Card:** White tappable card "Where to?" with brand search icon → navigate to search
5. **Vehicle List:** Vertical list of `.veh` rows (84×52 SVG art, name, seats/price/km, from price + ETA), selected state (brand-50 bg, brand border)
6. **Loading:** 3 skeleton rows (84×52 block + text strips), 1.1s shimmer
7. **Refresh:** Manual refresh icon-btn → reload + toast

### Validation
- Home loads with skeleton → vehicles
- Tab switching works with floating pill
- Vehicle selection → Map screen
- Language toggle works
- PROMO tap shows toast

---

## Phase 5: Map + Booking + Fee + Rating + Receipt (High Risk)

**Goal:** Migrate the most complex screens.

**Duration:** 5-7 days

**Depends on:** Phase 1, Phase 2, Phase 4

### Files to Modify
```
lib/presentation/screens/map/view/map_view.dart
lib/presentation/screens/map/logic/map_logic.dart
lib/presentation/screens/map_drag/view/map_drag_view.dart
lib/presentation/screens/map_drag/logic/map_drag_logic.dart
lib/presentation/screens/booking/view/booking_map_view.dart
lib/presentation/screens/booking/logic/booking_logic.dart
lib/presentation/screens/calculate_fee/view/calculate_fee_view.dart
lib/presentation/screens/history/view/history_view.dart
lib/presentation/screens/history/logic/history_logic.dart
lib/presentation/screens/history_detail/view/history_detail_view.dart
lib/presentation/screens/history_detail/logic/history_detail_logic.dart
```

### Files to Create
```
lib/presentation/screens/rating/view/rating_view.dart          — NEW
lib/presentation/screens/rating/logic/rating_logic.dart        — NEW
lib/presentation/screens/rating/binding/rating_binding.dart    — NEW
lib/presentation/screens/receipt/view/receipt_view.dart        — NEW
lib/presentation/screens/receipt/logic/receipt_logic.dart      — NEW
lib/presentation/screens/receipt/binding/receipt_binding.dart  — NEW
```

### Tasks

#### Map Screen
1. Restructure bottom sheet: search card (no dest), pickup addr row, dest addr row (with clear), stat3 row, note field, vehicle mini row + tariff btn, Book Now
2. Tariff bottom sheet: min fee, price/km, seats + "Got it"
3. Booking overlay: white 94%, spinner, car bounce, status text, cancel btn

#### MapDrag (Search)
1. Minimap preview (170px, radius 16, shadowMd)
2. Search field with icon
3. Place result cards with distance badge
4. Tap place → set dest → back to Map + toast

#### Booking Map
1. Status pill (navy, pulse dot, 3 status texts)
2. Skip button (demo)
3. Timeline (3 steps: Accepted → Arriving → On trip)
4. Driver card (avatar, name+rating, car, plate badge)
5. Call + Safety button row (dark + ghost)
6. Cancel button (danger-ghost, hidden during On trip)
7. Dialog: "Cancel booking?" with two buttons

#### CalculateFee
1. "Trip fare" header (no back)
2. Driver row (no plate)
3. KV rows: Distance, Duration, Vehicle, Date
4. Address rows with dots
5. Total box (orange gradient, $4.85)
6. Payment badge (amber → green)
7. Simulate payment button
8. Auto-pay → Rating after 900ms

#### Rating (NEW)
1. Driver avatar (gradient, 72px)
2. "Rate your driver" title
3. Star rating (5 stars, 44px each)
4. Tag chips (Polite, Clean car, Safe driving, Fast pickup)
5. Textarea (height 76, radius 14)
6. Submit button (disabled until rating>0)
7. Submit → Receipt

#### Receipt (NEW)
1. Green check (96×96, #E6F8EF, pop animation)
2. "Thank you!" title
3. Receipt card (INV, rating, destination, amount, cash paid)
4. "Back to Home" primary button
5. "Book again" ghost button → Map

#### History
1. Segmented tabs (Completed / Cancelled) — `.tabs` style
2. History cards (havatar gradient, invoice, driver·date, amount, badge, hroute, hmeta)
3. Tap → HistoryDetail

#### History Detail
1. AppBar with invoice number
2. Minimap (200px)
3. Detail card (havatar, invoice, badge, KV rows, Cash paid)

### Validation
- Full booking flow: Home → Map → Search → Map (dest set) → Book Now → Booking → Fee → Rating → Receipt → Home
- History tab switching works
- History detail displays correctly
- All error states handled
- `flutter analyze` passes

### Risk Mitigation
- Create new screens (Rating, Receipt) first — they are independent
- Map screen: use feature flag to toggle old/new implementation
- Test booking flow end-to-end with mock data before real API

---

## Phase 6: Profile + Remaining Screens (Low Risk)

**Goal:** Migrate Profile, Terms, Contact, Announcements.

**Duration:** 2 days

**Depends on:** Phase 1, Phase 2, Phase 4

### Files to Modify
```
lib/presentation/screens/profile/view/profile_view.dart
lib/presentation/screens/profile/logic/profile_logic.dart
lib/presentation/screens/term_condition/view/term_condition_view.dart
lib/presentation/screens/contact_us/view/contact_us_view.dart
lib/presentation/screens/announcement/view/announcement_view.dart
lib/presentation/screens/announcement/logic/announcement_logic.dart
lib/presentation/screens/announcement_detail/view/announcement_detail_view.dart
```

### Tasks
1. **Profile:** Header row (h2 "Profile" + segmented lang toggle), profile card (avatar 48px + name + phone), 5 prow rows (Announcements, Saved places, Terms, Contact, Logout danger), version "1.2.1"
2. **Terms:** Numbered cards (brand-50 circle + text)
3. **Contact:** Logo badge 72px, "Taarraa Taxi · Phnom Penh", 4 contact rows (phone×2, email, address)
4. **Announcements:** News cards (title, excerpt 80 chars, date)
5. **AnnouncementDetail:** Title, date, body, image placeholder

### Validation
- Profile displays correctly
- Language toggle works
- All menu items navigate correctly
- Contact phone/email are tappable

---

## Phase Summary

| Phase | Scope | Duration | Risk |
|---|---|---|---|
| 1 | Design tokens | 1 day | Low |
| 2 | 32 components | 4-5 days | Medium |
| 3 | Auth flow (4 screens) | 2-3 days | Low |
| 4 | Nav + Home | 2-3 days | Low |
| 5 | Map + Booking + Fee + Rating + Receipt + History | 5-7 days | High |
| 6 | Profile + Remaining | 2 days | Low |
| **Total** | | **16-21 days** | |

---

## Post-Implementation

1. Remove deprecated old widgets
2. Full regression test on all 20 screens
3. Update route definitions for new screens (Rating, Receipt)
4. Update GetX bindings for new screens
5. Run `flutter analyze` — zero warnings
6. Manual QA on both EN and KM languages
