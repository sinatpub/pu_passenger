# Phase 4 — Rebuild and Redesign Blueprint

---

## PART A — Current Application Blueprint

### Screen-by-Screen Specification

| Screen | Purpose | Key Components | Data Required | User Actions | Navigation |
|---|---|---|---|---|---|
| **Splash** | Branding + auth gate | Logo image, brand text | Token (SessionService) | None (auto) | → LOGIN or BOTTOMNAV |
| **Login** | Phone number input | Phone field (+855), Next button, lang toggle | None | Enter phone, toggle lang, submit | → OTP |
| **OTP** | 4-digit verification | Pinput, countdown timer, resend button | OTP data, phone number | Enter OTP, resend | → REGISTER or BOTTOMNAV |
| **Register** | Complete profile | Name input, photo upload, Create/Skip | Profile photo (optional), name | Enter name, upload photo, create/skip | → BOTTOMNAV |
| **BottomNav** | Tab host (3 tabs) | BottomNavigationBar, 3 pages | — | Switch tabs | Hosts Home/History/Profile |
| **Home** | Vehicle selection | 2x2 grid + center VIP circle | Vehicle types (API) | Tap vehicle, pull refresh | → MAP |
| **Map** | Pickup + destination + booking | GoogleMap, search bar, bottom sheet, booking overlay | Vehicle ID, location, destination | Drag map, search, book | → DRAGMAP, → BOOKING |
| **MapDrag** | Location search/pin | Search field, GoogleMap, confirm button | Search query, map position | Search, drag, confirm | → returns LatLng |
| **BookingMap** | Active ride tracking | GoogleMap, driver info sheet, status text | Booking data (poll/socket) | Phone call, cancel | → CALCULATEFEE |
| **CalculateFee** | Fare display | Driver info, fare breakdown, total price | Booking/payment data | None (read-only) | → BOTTOMNAV |
| **History** | Booking history tabs | TabBar, PagedListView, history cards | History list (API) | Tap card, scroll, refresh | → HISTORYDETAIL |
| **HistoryDetail** | Single history with map | Card + GoogleMap + polyline | History item (Datum) | None (read-only) | ← back |
| **Profile** | User profile + settings | Profile info, menu items, lang toggle | Profile data (API) | Toggle lang, tap menu | → TERMCONDITION, CONTACTUS |
| **TermCondition** | Static terms | ListView of 5 terms | None | Scroll | ← back |
| **ContactUs** | Company info | Logo, phone, email, address | None | Tap phone/email | External apps |
| **Announcement** | Announcement list | PagedListView, cards | Announcements (API) | Tap card, scroll | → ANNOUNCEMENTDETAIL |
| **AnnouncementDetail** | Single announcement | Title, description, image list | Announcement data (API) | Scroll images | ← back |

---

## PART B — Redesign Opportunities

### 1. Inconsistent UI Patterns

**Evidence:**
- Vehicle cards in Home use `AppColors.main.withOpacity(0.8)` for background (`home/view.dart`), while buttons use full `AppColors.main`
- History cards use inline shadow: `BoxShadow(color: rgba(0,0,0,0.05))`, text fields use `rgba(0,0,0,0.25)`, and `DecoratedInputBorder` uses `rgba(96,96,96,0.17)` — three different shadow specs
- Bottom sheets have two implementations: `gShowModalBottomSheet` and `xShowModalBottomSheet` with slightly different theming
- Loading states use three different patterns: `EasyLoading.show()`, `LoadingWidget` (full-screen overlay), and inline `CircularProgressIndicator`

**Recommendation:** Consolidate to a single shadow scale, single loading pattern, and single bottom sheet component.

### 2. Duplicated Components

**Evidence:**
- `g_showmodal_bottom.dart` and `x_showmodal_bottom.dart` are nearly identical (18px top corners, drag handle, same animation). Only difference: theme color source.
- `LoadingShimmer` and `ShimmerCardBoardWidget` serve overlapping purposes.
- Two full-screen loading patterns: `LoadingWidget` and `EasyLoading`.

**Recommendation:** Merge into single bottom sheet component with theme-aware colors. Merge shimmer components.

### 3. Hard-Coded Visual Values

**Evidence:**
- Spacing values scattered across screens: 8, 10, 12, 16, 18, 28, 32, 38, 48 — no central spacing scale
- Font sizes defined in `ThemeConstands` but many screens also inline `TextStyle(fontSize: ..., fontWeight: ...)` directly
- Colors in widgets: error dialog uses `Colors.red` directly instead of `AppColors.error`, Yes button uses `Colors.red` instead of `AppColors.main`
- `font10SemiBold` is actually 14pt — naming bug (`text_styles.dart:29-30`)

**Recommendation:** Create a formal spacing scale (4/8/12/16/24/32/48). Replace all inline styles with named tokens. Fix `font10SemiBold` bug.

### 4. Inconsistent Navigation Patterns

**Evidence:**
- Some screens use `Get.toNamed` (push), others use `Get.offNamed` (replace), and critical transitions use `Get.offAllNamed` (clear stack) — but the choices are inconsistent
- History tab registration: `HistoryBinding` is empty; `HistoryLogic` is registered manually in `view.dart` with `Get.put(..., permanent: true)` — inconsistent with all other screens
- BottomNav registers 4 bindings (`BottomNavBinding`, `HomeBinding`, `HistoryBinding`, `ProfileBinding`) as a list — but `HomeBinding` and `HistoryBinding` already have standalone `GetPage` entries
- No formal route guards — auth check is embedded in `SplashLogic._checkAuthorization()`

**Recommendation:** Standardize DI registration pattern (all in bindings, none manual). Add formal route middleware for auth.

### 5. Missing States

**Evidence:**
- `CalculateFeeScreen`: no empty state, no error state — only loading and success
- `HistoryDetail`: no loading state, no error state — assumes data always present via arguments
- `Profile`: `errorMessage` exists in state but is not shown in the view
- `AnnouncementDetail`: no loading or error state in view
- `TermCondition`, `ContactUs`: no loading states (static content, acceptable)
- Home: loading state is `SizedBox.shrink()` — invisible loading, poor UX

**Recommendation:** Add error states to all data-fetching screens. Replace invisible loading on Home with shimmer skeleton.

### 6. Unclear User Flows

**Evidence:**
- Announcements: bell button on Home is **commented out** — users have no visible entry point to announcements
- Rating: `rating.dart` exists as a library but has no screen, no datasource, no route — dead feature
- Logout: button is **commented out** on Profile screen — but `AppLogic.logout()` exists and works
- `BOTTOMNAV` route is defined in `AppPages` but `HomeScreen` is only accessible as a tab — the standalone `/home` route may confuse future developers
- `MYBOOKING` and `WHERETOGO` route constants exist in `AppRoutes` but have no corresponding `GetPage` entries — dead routes

**Recommendation:** Remove dead routes. Uncomment/restore announcement entry. Add logout button to Profile. Remove rating library or build it out.

### 7. Dead Routes

**Evidence:**
- `AppRoutes.MYBOOKING` — defined but no `GetPage` mapping
- `AppRoutes.WHERETOGO` — defined but no `GetPage` mapping
- `AppRoutes.HOME` — has `GetPage` but never navigated to directly (Home is a tab widget, not a route destination)

**Recommendation:** Remove `MYBOOKING` and `WHERETOGO` constants. Clarify `HOME` route purpose or remove it.

### 8. Unused Components

**Evidence:**
- `rate_driver/rating.dart` — complete rating library with no consumers
- Multiple marker PNGs in `assets/marker/` (e.g., `rickshaw_marker01.png`, `suv_icon.png`, `suv_marker_icon.png`, `classis_car.png`, `car_marker.png`) appear unused
- Flag assets for Laos, Thailand, UK, Vietnam exist but only EN/KM language toggle is implemented
- `FlutterSwitch` package declared but no toggle switch found in active screens

**Recommendation:** Audit and remove unused assets. Remove or implement `FlutterSwitch`. Decide on flag assets.

### 9. Accessibility Concerns

**Evidence:**
- Text scale is clamped to `1.0–1.3` in `root_main.dart` — limits accessibility for visually impaired users
- No semantic labels on map markers or interactive elements
- Color contrast: `AppColors.main` (#FF4500) on white has a contrast ratio of ~3.9:1 — below WCAG AA (4.5:1) for normal text
- No `Semantics` widgets found in any screen
- Vehicle cards rely solely on image + color — no text labels for screen readers
- Phone numbers in Contact Us are `ListTile` with `onTap` but no explicit `Semantics` label

**Recommendation:** Increase text scale range. Add Semantics labels to interactive elements. Improve color contrast for primary color on white backgrounds. Add alt text to images.

### 10. Areas Needing Modernization

**Evidence:**
- Two HTTP stacks coexist (`ApiClient` + `BaseApiService`) — migration incomplete
- Legacy `SharedPreferences` blob coexists with `FlutterSecureStorage` — migration bridge needed
- `storages/` directory with raw SharedPreferences helpers is legacy code
- No error boundary widget (Crashlytics catches crashes but no user-facing recovery)
- No retry mechanism for failed API calls in screens
- No offline handling or connectivity checks (commented out `connectivity_plus`)

---

## PART C — Design System Migration Strategy

### Current Implementation Summary

| Aspect | Current | Issues |
|---|---|---|
| Theme | `AppTheme.lightTheme` (Material 3) | No dark theme, minimal configuration |
| Colors | `AppColors` (20 static colors) | Hard-coded hex values, some unused |
| Typography | `ThemeConstands` (19 named styles) | 2 weights only, `font10SemiBold` bug, no line heights |
| Spacing | `.d` extension (diagonal-based) | No scale, values scattered |
| Radius | Per-component (8-18) | No scale |
| Shadows | Per-component (3+ variants) | Inconsistent |
| Components | 20 widgets in `presentation/widgets/` | Mixed quality, some duplicated |

### Proposed Semantic Token Structure

```
Primitive Tokens          Semantic Tokens              Component Tokens
─────────────────        ──────────────────            ──────────────────
colors:                  surfaces:                     button.primary.bg:
  brand-500 #FF4500  →    primary     = brand-500         = semantic.surfaces.primary
  brand-600 #CC3700  →    on-primary  = white              button.primary.text:
  brand-400 #FFA84C  →    surface     = neutral-50         = semantic.colors.on-primary
  neutral-900 #000   →    on-surface  = neutral-900        button.primary.radius:
  neutral-700 #6B7588→    error       = red-700            = semantic.radii.md
  ...                    ...                           ...

font-sizes:              text:                          card.radius:
  xs=12, sm=14, md=16     heading-lg = font-bold/28      = semantic.radii.lg
  lg=20, xl=24, 2xl=28    body-md    = font-regular/16   card.shadow:
                           caption    = font-regular/12    = semantic.shadows.sm

spacings:                layout:
  4, 8, 12, 16, 24, 32     screen-padding = spacings.lg
  48, 64                    section-gap     = spacings.xl
                            component-gap   = spacings.md

radii:                   radii:
  sm=8, md=12, lg=16        sm, md, lg, xl(full)
  xl=18, full=999

shadows:                 shadows:
  sm: blur5/offset2          sm, md, lg
  md: blur10/offset4
  lg: blur14/offset4
```

### Migration Map (Old → New)

| Old Token/Value | New Semantic Token | Notes |
|---|---|---|
| `AppColors.main` | `AppColors.brand[500]` or `colorScheme.primary` | Preserve semantic name |
| `AppColors.light4` | `colorScheme.surface` | Scaffold background |
| `AppColors.error` | `colorScheme.error` | Already mapped |
| `font16Regular` | `AppTextStyles.bodyMedium` | Rename for clarity |
| `font20SemiBold` | `AppTextStyles.titleLarge` | Use Material 3 naming |
| `28..d` | `AppSpacing.xl` | Replace diagonal-based with fixed scale |
| `12` (card radius) | `AppRadii.md` | Centralize |
| `18` (bottom sheet) | `AppRadii.xl` | Centralize |
| Inline `Colors.red` | `AppColors.error` or `colorScheme.error` | Standardize |

### Rules for Migration

1. **Preserve existing semantic token names** where they align with Material 3 (`primary`, `error`, `surface`)
2. **Map old values to new semantic tokens** — no silent value changes
3. **Separate primitive from semantic** — primitives are raw values, semantics are usage-based
4. **Do not change business logic** — only presentation layer
5. **Keep `KantumruyPro` as primary font** — no font changes during re-skin
6. **Keep `AppColors.main` brand color** — extend with proper shade scale, don't replace

---

## PART D — Rebuild Order

### Stage 1: Design Foundations (Week 1)

**What:** Color system, typography scale, spacing scale, radii, shadows, theme configuration

**Why first:** Every subsequent screen and component depends on these tokens. Establishing them first ensures consistency from the start.

**Dependencies:** None

**Expected UX Impact:** Visual foundation for all screens. No user-facing changes yet.

**Key Tasks:**
- Extend `AppColors` with a proper shade scale (50-900)
- Fix `font10SemiBold` bug (14pt → 10pt or rename to `font14SemiBold`)
- Add line heights to text styles
- Create `AppSpacing`, `AppRadii`, `AppShadows` classes
- Add dark theme support (optional — can defer)
- Update `AppTheme` to use new tokens

---

### Stage 2: Shared Components (Week 1-2)

**What:** Refactor and unify the 20 reusable widgets in `presentation/widgets/`

**Why second:** All screens depend on these. Unifying them first prevents rework.

**Dependencies:** Stage 1 (design tokens)

**Expected UX Impact:** Consistent button styles, inputs, loading states, dialogs across all screens.

**Key Tasks:**
- Merge `gShowModalBottomSheet` and `xShowModalBottomSheet` into one
- Merge `LoadingShimmer` and `ShimmerCardBoardWidget`
- Standardize loading patterns (choose one: EasyLoading or LoadingWidget)
- Update `FBTNWidget` to use new spacing/radius tokens
- Update `XTextField` and `getTextFieldDecoration` to use new tokens
- Update `XNetworkImage` to use new loading/error patterns
- Update dialogs (`showErrorCustomDialog`, `showYesNoCustomDialog`) to use semantic colors
- Add `Semantics` labels to interactive components

---

### Stage 3: Authentication / Onboarding (Week 2)

**What:** Splash, Login, OTP, Register screens

**Why third:** First user touchpoint. Must feel polished. Also validates design system in real use.

**Dependencies:** Stage 1, Stage 2

**Expected UX Impact:** First impression improvement. Consistent auth flow.

**Key Tasks:**
- Update Splash to use design tokens (logo, text, background)
- Refactor Login form with new spacing and input styles
- Refactor OTP screen with new Pinput styling
- Refactor Register screen with new upload card and form styles
- Add proper loading/error states
- Verify EN/KM translations render correctly with new typography
- Add Semantics for accessibility

---

### Stage 4: Main Navigation Shell (Week 2-3)

**What:** BottomNav, Home screen

**Why fourth:** Navigation shell is the backbone. Home is the most visible screen.

**Dependencies:** Stage 1, Stage 2

**Expected UX Impact:** Vehicle grid becomes the visual centerpiece. Navigation feels modern.

**Key Tasks:**
- Update BottomNavigationBar styling (icons, labels, active color)
- Redesign Home vehicle grid with new card styles
- Add shimmer skeleton loading (replace `SizedBox.shrink()`)
- Update header with new typography tokens
- Fix dead announcement entry point
- Add Pull-to-refresh styling

---

### Stage 5: Core Booking Journey (Week 3-4)

**What:** Map, MapDrag, BookingMap, CalculateFee

**Why fifth:** This is the core user journey. Most complex screens. Benefits from all prior work.

**Dependencies:** Stage 1-4

**Expected UX Impact:** The primary booking flow looks and feels professional.

**Key Tasks:**
- Update Map bottom sheet with new card/typography tokens
- Refactor MapDrag search UI with new input, results, and map styles
- Update BookingMap driver info sheet
- Update CalculateFee breakdown with new card/typography styles
- Standardize map marker styling
- Add loading/error states to CalculateFee
- Improve map interaction affordances

---

### Stage 6: Secondary Features (Week 4)

**What:** History, HistoryDetail, Profile, TermCondition, ContactUs

**Why sixth:** Lower frequency screens. Important but not blocking core journey.

**Dependencies:** Stage 1-4

**Expected UX Impact:** Complete, consistent experience across all screens.

**Key Tasks:**
- Update History cards with new tokens
- Add error state to HistoryDetail
- Fix Profile missing error display
- Add logout button to Profile (currently commented out)
- Update TermCondition and ContactUs with new typography
- Unify list item styles

---

### Stage 7: Edge States and Polish (Week 5)

**What:** Error handling, loading patterns, accessibility, animations

**Why last:** Refinement pass that benefits from all prior work being stable.

**Dependencies:** Stage 1-6

**Expected UX Impact:** Professional-grade polish. Better error recovery. Accessibility improvements.

**Key Tasks:**
- Add `Semantics` labels to all interactive elements
- Add error boundary widget for graceful crash recovery
- Standardize all loading states (shimmer, spinner, overlay)
- Improve color contrast (primary on white)
- Add retry mechanisms to failed API calls
- Implement offline/connectivity state handling
- Animation polish (transitions, micro-interactions)
- Remove dead code: unused routes (`MYBOOKING`, `WHERETOGO`), dead assets, `FlutterSwitch`
- Text scale range improvement (currently 1.0-1.3, suggest 0.8-1.5)
- Audit and remove unused marker PNGs and flag assets
