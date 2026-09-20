# pu_passenger UI Redesign — Implementation Roadmap

**Purpose:** what to implement, in what order, and how to verify each step.
**Status:** planning only. No Dart, pubspec, asset or HTML file has been changed for this
redesign (the uncommitted `map_drag/` + `app_locale.dart` changes in the tree belong to the
P-04/P-05 pickup/search work logged in the parent `../.agent/PROGRESS.md`, not to this plan).

- **Behaviour truth:** `docs/reverse-engineering/` + the Flutter source (`lib/`).
- **Visual truth:** `docs/taarraa-ui-prototype.html` and `docs/ux-redesign/` (01 design
  direction, 02 design system, 03 screen redesign, 04 component spec, 05 interaction and states).
- **Approved translation between them:** `docs/ux-redesign/07-design-decision-log.md`
  (decisions `D1`–`D18`). Open product calls are listed under **G0** as `PDD-xx`.

> **File-path note.** `docs/ux-redesign/06-implementation-plan.md` predates the
> `docs/14` structure convention and names files like `splash/view/splash_view.dart`.
> The live layout is `lib/presentation/screens/<feature>/{binding,logic,state,view}.dart`
> (see the README and `docs/reverse-engineering/01`). This roadmap uses the live paths;
> where 06 and this roadmap disagree, **this roadmap wins**.

---

## 0. Rules that apply to every task

**Change only presentation:** widgets, layout, theme, components, visual hierarchy, copy keys.

**Never change** (verify your diff against the "Never change" table before considering a
task done):

| Preserved | Lives in |
|---|---|
| Business logic: passenger booking state machine, polling policy, booking session | `screens/booking_map_screen/{logic,state,poll_policy}.dart`, `services/booking_session.dart`, `screens/map_screen/logic.dart`, `screens/map_drag/logic.dart` (<i>shared/</i>), `app/{logic,state}.dart` |
| API contracts, models, repositories, datasources | `data/datasources/`, `data/models/`, `features/{auth,profile}/data/`, `core/network/`, `core/api_service/` |
| Realtime: socket event names, payloads, emit order | `services/socket_service.dart`, `test/taxi_single_ton/` |
| Location services and reporting | `services/location_service.dart`, `service/location_imp.dart`, `data/datasources/update_passenger_location_api.dart` |
| Auth and session | `services/session_service.dart`, `core/storage/token_store.dart` |
| Routes, route arguments, bindings | `routes/app_pages.dart` |
| Translation mechanism | `translations/{app_locale,english_key,khmer_key}.dart` — both key maps must stay in sync |

**If a task appears to need a behaviour change: stop.** Mark it `REQUIRES EXPLICIT DECISION`,
add it to `docs/ux-redesign/06-implementation-plan.md §4` (or the progress file), and ship
the visual part without it.

**Working rules:**
- One task per PR. Never bundle redesign with refactoring, migration or a new feature.
- No new packages. Everything needed already exists (`flutter_svg`, `shimmer`,
  `google_maps_flutter`, `pinput`, `dio`, `socket_io_client`, `get`). The only permitted
  `pubspec.yaml` edits are asset-path lines.
- Reuse components from `docs/ux-redesign/04-component-specification.md`. Don't create a
  second button, card, sheet or dialog.
- Every screen handles loading, empty, error and offline states before it is "done".
- The light token theme lands in F1 and every screen migrates under it. S5 only deletes the
  legacy tables (`AppColors`, `ThemeConstands`).
- Currency: until `PDD-01` is answered (G0), keep today's formatter on every money
  display (`formatRielAmount` etc.). The prototype's `$` is a demo convention.
- Demo-only prototype behaviours (`D14`) are never built: splash "Skip →", booking
  "Skip ▸", "Simulate payment", "type any 4 digits", and the sidebar navigator.

**Verification tooling:**
- `dart analyze <path>` must be clean. Plain `flutter analyze` is broken in this environment.
- The pinned Flutter `3.38.9` (`.fvmrc`) is not installed. Tests and builds run in a
  **scratchpad mirror** with `~/fvm/versions/3.44.1` (has `flutter_tester`): `rsync` the
  repo minus `build`, `.dart_tool`, `.git`; `flutter pub get --offline`; then
  `flutter test --no-pub` / `flutter build apk --debug --no-pub`. Never touch
  `pubspec.lock`/`.dart_tool` in the working tree. Android Gradle defines **no flavors** —
  build without `--flavor`.
- G0 baseline artefacts are the regression oracle (see G0).

---

## 1. Gate — do this before writing any code

### G0 — Decisions and baseline

The design direction is documented and internally consistent, but **none of D1–D18 has an
explicit client sign-off**. The roadmap proceeds on the documented defaults. Four calls are
genuinely open and gate or shape the tasks they name:

| Decision | Question | Shapes |
|---|---|---|
| `PDD-01` | Recording currency: prototype is USD (`D15`), codebase formats Riel (`formatRielAmount`, `app_locale.dart` `khmerCurrency`). **Default: keep today's formatter** until product answers | C2 fare rows, C6, C7, S1 history |
| `PDD-02` | Rating + Receipt screens (`D13`): the rating **rules** exist (`screens/rate_driver/rating.dart`, N-10) but there is **no rating endpoint** (parent `.agent/DECISIONS.md` — P-11 probe-confirmed 404). **Default: build the UI; wire submit as "pending backend"**, keep Fee → Rating → Receipt → Home demo chain (`D14`) | C7 |
| `PDD-03` | Restore the announcements bell on Home and Logout on Profile — both exist as working code (`HomeLogic` bell route + `AppLogic.logout()`) but are **commented out** today. **Default: restore only with user sign-off** (it re-exposes user-facing actions) | C2, S2 |
| `PDD-04` | Splash auto-nav timing / step indicators on auth (`D11`): adds 3-dot step indicators to Login/OTP/Register. **Default: build them as specified** | S4 |

**Baseline to record before the first PR** (carried to Q2 — needs a device, a live backend
and passenger account):
1. A device video of every screen and state in `docs/ux-redesign/05-interaction-and-states.md` §1–§10.
2. The `tlog` transcript of one complete booking (request → accept → driver arrival →
   start → drop → payment). This is the socket-emit oracle every booking task is verified
   against.

---

## 2. Dependency order

```
G0  decisions + baseline
 │
F1  tokens · theme · typography
 │
F2  shared components ────────────────┐
 │                                     │
F3  sheets · dialogs · toast · states  │
 ├───────────────────────────────┐     │
C1  shell (floating pill + header)│     │
 │                               │     │
C2  home (promo, search card, vehicle list)
 │                               │     │
C3  map screen + tariff sheet + booking overlay    ← highest risk
 │                               │     │
C4  search + pickup (MapDrag) ────┤     │
 │                               │     │
C5  booking (timeline, driver card, cancel)
 │                               │     │
C6  calculate fee + payment wait  │     │
 │                               │     │
C7  rating + receipt (new screens)
 │
 ├── S1 history + detail ── S2 profile/terms/contact ── S3 announcements ── S4 auth
 │        (four independent tracks; all need F1–F3)
 │
S5  legacy token cleanup
 │
P1 motion · P2 copy/localization · P3 accessibility
 │
Q1 visual QA · Q2 functional regression · Q3 performance
```

**21 implementation tasks** (+ G0 gate). C3 → C4 → C5 → C6 → C7 is the critical path;
S1–S4 can run in parallel once F3 lands.

---

# Phase 1 — Design Foundation

## F1 — Design tokens, theme, typography

### Goal
One token source for colour, type, spacing, radius and shadow, plus the theme built from it.

### Scope
- New: `lib/core/theme/{ta_colors,ta_text_styles,ta_spacing,ta_radius,ta_shadow,ta_theme}.dart`
  per `docs/ux-redesign/06-implementation-plan.md` Phase 1 (semantic tokens per
  `02 §Colors`, 12 type roles per `02 §Typography`, 4 px spacing grid, radius + shadow scales).
- Edit: `core/theme/app_theme.dart` to consume the tokens; app entry to install the theme.
- Legacy `AppColors`/`ThemeConstands` are **marked `@Deprecated`, not deleted** (S5 removes them).

### Design References
- `docs/ux-redesign/02-design-system.md` (whole file — this task *is* that file)
- `docs/ux-redesign/07-design-decision-log.md` → `D1`–`D3`, `D8`, `D9`, `D15`, `D16`, `D17`

### Behavior References
- `docs/reverse-engineering/04-design-tokens.md` (today's tokens and the `font10SemiBold` bug)
- `core/theme/{colors,text_styles,app_theme}.dart` plus `translations/` (theme is locale-aware today)

### Dependencies
G0 (nothing blocking — `PDD-01` default keeps formatters untouched)

### Risk
**Medium.** Two unknowns: whether Kantumruy Pro renders tabular figures and whether the
variable font resolves `FontWeight.w700`/`w800` (02 §Typography documents fallbacks). Fixing
the `font10SemiBold` (14 px) naming bug while renaming into the scale is expected — keep the
**rendered size** identical until P3 re-checks contrast.

### Verification
- A debug-only token sampler screen rendered in EN and KM (device/emulator when available).
- Contrast: no normal-text pair below 4.5:1, no large-text/border pair below 3:1.
- `dart analyze lib/core/theme`.

### Done When
- Tokens exist as semantic names; no component references a primitive.
- `AppTheme` is built from tokens, installed app-wide, and no screen regresses.
- `AppColors`/`ThemeConstands` still compile untouched (removed in S5).

## F2 — Shared components

### Goal
Build the Ta- component set so no screen invents its own button, field, card or row.

### Scope
`lib/presentation/widgets/` per `04-component-specification.md` (32 components) and
`06-implementation-plan.md` Phase 2 priorities:
- Tier 1 primitives: `TaPrimaryButton`, `TaIconButton`, `TaTextField`, `TaOtpField`,
  `TaAvatar`, `TaBadge`.
- Tier 2 composites: `TaCard`, `TaSegment`, `TaStepIndicator`, `TaKvRow`, `TaSearchCard`,
  `TaSearchResult`, `TaNoteField`, `TaChip`, `TaStarRating`, `TaSkeleton`.
- Tier 3 compound: `TaAddressRow`, `TaStatRow`, `TaVehicleRow`, `TaDriverCard`,
  `TaTotalBox`, `TaPromoBanner`, `TaTimeline`, `TaStatusPill`, `TaHistoryCard`, `TaProfileRow`.
- Barrel export `widgets.dart`.

### Design References
- `docs/ux-redesign/04-component-specification.md` (props, states, press animations
  — every variant `02 §Component Radius Mapping` names)
- `docs/ux-redesign/02-design-system.md` §Colors/§Spacing/§Shape/§Icons

### Behavior References
None. These are presentational; formatters/validation stay at the call sites.

### Dependencies
F1

### Risk
**Low.**

### Verification
- Widget tests for each component's states: default, pressed, disabled, loading, error, selected.
- Touch targets ≥ 48 px (or the spec's own size), checked in the Flutter inspector.

### Done When
- Every variant in `04` renders against the tokens.
- No Ta-component owns validation or money formatting — it takes pre-formatted strings.

## F3 — Sheets, dialogs, toast, banner, state views

### Goal
Re-skin the overlay layer **without changing how any dialog dismisses or navigates.**

### Scope
- New: `TaToast`, `TaDialog`, `TaBottomSheet`, `TaLoadingOverlay`, `TaMinMaxSheet`.
- Re-skin in place, keeping signatures: `presentation/widgets/{error_dialog_widget,
  yesno_dialog_widget,g_showmodal_bottom,x_showmodal_bottom,loading_widget,loading_shimmer,
  empty_data}.dart`.

### Design References
- `04-component-specification.md` (dialog/toast/bottom-sheet entries)
- `02-design-system.md` §Elevation/Shadows, §Icons
- `05-interaction-and-states.md` §Toast, §Dialog, §Bottom Sheet, §Micro-Interactions

### Behavior References
`05-interaction-and-states.md` §Dialog/§Bottom Sheet (dismissibility, barrier, navigation per sheet).

### Dependencies
F1, F2

### Risk
**High** — the easiest place to silently break navigation.
- `showErrorCustomDialog`/`showYesNoCustomDialog`/booking-cancel dialog: keep pop counts and
  the routes that follow them byte-for-byte.
- `showDriverInfoSheet` (`map_screen/widgets/driver_info_sheet.dart`) is a free function —
  keep its signature and the tap-to-call behaviour.
- `EasyLoading.show()`/`.dismiss()` call sites (booking overlay, auth, places search) stay;
  the overlay is re-skinned only where the task scope says so.

### Verification
For each dialog/sheet: trigger on a device and confirm the route afterwards matches the G0
baseline video.

### Done When
- No call site changed.
- Dismissal, barrier behaviour and navigation are identical to the baseline.

---

# Phase 2 — Core Passenger Experience

Passenger journey, taken from the real flow (`docs/reverse-engineering/02-app-flow.md`):

```
home → map (pickup, destination, vehicle) → search/map-drag ↺
     → booking (request → driverAccepted → driverArrival → driverStartDrive)
     → calculate_fee (waits for driverAcceptPayment)
     → rating → receipt → home
```

## C1 — App shell and tab host

### Goal
Floating pill tab bar (`D4`), the shared header, and tab-host wiring.

### Scope
`screens/bottom_nav/{view,logic,binding}.dart` (the host keeps its three tabs and the
`GetPage` bindings list unchanged). Icon set per `02 §Icons` + existing `assets/nav_icon/*.svg`.

### Design References
- `03-screen-redesign.md` § Screen 5: Bottom Navigation Host
- `04-component-specification.md` (TaSegment/TaIconButton usage); `02` §Shapes (22 px radius)
- `07` → `D3`, `D4`, `D9`, `D12`

### Behavior References
- `05-interaction-and-states.md` §Tab Navigation
- `docs/reverse-engineering/02-app-flow.md` (tab stack; `/home` clearing rules)

### Dependencies
F1–F3

### Risk
**Medium.** The host has exactly **three** tabs today — Home, "My Booking" (= History),
Profile (`bottom_nav/view.dart:19-32`) — and the tab labels are the `AppLocale` keys
(`home`/`myBooking`/`profile`). The pill keeps three tabs; none is added or removed, and the
language toggle behaviour is unchanged. ("My Booking" currently uses `Icons.event` — the
calendar/list icon swap per `01-design-direction.md` is part of this task.)

### Verification
- Tab switching with the pill; each tab shows its own screen; back behaviour unchanged.
- 320 px width: pill + tab labels don't overflow at text scale 1.3.

### Done When
- The pill renders (inset 12, radius 22, `shadowLg`, active = `primaryBg` pill).
- No tab gains or loses content, and language toggle behaviour is unchanged.

## C2 — Home tab

### Goal
Header, PROMO banner, "Where to?" search card, and the vertical vehicle list replacing the
2×2 grid (`D5`).

### Scope
`screens/home/{view,logic,state}.dart`, `screens/home/widgets/` (new: `PromoBanner`,
`SearchCard`, `VehicleRow`), `core/utils/vehicle_seat_capacity.dart` (read-only reuse).

### Design References
- `03-screen-redesign.md` § Screen 6: Home
- `04-component-specification.md` (TaVehicleRow, TaPromoBanner, TaSearchCard, TaSkeleton)
- `07` → `D5`, `O2`, `O3`, `O4`, `PDD-03` (bell entry)

### Behavior References
- `05-interaction-and-states.md` §Loading States (Home skeleton), §Empty States
- `docs/reverse-engineering/03-ui-inventory.md` (home structure, `getVehicalRemoteDataSource`)

### Dependencies
C1

### Risk
**Medium.** `HomeLogic` keeps `requestBooking`/vehicle-fetch and the redirect logic
(`home/booking_redirect.dart`) untouched. The skeleton must replace `SizedBox.shrink()`
without changing when data arrives.

### Verification
- Skeleton → loaded, empty, and error states.
- Tap a vehicle row → `/map` with the same arguments as today.
- Pull-to-refresh still calls the same reload.

### Done When
- Vehicle rows show name, seats, price/km and ETA from existing model fields only.
- Bell entry point restored **only if `PDD-03` is approved**; otherwise it stays commented out.
- Busy/refresh uses the shared shimmer, not `EasyLoading` spikes.

## C3 — Map screen: bottom sheet, tariff sheet, booking overlay

### Goal
Re-skin the booking-request map: search + address rows + stat row + note + vehicle mini-row
+ Book Now in a restructured sheet; nested tariff sheet (`D7`); booking overlay (`D14`
production = real rideRequest).

### Scope
`screens/map_screen/{view,logic,state}.dart`, `map_presentation.dart`,
`widgets/{map_appbar,search_where_to_go,detail_service_dialog,driver_info_sheet}.dart`.

### Design References
- `03-screen-redesign.md` § Screen 7: Map (Booking Request); Screen 20: Design Tokens (for the sheet)
- `04-component-specification.md` (TaTextField, TaKvRow, TaNoteField, TaVehicleRow, TaMinMaxSheet)
- `07` → `D7`, `D13`, `D14`, `D15`

### Behavior References
- `05-interaction-and-states.md` §Map Loading/Error/Empty, §Booking overlay timing, §Keyboard
- `docs/reverse-engineering/02-app-flow.md` §User flows (Vehicle Selection + Booking)
- `core/utils/fare_estimate.dart`, `vehicle_seat_capacity.dart` — read-only

### Dependencies
F1–F3, C1

### Risk
**High — the highest in the project.**
- The booking trigger (`MapLogic.requestBooking`, `rideRequest` emit, spinner, driver-not-found
  dialog) is **read-only**. The redesign re-skinned the sheet and overlay only.
- `MapStack`/sheet expansion and the "drag to change pickup" affordance keep their logic.
- Tariff sheet is nested **above** the main sheet (`D7`) — keep the presenter calls.

### Verification
Against the G0 `tlog` oracle, on a device:
- set pickup + destination, open tariff, book; confirm the `rideRequest` payload is
  byte-identical to the oracle;
- driver-not-found path still shows the existing dialog and returns to a tappable state.

### Done When
- The sheet shows the spec's rows in order and collapses cleanly.
- No `rideRequest`/`rideRequestSpecificDriver` emit changed.

## C4 — Search and pickup (MapDrag)

### Goal
Re-skin the search/pin flow: minimap preview, search card, place result cards with distance
badge, and the confirm path. Much of the Screen 2/3 UI already exists (built under P-04/P-05,
uncommitted) — this task reskins it onto Ta-components and completes the minimap.

### Scope
`presentation/shared/map_drag/{view,logic,state,args,pickup_label,search_state}.dart`;
`routes/app_pages.dart` unchanged.

### Design References
- `03-screen-redesign.md` § Screen 8: Search (MapDrag)
- `04-component-specification.md` (TaSearchResult, TaTextField, TaAddressRow)
- `07` → `D18`

### Behavior References
- `05-interaction-and-states.md` §Search interactions
- `docs/reverse-engineering/02-app-flow.md` (MapDrag flow; `MapDragArgs`/`MapDragPurpose`)
- Test-pinned behaviour: `test/presentation/shared/map_drag/*` must stay green

### Dependencies
F3, C3

### Risk
**Low.** P-05 pinned the pin-commit semantics (no `LatLng(0,0)`, no stale pin) — preserve
`logic.dart` state machine; re-skin its render only.

### Verification
- Search → result rows → set destination → returns to `/map` with the same `LatLng`.
- Cancel keeps the crash-proof `if (result is! LatLng) return;` path.
- Empty/error/resolving states render.

### Done When
- The search entry point on the map uses the "Where to?" card (`C2`/`03 Screen 8`).
- Existing `map_drag` tests still pass untouched.

## C5 — Booking screen: timeline, driver card, cancel

### Goal
Status pill, driver card, 3-step timeline (`D6`), Call + Safety row, and the cancel dialog —
all re-skinned; the socket-driven state machine preserved.

### Scope
`screens/booking_map_screen/{booking_map_screen,logic,state,poll_policy}.dart` — **view only**.

### Design References
- `03-screen-redesign.md` § Screen 9: Booking (Active Ride)
- `04-component-specification.md` (TaStatusPill, TaTimeline, TaDriverCard, TaDialog)
- `07` → `D6`, `D11`, `D15`

### Behavior References
- `05-interaction-and-states.md` §Booking states
- `docs/reverse-engineering/02-app-flow.md` (socket-driven navigation; poll gating)
- `services/socket_service.dart` event contract (`test/taxi_single_ton/*`)

### Dependencies
F3, C3

### Risk
**High.**
- `BookingMapLogic.getBookingInfo()` (the socket + 10 s poll source of truth, P-09's race
  guard) is **read-only**. The timeline/cards render its state only.
- Cancel dialog (`cancel_booking_api` + `passengerCancelDrive` emit) must keep its emit order
  and navigation.
- Camera/location updates on the booking map are untouched.

### Verification
- Device: full trip against the oracle — request → accepted → arrival → start → drop; confirm
  the timeline advances only on real socket events (never on demo timers).
- Cancel in each state; confirm the wire emit + route.

### Done When
- The 3-step timeline is driven by socket stage only (`D14`).
- No change to `poll_policy.dart`, the emit order, or the P-09 race guard.

## C6 — Calculate fee and payment wait

### Goal
Receipt-style fee card, driver row, KV rows, address rows, total box (`D15` + `PDD-01`
default = today's formatter), payment badge, and the real payment wait.

### Scope
`screens/calculate_fee/{calculate_fee_screen,logic,state}.dart` — **view only**.

### Design References
- `03-screen-redesign.md` § Screen 10: Fee (CalculateFee)
- `04-component-specification.md` (TaTotalBox, TaKvRow, TaAddressRow, TaDriverCard)
- `07` → `D14` (no "Simulate payment"), `D15`

### Behavior References
- `05-interaction-and-states.md` §Fee states, §Payment
- `docs/reverse-engineering/02-app-flow.md` (payment flow; `driverAcceptPayment` socket wait)

### Dependencies
F2, C5

### Risk
**Medium.** The amount must stay `payment.amount` through the existing formatter. Auto-advance
to the next screen waits for the **real** `driverAcceptPayment` socket event — not a 900 ms
demo timer (`D14`). `CalculateFeeLogic` is read-only.

### Verification
- Both entry paths reach this screen from a live trip; the total matches the pre-change render.
- Kill the network mid-wait: the same failure path as today, no stuck spinner.

### Done When
- "Total" reads from the total box with the existing amount pipeline.
- No payment *simulation* exists.

## C7 — Rating + Receipt (new screens)

### Goal
Wire the two new prototype screens (`D13`): Rating (stars, tone-gated tags, textarea from the
existing N-10 rules) and Receipt (green check, receipt card, Back to Home / Book again).

### Scope
- New: `screens/rating/{view,logic,state,binding}.dart`, `screens/receipt/{view,logic,state,binding}.dart`.
- Routes: new `GetPage`s in `routes/app_pages.dart` (this is the one task that may add routes —
  new screens, per `03 Screen 11/12`).
- `screens/rate_driver/rating.dart` (N-10 rules) reused read-only.

### Design References
- `03-screen-redesign.md` § Screen 11: Rating, § Screen 12: Receipt
- `04-component-specification.md` (TaStarRating, TaDialog, TaPrimaryButton, TaAvatar)
- `07` → `D13`, `D14`, `D15`

### Behavior References
- `05-interaction-and-states.md` §Star pop, §Toast
- `docs/reverse-engineering/02-app-flow.md` (post-payment navigation chain)
- Rating submit: `PDD-02` — no endpoint exists. Build the UI and the rules; the submit is
  recorded as pending backend, never invented.

### Dependencies
C6; `PDD-02`

### Risk
**Medium.** New routes are the only schema change in the redesign. The chain
`Fee → Rating → Receipt → Home` must be navigable; with `PDD-02` defaulted, submitting a
rating is disabled with a clear "will connect when backend provides the endpoint" state.

### Verification
- Widget tests: star interaction, tag enabling by tone, submit gating (>0 stars), receipt rows.
- Navigation chain on device with the 5-star → Receipt → "Book again" → Home path.

### Done When
- Rating applies the N-10 tone rules (`rating.dart`: `toneFor`/`tagsForStars`, tags 4–5★
  positive / 1–3★ negative); Skip is available and unpunished.
- Receipt shows invoice, rating, destination, amount, cash-paid from existing trip data.

---

# Phase 3 — Supporting Screens

These four are independent of each other. Any order; they can run in parallel.

## S1 — History and history detail

### Goal
Segmented Completed/Cancelled tabs (`D12`), compact history cards, and the detail screen.

### Scope
`screens/history/{view,logic,state}.dart`, `screens/history/widgets/{history_card_widget,
cancelled_tab,completed_tab}.dart`, `screens/history_detail/{view,logic,state}.dart`.

### Design References
- `03-screen-redesign.md` § Screen 13: History, § Screen 14: History Detail
- `04-component-specification.md` (TaHistoryCard, TaAvatar, TaBadge, TaSegment)
- `07` → `D9`, `D12`, `D15`

### Behavior References
- `docs/reverse-engineering/02-app-flow.md` (history paging, card → detail args)
- Existing pagination rules in `logic.dart` and `x_paging_data_handler.dart` — read-only.

### Dependencies
F1–F3

### Risk
**Low.** The tap target moves to the whole card; it must pass the same history-detail args, and
cancelled trips keep their current behaviour (route box must not send a destination when none exists).

### Verification
Paging, pull-to-refresh, empty account, offline error; tap a completed and a cancelled card.

### Done When
- Completed and cancelled tabs both have real empty and error states.
- The detail screen opens with identical arguments and formatters.

## S2 — Profile, Terms, Contact

### Goal
Liven the sparse Profile (`P7`), restore Logout (`PDD-03`), and re-skin Terms + Contact.

### Scope
`screens/profile/{profile_screen,logic,state}.dart`, `screens/term_condition/{view,logic,
state}.dart`, `screens/contact_us/{view,logic,state}.dart`.

### Design References
- `03-screen-redesign.md` § Screen 15: Profile, § Screen 16: Terms, § Screen 17: Contact Us
- `04-component-specification.md` (TaProfileRow, TaCard, TaAvatar, TaSegment)
- `07` → `D12`, `D18`

### Behavior References
- `docs/reverse-engineering/02-app-flow.md` (profile load; language toggle; logout → login)
- `AppLogic.logout()` and `SessionService` — read-only.

### Dependencies
F1–F3

### Risk
**Low.**
- Logout restored **only if `PDD-03` is approved**; the `errorMessage` in profile state
  (`05-blueprint` B5) finally renders.
- Contact rows keep the `callPhone`/`sendEmail` launches.

### Verification
Profile with/without an avatar name; lang toggle; logout round-trip; terms scroll; call/email launch.

### Done When
- No commented-out logout if `PDD-03` was approved (otherwise unchanged).
- Profile menu rows navigate to the right routes.

## S3 — Announcements and announcement detail

### Goal
Re-skin the announcement list + detail (`P6`, dead bell entry from `P`/`PDD-03`).

### Scope
`screens/announcement/{view,logic,state}.dart`, `screens/announcement_detail/{view,logic,state}.dart`.

### Design References
- `03-screen-redesign.md` § Screen 18: Announcements, § Screen 19: Announcement Detail
- `04-component-specification.md` (TaCard, TaSkeleton, TaStatusPill)

### Behavior References
- `docs/reverse-engineering/02-app-flow.md` (paging; announcement detail args; FCM deep link)
- Existing `logic.dart` + `announcement_api.dart` — read-only.

### Dependencies
F1–F3

### Risk
**Low.** The FCM deep-link into the detail must keep working warm and cold; the bell entry
point is gated on `PDD-03`.

### Verification
Open the detail from an FCM tap in background and terminated states; unread styling; empty/error states.

### Done When
- The list has a true empty state, and cards show title/excerpt/date from existing fields.

## S4 — Auth: splash, login, OTP, register

### Goal
Re-skin the four auth screens with step indicators (`D11`), language segment, and Pinput styling.

### Scope
`screens/splash_screen/{view,logic,state}.dart`, `screens/login/{view,logic,state}.dart`,
`screens/otp/{view,logic}.dart`, `screens/register/{view,logic,state}.dart`.

### Design References
- `03-screen-redesign.md` § Screen 1: Splash, § Screen 2: Login, § Screen 3: OTP, § Screen 4: Register
- `04-component-specification.md` (TaTextField, TaOtpField, TaStepIndicator, TaSegment)
- `07` → `D11`, `D12`, `D14` (no Skip on splash; no demo OTP), `D18`

### Behavior References
- `05-interaction-and-states.md` §Auth Flow
- `docs/reverse-engineering/02-app-flow.md` (startup, `SessionService`, OTP redirect rules)
- Validation quirks pinned in `register/view.dart:171` + `register/logic.dart:47`:
  Register submit is disabled unless `passengerName != '' && profileImage != null`
  (if that contradicts the parent `.agent/RULES.md` quirk note, the code wins); the empty-name
  timestamp auto-generation in `logic.dart:50` is only a defensive path at submit time.
  Login phone rule and OTP auto-submit (`otp/view.dart:84-96`, 4 × Pinput `onCompleted`) — preserve.

### Dependencies
F1–F3

### Risk
**Medium** — validation quirks are easy to "fix" by accident:
- Login phone rule, OTP auto-submit on 4th digit, resend countdown — preserve exactly.
- Register's `canSubmit` rule and the name auto-generation — preserve.
- `debug_auth_bypass` (`core/utils/debug_auth_bypass.dart`) keeps working.

### Verification
- `test/presentation/screens/...auth tests` stay green.
- Manual: empty phone, short phone, formatted phone with spaces, wrong OTP, resend, register enable/disable.

### Done When
- Validation behaviour is identical to the baseline; OTP still auto-submits on the 4th digit.

## S5 — Legacy token cleanup

### Goal
Delete the superseded style tables now that every screen uses tokens.

### Scope
`core/theme/*` — remove `AppColors`, `ThemeConstands` and superseded members, plus superseded
legacy widgets (`x_text_field`, `fbtn_widget`, `x_button`, `x_showmodal_bottom`,
`g_showmodal_bottom`, etc. — each verified to have no remaining importer first).

### Design References
`07` → `D1`–`D18` (the token system is the whole point)

### Behavior References
None.

### Dependencies
**All of C1–C7 and S1–S4.**

### Risk
**Medium.** ~307 `Colors.*` literals and ~111 `ThemeConstands`-style references today
(`05-redesign-blueprint.md` Part B §3); stragglers surface as off-palette greys/oranges.

### Verification
`grep -rn 'Colors\.\|Color(0x\|ThemeConstands\|AppTextStyles' lib/presentation` returns
nothing meaningful, then walk every screen in both locales.

### Done When
- `AppColors`/`ThemeConstands` are deleted rather than left commented out.
- No screen references a legacy colour or text style.

---

# Phase 4 — Polish

## P1 — Motion and micro-interactions

### Goal
Apply the motion spec and honour reduced motion.

### Scope
Transitions in the F2–F3 components and the map/booking stage changes.

### Design References
`docs/ux-redesign/02-design-system.md` §Animations, `05-interaction-and-states.md` §Micro-Interactions

### Behavior References
None.

### Dependencies
S5

### Risk
**Low.** Note the driver-app lesson: an `AnimationController` that also *is* a real timer
(e.g. any OTP countdown or auto-dismiss) must use `AnimationBehavior.preserve` so OS
"remove animations" doesn't fire it at 5% speed. Check the OTP countdown and the booking
auto-dismiss paths for this.

### Verification
Enable "Remove animations" in OS accessibility settings: pulses stop, sheets/dialogs fade only.

### Done When
Nothing animates longer than ~300 ms except the map camera; no real-time timer is an
`AnimationController` with the default behavior.

## P2 — Copy and localization sweep

### Goal
Add the new keys in EN and KM and remove remaining hardcoded English.

### Scope
`translations/{app_locale,english_key,khmer_key}.dart` — **both maps must stay synchronized
and keyed identically**; call sites per `05-interaction-and-states.md` §Toast/§empty-state copy.

### Design References
`02-design-system.md` §Typography (per-locale line heights), prototype copy in `03`

### Behavior References
`docs/reverse-engineering/04-design-tokens.md` §Typography; `05` §Accessibility §Localization

### Dependencies
The screen tasks that introduce each key.

### Risk
**Medium.** Passenger translations are Dart maps, not JSON — a key added to one map but not
the other is a silent fallback-to-literal bug. A test should pin identical key sets.

### Verification
Run the app fully in KM at text scale 1.3; native Khmer review for drafted strings
(the driver's `docs/l10n-km-review.md` pattern if this grows).

### Done When
No hardcoded user-facing English remains on the redesigned screens; EN/KM key sets are identical.

## P3 — Accessibility pass

### Goal
Labels, targets and contrast verified on real screens.

### Scope
All redesigned screens.

### Design References
`docs/ux-redesign/02-design-system.md` §1.2, §13; `05-interaction-and-states.md` §Accessibility

### Behavior References
None.

### Dependencies
S5

### Risk
**Low.** Known baseline items: brand primary `#FF4500` on white is disputed — the design docs
disagree with each other (`05-redesign-blueprint.md`: ~3.9:1; `05-interaction-and-states.md`
§Accessibility: 4.52:1 "AA large text") and both sit above/down from ~3.4:1 by WCAG math, so
its real AA standing for normal text is decided by measurement in this pass (resolve the
discrepancy, trust neither figure); map markers carry no labels; text scale is clamped
[1.0, 1.3] in `root_main.dart`.

### Verification
TalkBack/VoiceOver through the full booking flow; every icon-only button announces a label;
no target under 48 px; no text under 12 px; contrast pairs from the F1 audit re-measured on
their real fills.

### Done When
The booking flow is completable with a screen reader, and nothing clips at the 1.3 scale cap.

---

# Phase 5 — QA

## Q1 — Visual QA against the prototype

### Goal
Confirm the Flutter UI matches the target direction.

### Scope
Every redesigned screen (17 existing + Rating + Receipt).

### Design References
`docs/taarraa-ui-prototype.html` (open in a browser at ~400 px wide), `03-screen-redesign.md`

### Behavior References
None.

### Dependencies
S5, P1–P3

### Risk
**Low.**

### Verification
Side-by-side screenshots per screen; spacing, radius, type scale and state colours. Any
deliberate divergence must already be a `D-xx`/`PDD-xx` entry — if it isn't, it's a bug.

### Done When
Every screen in `03-screen-redesign.md` has a side-by-side pair, and divergences trace to decisions.

## Q2 — Functional regression

### Goal
Prove no behaviour changed.

### Scope
Whole app, on a real device with the live backend.

### Design References
None.

### Behavior References
`docs/ux-redesign/05-interaction-and-states.md` (this is the test plan), G0 baseline video + `tlog` oracle

### Dependencies
S5

### Risk
**High** if skipped — this task catches everything else.

### Verification
| Area | Cases |
|---|---|
| Booking lifecycle | full trip request → accept → arrive → start → drop → payment; cancel at each stage; driver-not-found |
| Realtime | socket emits vs the G0 oracle; buffered emits on reconnect (test `taxi_single_ton/*`) |
| Network failure | REST failure at every booking action; offline/error states on history and announcements |
| Location / GPS | permission denied then granted; GPS off mid-booking; pickup pin integrity |
| Navigation | search → set destination → back; FCM deep links cold and warm; `/home` stack clearing |
| Session | 401 still logs out and clears session (`api_exception.dart` `endsSession`); 403 does not |

### Done When
Every row is ticked with evidence and the full test suite passes in the mirror.

## Q3 — Performance review

### Goal
Confirm the redesign didn't make the map screens heavier.

### Scope
Home and booking/map screens.

### Design References
None.

### Behavior References
None.

### Dependencies
Q1, Q2

### Risk
**Low.**

### Verification
DevTools on a mid-range Android: frame timings while panning the map with the bottom sheet
collapsed/expanded; scan for rebuild storms around the socket-triggered booking state.

### Done When
No sustained jank above 16 ms on the booking screen, and memory is stable across a full trip.

---

## Appendix — Known issues deliberately out of scope

Found during analysis of `docs/reverse-engineering/05-redesign-blueprint.md` Part B and the
parent `.agent/`. Each needs its own decision, PR and tests — not part of the redesign.

| ID | Issue |
|---|---|
| B1 | Two HTTP stacks coexist (`ApiClient` + legacy `BaseApiService`) — migration is P-12/P-13 territory, already partially done |
| B2 | Dead route constants `MYBOOKING`/`WHERETOGO` (and `/home` as a routable tab) |
| B3 | Text scale clamped [1.0, 1.3] — product call to widen |
| B4 | No rating endpoint and no wallet/withdraw route on the passenger side (parent Q-4, P-11) |
| B5 | `rate_driver/rating.dart` rules exist but the screen was never wired (this redesign wires the screen; the endpoint is `PDD-02`) |
| B6 | Legacy `storages/` SharedPreferences helpers coexist with `FlutterSecureStorage` — bridge/removal is separate |
| B7 | Two bottom-sheet implementations (`g_showmodal_bottom`/`x_showmodal_bottom`) — consolidated by F3's re-skin, delete the survivor in S5 |
| B8 | Announcement bell and Profile logout commented out (`PDD-03`) |
| B9 | Server-sent messages (e.g. OTP errors) are English — needs backend localization or error codes |

---

## Decision / Change Log

- 2026-09-14 — Created this roadmap (the passenger counterpart of `pu_driver/docs/roadmap.md`).
  Derived 21 implementation tasks from `docs/ux-redesign/01–07` and the parent `.agent` state.
  Task IDs (F1–F3, C1–C7, S1–S5, P1–P3, Q1–Q3) are new and tracked in
  `docs/IMPLEMENTATION_PROGRESS.md`. No application source modified by this change.