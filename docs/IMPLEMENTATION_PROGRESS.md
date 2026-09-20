# pu_passenger UI Redesign — Implementation Progress

Single source of truth for current implementation progress. What must be implemented lives in
`docs/roadmap.md`; this file tracks what is actually done — and nothing is marked done unless
its verification criteria pass.

## Current Status

- Overall Progress: **17 / 22** tasks DONE (G0 decision half + F1–F3 + C1–C7 + S1–S5 + P1–P2)
- Overall Status: **IN PROGRESS**
- Current Phase: Phase 4 — Polish
- Current Task: **P3 — Accessibility pass** `[>]`
- Next Task: P3 — Accessibility pass

## Verification Standard

- `dart analyze <path>` must be clean (plain `flutter analyze` is broken in this environment).
- Tests/builds run in the **scratchpad mirror** with `~/fvm/versions/3.44.1`
  (mirror the repo via `rsync`, `flutter pub get --offline`, `flutter test --no-pub` /
  `flutter build apk --debug --no-pub`). Never use `--flavor` (no Android flavors).
- Any check that could not actually run here is recorded as **device/backend — carried to Q2**,
  never claimed as a pass.
- Baseline artefacts required for regression are the G0 video + `tlog` booking oracle
  (roadmap G0).

## Blockers

- **G0 baseline not recorded `[!]`** — needs a device, a live backend and role accounts.
- **Open decisions** (roadmap G0, each with a documented default so individual tasks can proceed):
  - `PDD-01` Recording currency (default: keep today's formatter)
  - `PDD-02` Rating/receipt endpoint absent (default: build UI, submit pending backend)
  - ~~`PDD-03` Restore bell + logout~~ — **RESOLVED 2026-09-19** by explicit user
    sign-off: **Logout restored** on Profile (S2); the **bell stays commented**, as there
    is no notifications screen for it to open.
  - `PDD-04` Auth step indicators (default: build as specified)
- **Khmer copy is unreviewed `[!]`** — every KM string added across C2–C7 and S1–S4 was
  drafted during implementation, not reviewed by a native speaker. P2's Verification asks
  for one (the driver app's `docs/l10n-km-review.md` is the pattern). Key *coverage* is now
  enforced by `test/translations/key_parity_test.dart`; *quality* is not.
- **Role test accounts** do not exist (shared parent `.agent` limitation) — blocks every
  device verification behind login and the full-trip oracle.

## Progress Summary

| Phase | Done | Total | Status |
|---|---|---|---|
| Gate | 0 | 1 | PARTIAL — decision half recorded; baseline blocked |
| Phase 1 — Design Foundation | 3 | 3 | DONE |
| Phase 2 — Core Experience | 7 | 7 | DONE |
| Phase 3 — Supporting Screens | 5 | 5 | DONE |
| Phase 4 — Polish | 2 | 3 | IN PROGRESS (P3 next) |
| Phase 5 — QA | 0 | 3 | NOT STARTED |
| **Total** | **17** | **22** | **IN PROGRESS** |

## Task Status

Checkbox legend: `[ ]` TODO · `[>]` IN PROGRESS · `[x]` DONE · `[!]` BLOCKED / NEEDS FIX ·
`[Q]` code-complete awaiting review.

### Gate

- `[>]` **G0 — Decisions and baseline.** Decision half recorded 2026-09-15: the four open
  product calls were accepted on the documented defaults (`PDD-01` keep today's currency
  formatter · `PDD-02` build rating/receipt UI, submit pending backend · `PDD-03` bell+logout
  stay commented until explicit user sign-off · `PDD-04` auth step indicators build as
  specified), via the audit go-ahead. The **baseline** half (`[!]` device-video + `tlog`
  booking oracle) still needs a device, a live backend and role accounts — carried to Q2.

### Phase 1 — Design Foundation

- `[x]` F1 — Design tokens, theme, typography (`lib/core/theme/ta_*.dart`)

  **Done 2026-09-15.** Created `ta_colors.dart` (27 semantic colors from `02 §Colors`),
  `ta_text_styles.dart` (12 type roles per `02 §Typography`, `KantumruyPro` variable font
  with `wght` FontVariation), `ta_spacing.dart` (16 values), `ta_radius.dart` (6 radius
  tokens), `ta_shadow.dart` (3 shadow levels), `ta_theme.dart` (`TaTheme.lightTheme` built
  only from tokens). `app_theme.dart` is now a `@Deprecated` alias delegating to
  `TaTheme.lightTheme`; `AppColors`/`AppTextStyles`/`ThemeConstands` marked `@Deprecated`
  (removal is S5); `root_main.dart` installs `TaTheme.lightTheme`.
  **Verified:** `dart analyze lib/core/theme` → No issues ✓ · app-wide `dart analyze lib`
  → 0 errors / 0 warnings (276 `deprecated_member_use` infos are the expected legacy-token
  annotations) ✓ · compile gate `flutter build apk --debug --no-pub` in the scratchpad
  mirror → `app-debug.apk` built ✓ · token sampler + contrast pairs are device checks →
  **carried to Q2**. Pre-existing repo quirk noted: stale gitignored
  `ios/Flutter/Generated.xcconfig` still points `FLUTTER_TARGET` at the removed
  `lib/main1.dart`, so mirror builds need `--target lib/main.dart` (unrelated to this task).
- `[x]` F2 — Shared components (`lib/presentation/widgets/`, 32 per `04-component-specification.md`)

  **Done 2026-09-15.** Built all 32 components against the tokens — Tier 1 primitives
  (`ta_button`, `ta_icon_button`, `ta_text_field`, `ta_otp_field`, `ta_avatar`, `ta_badge`),
  Tier 2 composites (`ta_card`, `ta_segment`, `ta_step_indicator`, `ta_kv_row`,
  `ta_search_card`, `ta_search_result`, `ta_note_field`, `ta_chip`, `ta_star_rating`,
  `ta_skeleton`), Tier 3 compound (`ta_address_row`, `ta_stat_row`, `ta_vehicle_row`,
  `ta_driver_card`, `ta_total_box`, `ta_promo_banner`, `ta_timeline`, `ta_status_pill`,
  `ta_history_card`, `ta_profile_row`), the F3 scaffold components (`ta_dialog`,
  `ta_bottom_sheet`, `ta_toast`, `ta_loading_overlay`, `ta_minimax_sheet`), `ta_bottom_nav`
  and the barrel `widgets.dart`. Data models (VehicleData/StatItem/HistoryItem) live next to
  their components; every component is presentational (pre-formatted strings, no validation,
  no money formatting — roadmap F2 Done When). Small internal helper `ta_pressable.dart`
  (press-scale `0.97/100ms`) added — not on the documented file list, noted as a deviation.
  **Verified:** `dart analyze lib/presentation/widgets test/presentation/widgets` → clean
  (all `ta_*.dart` files: No issues) ✓ · widget tests for every component covering default /
  pressed / disabled / loading / error / selected states (`test/presentation/widgets/
  ta_components_test.dart`, 43 tests) → **262/262 pass** in mirror (incl. full pre-existing
  suite) ✓ · compile gate `flutter build apk --debug --no-pub --target lib/main.dart`
  (mirror, required due to pre-existing stale iOS `FLUTTER_TARGET`) → built ✓ · touch targets:
  large button 52px, OTP boxes 64px, avatars ≥44px; small button (44px), icon button (42px),
  stars (44px) follow the spec's own sizes (roadmap allows "the spec's own size") — spot-check
  with the inspector is **carried to Q3**.
- `[x]` F3 — Sheets, dialogs, toast, state views (re-skinned in place, signatures kept)

  **Done 2026-09-15.** New overlay primitives existed from F2 (`TaToast`/`TaDialog`/
  `TaBottomSheet`/`TaLoadingOverlay`/`TaMinMaxSheet`); this task re-skinned the legacy
  overlay layer **in place** — signatures and dismissal/navigation semantics unchanged:
  `error_dialog_widget.dart` (`showErrorCustomDialog` → `TaDialog.show` + primary retry
  `TaButton` with loading state; `showGetXErrorCustomDialog` → `Get.dialog` +
  `TaDialogCard`, ghost cancel + primary retry), `yesno_dialog_widget.dart`
  (`showYesNoCustomDialog` → `TaDialog.show`, ghost "No" + primary "Yes"/ghost "OK",
  `Get.back()`/`onYes` sequencing preserved), `g_showmodal_bottom.dart` +
  `x_showmodal_bottom.dart` (22px top radius, `TaGrabHandle` 44×5, `TaColors.overlay`
  backdrop, 300ms easeInOutCubic; draggable sheet behavior kept),
  `loading_widget.dart` (94% white overlay + 64px brand spinner), `loading_shimmer.dart`
  (token shimmer #EDEEF2→#F7F7FA at 1.1s on white `shadowSm` radius-16 cards; API
  incl. `.list`/`.grid` factories unchanged), `empty_data.dart` (muted icon + centered
  muted message). `TaDialog.show` gained a `barrierDismissible` parameter (default
  `false`); `TaGrabHandle` exported from `ta_bottom_sheet.dart` to share the spec grab
  handle. AppLocale `.tr` strings and `Get`/`Get.back()` usage preserved.
  **Verified:** `dart analyze lib/presentation/widgets` → all F3 + `ta_*` files clean
  (remaining 6 issues are pre-existing legacy `x_*.dart`/`card_atta_widget.dart`) ✓ ·
  full suite **262/262 pass** in mirror (incl. the 43 component tests) ✓ · compile gate
  `flutter build apk --debug --no-pub --target lib/main.dart` (mirror) → built ✓ ·
  app-wide `dart analyze lib test` → 0 errors, 0 new warnings (remaining warnings/infos
  are pre-existing legacy files, out of scope until the C/S tasks touch them). Device-only
  look-and-feel of the re-skinned overlays → **carried to Q2**. Also verified up-front that
  all 7 re-skin targets' call sites (google_map_logic, logic, login/otp/register,
  driver_info_sheet, x_paged_child_builder_delegate) keep working unchanged.

### Phase 2 — Core Passenger Experience

- `[x]` C1 — Shell: floating pill tab host (`screens/bottom_nav/`)

  **Done 2026-09-15.** `bottom_nav/view.dart` swapped the Material
  `BottomNavigationBar` for the F2 floating pill `TaBottomNav` (inset 12, radius
  22, `shadowLg`, active = `primaryBg` pill). Tab icons follow `03 §Screen 5` +
  the existing `assets/nav_icon/*.svg` iconset: Home `home.svg` /
  `home-angle-2-svgrepo-com.svg`, My Booking `book_outline.svg` / `book.svg`
  (this replaces the old `Icons.event` per `01 P9` / `02 §Icons`), Profile
  `profile.svg` / `profile_fill.svg`. Active tab is tinted `TaColors.primary`
  via `SvgPicture.colorFilter`; inactive keeps the asset's own muted color.
  `TaNavItem` gained optional `activeIcon`/`inactiveIcon` widget fields (the
  `IconData` fallback keeps `ta_components_test.dart` green). `logic.dart` and
  `binding.dart` untouched — the host keeps exactly three tabs (Home / My
  Booking / Profile) and the `GetPage` binding list unchanged.
  **Verified:** `dart analyze lib/presentation/screens/bottom_nav
  lib/presentation/widgets/ta_bottom_nav.dart` → No issues ✓ · new C1 tests
  (`test/presentation/screens/bottom_nav_test.dart`: pill renders all three
  labels at 320 px width + text scale 1.3 without overflow, honours
  `currentIndex`, reports taps via `onChanged`) → **265/265 full suite pass** in
  mirror ✓ · compile gate `flutter build apk --debug --no-pub --target
  lib/main.dart` (mirror) → built ✓ · host-on-device checks — pill tab
  switching showing each screen, unchanged back behaviour, language toggle,
  real-font overflow at scale 1.3 — **carried to Q2/Q1** (HomeScreen requires
  app DI + network, so the host itself is not pumped in the widget suite).
- `[x]` C2 — Home: header, promo banner, search card, vertical vehicle list (`screens/home/`)

  **Done 2026-09-15.** `home/view.dart` rewritten to `03 §Screen 6`: `TaColors.background`
  canvas, brand header (TAARRAA 24/800 + "Ride with trust" tagline with 'តារា' in primary;
  KM word shows in the Khmer locale), language toggle `TaIconButton` ('ខ្មែរ'/'EN' →
  `appLogic.toggleLanguage`), bell kept commented (PDD-03), `TaPromoBanner` (FLY20, tap →
  "Promo applied" toast), `TaSearchCard` ("Where to?" → `/map`), "Choose your ride" section
  header with 36 px refresh (reload + "Refreshed" toast), 3× `TaSkeletonCard` shimmer rows
  while loading/error, `TaVehicleRow` list when loaded, `EmptyData` when the list is empty.
  Vehicle cell data derives from the **existing model fields only** per Done When: name;
  seats from `seatCapacityForVehicleId`; price per km / "from" (KHR via `toMoneyFormat()` +
  `khmerCurrency`, PDD-01; "from —" when `miniMunFare` is missing; ETA via the new
  deterministic `etaMinutesForVehicleId`/`formatEtaMinutes` helpers in
  `core/utils/vehicle_seat_capacity.dart` — the backend exposes no ETA). Tap row →
  `/map` with `arguments: {'vehicleId': id}` as today. `home/logic.dart` `getVehicleType()`
  dropped EasyLoading (the shared shimmer drives busy/refresh per Done When), sets success
  unconditionally, and catch → `RxStatus.error()` + `TaToast("Something went wrong")`;
  `requestBooking`/`checkingBookingStatus`/`booking_redirect` untouched. New AppLocale keys
  added to `english_key.dart`/`khmer_key.dart` (`whereTo`, `chooseYourRide`, `refreshed`,
  `promoApplied`, `promoTag`, `promoTitle`, `promoSubtitle`, `rideWithTrust`,
  `somethingWentWrong`, `noVehicleAvailable`). `EmptyData` added to the `widgets.dart` barrel.
  **Verified:** `dart analyze lib/presentation/screens/home lib/core/utils/vehicle_seat_capacity.dart
  lib/translations test/core/utils/vehicle_seat_capacity_test.dart test/presentation/screens/home/home_screen_test.dart`
  → No issues ✓ · new tests: ETA helpers (`vehicle_seat_capacity_test.dart`) + HomeScreen
  state widget tests (`home_screen_test.dart`, light `HomeLogic`/`AppLogic` harnesses via
  `Get.put` covering loading → skeleton, loaded → rows with name/seats/1,500 ៛/km + ETA,
  error → skeleton, empty → `EmptyData`) → **272/272 full suite pass** in mirror (265 + 7)
  ✓ · compile gate `flutter build apk --debug --no-pub --target lib/main.dart` (mirror) →
  built ✓. Device-only: real-font overflow at scale 1.3, promo/refresh toasts on-device,
  pull-to-refresh feel, row tap → map on-device, tagline KM-word rendering nuance (KM word
  only in Khmer locale) → **carried to Q1/Q2**.
- `[x]` C3 — Map: bottom sheet, tariff sheet, booking overlay (`screens/map_screen/`) — highest risk

  **Done 2026-09-15.** `view.dart` rebuilt to `03 §Screen 7`. Top-right stays the `MapAppbar`
  ("My Location" pill + back → `/home`, `TaColors.primary`, `shadowMd`), locate FAB
  (`TaIconButton` my_location, `ta_colors` primary), center pin while no destination. The
  **bottom sheet** (`widgets/map_bottom_sheet.dart`, extracted so it pumps without the
  GoogleMap platform view) renders in spec order: `TaGrabHandle`; `SearchWhereToGo`
  (`TaSearchCard` "Where to go?" → `/map_drag`, P-05 downcast kept); pickup `TaAddressRow`
  (`currentLocation`/current address); when destination set — Divider, destination
  `TaAddressRow` + clear X, `TaStatRow` (distance + fare in `toMoneyFormat()` KHR, PDD-01),
  `TaNoteField` (note text → `MapState.note`, presentational only); Divider; compact
  `TaVehicleRow` + tariff pill → `openTariffSheet` = the nested **D7** `TaMinMaxSheet.open`
  ("Vehicle · Tariff", Min fee / Price per km / Seats, "Got it"); `TaButton` "Booking Now"
  enabled only with a destination (else `selectDestinationToContinue` hint). Content is
  `ConstrainedBox(maxHeight 0.55 × screen)` + scroll so small screens cannot overflow.
  **Booking overlay** (`widgets/booking_loading_overlay.dart`): `TaLoadingOverlay`
  (94 % white, brand spinner + bouncing car, D14 production text "Contacting nearby
  drivers…" + chosen vehicle · nearest-driver km via the new pure
  `nearestDriverDistanceKm`/haversine in `map_presentation.dart`, cancel → `cancelBooking`)
  — kept under `MapUpdate.bookingID`; `onCameraIdle` pickup-drag flow, `onMapCreated`
  markers/camera and the `requestBooking`→`rideRequest` emit path are unchanged (Done When).
  `MapLogic` gained only `noteController` + `onClose` dispose. `driver_info_sheet.dart`
  intentionally untouched (its host sheet was re-skinned at F3). New AppLocale keys
  (`contactingDrivers`, `kmAway`, `destination`, `selectDestinationToContinue`) in all three
  translation files. Home's `_toVehicleData` extracted to shared
  `core/utils/vehicle_cell_data.dart` (`vehicleCellData`) so Home + Map cell formatting
  cannot drift.
  **Verified:** `dart analyze lib/presentation/screens/map_screen lib/presentation/screens/home
  lib/core/utils/vehicle_cell_data.dart lib/translations test/presentation/screens/map_screen
  test/core/utils/vehicle_cell_data_test.dart` → No issues ✓ · new tests
  (`test/core/utils/vehicle_cell_data_test.dart` + `test/presentation/screens/map_screen/map_screen_test.dart`:
  `_MapLogicHarness` no-super onReady/getAvailableDriver/getVehicleTypeSelection/cancelBooking;
  no-dest sheet, dest sheet rows, tariff sheet, overlay title/subtitle, cancel drops overlay)
  → **281/281 full suite pass** in mirror (272 + 9) ✓ · compile gate `flutter build apk
  --debug --no-pub --target lib/main.dart` (mirror) → built ✓. Device-only: map look &
  feel (markers, gestures), real-font overflow, overlay visuals, `requestBooking` wiring
  against the live backend → **carried to Q1/Q2**. Build lesson: `flutter build` must use
  `~/fvm/versions/3.44.1/bin/flutter` — the PATH `flutter` (3.38.1) mixed with FLUTTER_ROOT
  (3.44.1) breaks the AOT kernel strictly.
- `[x]` C4 — Search + pickup (MapDrag) (`presentation/shared/map_drag/`)

  **Done 2026-09-15.** `map_drag/view.dart` re-skinned to `03 §Screen 8` with the D18
  minimal app bar (TaIconButton back `arrow_back_ios_new` + title 17/700, `setPickup` /
  new `setDestination` by `MapDragPurpose`), a `TaTextField` search row (search icon +
  "Search for a place", autofocus per §Search, onChanged → `fetchPlaceSuggestions`,
  `textInputAction.done`) shown only while in results view, and the new **`SearchPanel`**
  (`widgets/search_panel.dart`) over the live map — the panel is a content-sized white
  card (radius 22 top, `shadowLg`, capped at half screen) switching on
  `logic.searchStatus` (idle/belowThreshold → hint; searching no prior → shimmer skeleton
  (`toShimmer`), searching with prior → prior rows dimmed at 0.4; error → wifi_off +
  "Couldn't search right now" + Retry → `fetchPlaceSuggestions`; empty → search_off +
  `No places match "xyz"` + "Check the spelling" + Set on map; results → `TaSearchResult`
  rows via `splitPlaceDescription` name/keyword + "Set location on the map" row). The
  pick/confirm path is preserved: tapping a row sets the field + `selectedPrediction` +
  `selectPlace` (pops `/map` with the same `LatLng`), the confirm `TaButton`
  (`purpose.confirmLabel`, enabled via `canConfirmPickup(logic.pickupConfirm)` /
  `logic.hasPin`) still `Get.back(result: logic.state.latlng)`, and cancel keeps the
  `if (result is! LatLng) return;` guard in `map_screen`. Pin/commit composition restored
  exactly (`Positioned.fill → IgnorePointer → Center → Stack{pickup callout bottom:72,
  AnimatedSlide pin}`); the pickup flow's reverse-geocode pipeline + driver-note
  `TaNoteField` above the confirm button are untouched. **Deviation** (PROGRESS-mandated):
  Screen 8's 170 px minimap preview requires a static-map asset that does not exist — the
  live map stays behind the results (pin-commit semantics P-05 preserved); visual parity
  carried to Q2. **Deviation:** placeline responses carry no `distance` field, so
  `TaSearchResult.distance` became optional and the badge is omitted rather than faked.
  New AppLocale keys (`setDestination`, `searchForPlace`; `setPickup` was pre-existing in
  `app_locale.dart` but never in the key files — swept in P2). Note-field's 60-char
  display cap dropped (TaNoteField has no `inputFormatters`); `normaliseDriverNote` still
  caps the payload.
  **Verified:** `dart analyze lib/presentation/shared/map_drag lib/presentation/widgets/ta_search_result.dart
  lib/translations test/presentation/shared/map_drag` → No issues ✓ · new tests
  (`test/presentation/shared/map_drag/search_panel_test.dart`: `_HarnessLogic`
  overriding `selectPlace`/`fetchPlaceSuggestions` — results render name/keyword without a
  distance badge, tap → selectPlace + field text, Set-on-map → `isShowMap`, idle hint,
  searching dim/skeleton, empty "No places match", error Retry re-run) while the pinned
  `args/logic/pickup_label/search_state` tests pass **untouched** → **289/289 full suite
  pass** in mirror (281 + 8) ✓ · compile gate `flutter build apk --debug --no-pub --target
  lib/main.dart` (mirror) → built ✓. Device-only (Q1/Q2): search → result → set-destination
  round trip against the live backend, keyboard/autofocus behaviour, minimap visual parity,
  real-font overflow.
- `[x]` C5 — Booking: timeline, driver card, cancel (`screens/booking_map_screen/`)

  **Done 2026-09-19.** `booking_map_screen.dart` rebuilt to `03 §Screen 9`: the map now
  fills the screen in a `Stack` (it was squeezed into a `Column` above a
  `bottomNavigationBar` panel), with the `TaStatusPill` floating at the top and the new
  **`widgets/booking_sheet.dart`** docked at the bottom — extracted as C3 did with
  `MapBottomSheet` so the whole phase table pumps without the GoogleMap platform view.
  The sheet renders, in spec order: `TaGrabHandle`; the D6 3-step `TaTimeline`;
  `TaDriverCard` (name / vehicle / plate / initials); the Call + Safety row
  (`TaButton` dark + ghost, Safety → `TaToast` "coming soon"); and the `dangerGhost`
  cancel button, hidden at phase 2 per §States. Google's own map controls are off and
  the map is bottom-padded clear of the sheet. Per `D14` the prototype's "Skip ▸" button
  and 17s auto-advance are **not** implemented — production advances on real socket
  events only.
  New pure helpers, both socket-stage-driven: `bookingPhaseFromStatus(int?)`
  (`accepted→0 · arrival→1 · onGoing→2`, every other status clamped to 0 so a transient
  or terminal booking cannot show a false final step) and `bookingStatusText(phase)`,
  kept beside it so the pill and the timeline cannot disagree. Both read `data.status` —
  never `appLogic.titleEvent`. New shared `core/utils/initials.dart`
  (`initialsFromName`) splits on grapheme clusters so a Khmer name keeps its combining
  marks; extracted rather than inlined because C6's fee card and S1's history card render
  the same avatar. New `.tr` keys `stepAccepted`/`stepArriving`/`stepOnTrip` in all three
  translation files (the rest of the Screen 9 keys were already present).
  Two view-level judgement calls, both recorded: **Call greys out when the booking has no
  driver phone** rather than launching an empty `tel:`; and **a failed cancel keeps the
  passenger on the ride** (toast only) — `logic.cancelBooking()`'s own contract says the
  view navigates only on `true`, and leaving a booking the backend still considers live
  would strand the passenger with no way back to it. The toast is raised *before*
  `offAllNamed` because it lives in the navigator's overlay, which survives the route
  swap, while the sheet's context does not.
  **Preserved untouched** (roadmap C5 Risk): `logic.dart`, `state.dart`, `poll_policy.dart`,
  `binding.dart`, `getBookingInfo()`'s P-09 race guard, the bounded-poll policy, the
  `cancel_booking_api` → `passengerCancelDrive` emit order, `PopScope(canPop: false)`, and
  all camera/marker/polyline work.
  **Verified:** `dart analyze lib/presentation/screens/booking_map_screen
  lib/core/utils/initials.dart lib/translations lib/routes test/presentation/screens/booking_map_screen
  test/core/utils/initials_test.dart` → clean (the one remaining info is the pre-existing
  `AppColors` polyline deprecation in `logic.dart:263`, which is S5's legacy-token cleanup
  and out of C5's view-only scope) ✓ · app-wide `dart analyze lib test` → **0 errors,
  0 warnings** (227 infos, all pre-existing legacy-token annotations) ✓ · new tests
  (`test/core/utils/initials_test.dart`, 8 · `test/presentation/screens/booking_map_screen/
  booking_sheet_test.dart`, 18: the full phase table, pill/timeline agreement, driver-card
  fields, the no-driver-attached degrade, Call enable/disable, Safety toast, and all four
  cancel paths — dialog opens without calling the API, "Keep waiting" cancels nothing,
  confirm calls the API + emits + toasts + lands on the shell stub, failure toasts and
  stays) while `logic_test.dart` and `poll_policy_test.dart` pass **untouched** →
  **315/315 full suite pass** in mirror (289 + 26) ✓ · compile gate `flutter build apk
  --debug --no-pub --target lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: the full-trip oracle (request → accepted → arrival →
  start → drop) confirming the timeline advances only on real socket events, cancel in each
  state against the live backend, map look and feel with the new full-bleed layout, and
  real-font overflow at scale 1.3.
- `[x]` C6 — Calculate fee + payment wait (`screens/calculate_fee/`)

  **Done 2026-09-19.** `calculate_fee_screen.dart` rebuilt to `03 §Screen 10` and converted
  from a `StatefulWidget` that `Get.put`-ed its own controller to a `StatelessWidget` that
  `Get.find`s the one the route's `CalculateFeeBinding` already provides. Layout: centered
  "Trip fare" header with no back button; the new **`widgets/fee_card.dart`** (`TaCard` →
  `TaDriverCard` with no rating and no plate, Divider, `TaKVRow` ×4 for Distance / Duration /
  Vehicle / Date, Divider, pickup + destination `TaAddressRow`s); `TaTotalBox`; and the
  payment-wait `TaBadge`. `FeeLoadingView` replaces the bare `CircularProgressIndicator`
  with a receipt-shaped shimmer so the layout does not jump when the fare lands. Per `D14`
  the "Simulate: driver confirms payment" button and the 9s auto-pay are **not** built —
  the screen waits for the real `driverAcceptPayment` socket event, which
  `PassengerSocketService` already routes to `CalculateFeeLogic.syncNavigateBack()`; a
  regression test asserts the screen renders no button at all.
  New pure `core/utils/fee_presentation.dart` applies the payload policy: **`feeAmount`
  fails loudly** — an absent or unparseable `payment.amount` returns null and the view shows
  an explicit "Fare unavailable" card instead of a `TaTotalBox`, never a zero or a raw
  string the passenger might pay against — while **`feeDisplayValue`/`feeDateTime` degrade**
  to an em dash. Currency stays KHR via `toMoneyFormat()` + `khmerCurrency` (`PDD-01`;
  `D15`'s USD is superseded for this app). New `.tr` keys `tripFare`/`vehicle`/`pickup`/
  `fareUnavailable` in all three translation files.
  **Two pre-existing bugs fixed on the way through, both presentation:** the route summary
  printed `endAddress` in *both* rows, so the pickup line showed the destination; and
  `formatDateTime(data.startTime)` passed a `dynamic` straight into a `String` parameter
  with no try/catch, so a null, numeric or ISO `start_time` threw and took the whole fee
  screen down — `feeDateTime` now parses defensively.
  **Preserved untouched** (roadmap C6 Risk): `logic.dart` (incl. `getCalculateFeeApi` and
  `syncNavigateBack`), `state.dart`, `binding.dart`, and the socket payment path.
  **Open, recorded rather than guessed:** the spec's "Payment confirmed ✓" success badge is
  not rendered. It would need a `payment.status` mapping the backend does not document and
  that nothing else in either app reads; in production the screen is left the instant the
  driver confirms, so only the waiting badge is reachable. Revisit if a contract appears.
  **Verified:** `dart analyze lib/presentation/screens/calculate_fee
  lib/core/utils/fee_presentation.dart lib/translations test/presentation/screens/calculate_fee
  test/core/utils/fee_presentation_test.dart` → No issues ✓ · app-wide `dart analyze lib test`
  → **0 errors, 0 warnings** (195 infos, down from 227 — the fee screen's legacy-token uses
  are gone) ✓ · new tests (`test/core/utils/fee_presentation_test.dart`, 13 ·
  `test/presentation/screens/calculate_fee/fee_screen_test.dart`, 13: driver row without
  rating/plate, the four KV rows, pickup/destination reading their own fields, an
  all-null payload degrading, a null booking, the fare + method label, the plain-total
  fallback, unparseable and missing fares showing "fare unavailable", the waiting badge,
  the absence of any demo button, and the shimmer) → **341/341 full suite pass** in mirror
  (315 + 26) ✓ · compile gate `flutter build apk --debug --no-pub --target lib/main.dart`
  (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: the fee screen against a real completed trip, the
  `driverAcceptPayment` hand-off out of the screen, real-font overflow at scale 1.3, and
  the Khmer copy for the new keys.
- `[x]` C7 — Rating + receipt (new screens `screens/rating/`, `screens/receipt/`, new routes)

  **Done 2026-09-19.** New `screens/rating/{view,logic,state,binding}.dart` and
  `screens/receipt/{view,logic,state,binding}.dart`, plus the redesign's only schema change:
  `AppRoutes.RATING` / `AppRoutes.RECEIPT` and their `GetPage`s. The post-payment chain is
  now `Fee → Rating → Receipt → Home`.
  **Spec conflict resolved by the user (2026-09-19).** `screens/rate_driver/rating.dart`
  (N-10, commit `a8bcb39`) and `03 §Screen 11` disagreed on the tag set
  (`Clean/On time/Friendly/Good route` vs `Polite/Clean car/Safe driving/Fast pickup`), on
  tag visibility (after a star, tone-gated vs always shown), on Skip (required vs absent)
  and on the ending ("No thank-you screen" vs Screen 12). **Decision: the N-10 module
  governs the rules and C7 only skins it; the flow does end at the Receipt screen.** This
  matches roadmap C7's own Done When. The ux-redesign chip labels are treated as prototype
  placeholders. `rate_driver/rating.dart` is reused **read-only** — the single edit is a
  doc-comment note recording that its "no thank-you screen" navigation line is superseded;
  every rule in it is unchanged and its 168-line test file passes untouched.
  **Rating (Screen 11):** `TaAvatar` + "Rate your driver", the prompt naming the driver
  (dropping the name rather than rendering "with ?" — N-10 `promptDriverName`),
  `TaStarRating`, tone-gated `TaChip`s (none before a star; the four positive tags at 4–5★;
  none at 1–3★ because N-10 names no negative tags and the wording of a complaint about a
  driver is not invented here), `TaNoteField`, an always-available ghost **Skip**, and a
  `Submit` gated on `canSubmit`. Changing 5★→2★ clears tags chosen for the 5.
  **`PDD-02` — there is no rating endpoint.** Nothing is invented: no datasource, no
  request. Submitting builds a `PendingRating` through the N-10 rules and queues it
  (`enqueueRating`, one per booking, latest wins), and the screen says so plainly
  ("saved and will be sent once ratings go live"). The queue is what drains into the
  endpoint when one exists.
  **Receipt (Screen 12):** animated success check (`pop2` curve), "Thank you!", the receipt
  card (invoice / rating / destination + amount / paid), and Back to Home + Book again.
  Rows the backend did not fill are dropped rather than shown empty — no invoice id means
  no `INV-null` row, a skipped rating shows an em dash instead of a score the passenger
  never gave, and no payment method drops the paid row. `PopScope(canPop: false)` keeps
  Back off the already-answered rating screen.
  **New `rating_prompt_store.dart`** persists which bookings were rated *or skipped* so
  `shouldPromptForRating` can hold: re-asking after a skip is exactly the punishment N-10
  forbids, and a passenger who force-quits on the rating screen is the likeliest to be
  re-asked. Both outcomes share one set — the rule treats them identically, and storing
  *why* would invite reading it as "this passenger refuses to rate". Bounded to 50 ids;
  every read/write is failure-tolerant so storage can never block the post-trip flow.
  **`CalculateFeeLogic.syncNavigateBack()` changed** (the one logic edit, and the task the
  roadmap sanctions for it — C7's behaviour reference is the post-payment navigation
  chain): it now routes to `RATING` when `shouldPromptForRating` says to, and to
  `BOTTOMNAV` otherwise. The 2s settle, the socket re-init and the `offAll` semantics are
  unchanged. A booking with no id goes home rather than being asked about a trip that
  cannot be recorded. `CalculateFeeLogic` gained an injectable `RatingPromptStore` so that
  choice is testable.
  New `.tr` keys in all three translation files (`rateYourDriver`, `howWasYourTrip`,
  `howWasYourTripWith`, `ratingPendingBackend`, the four `tag*`, `thankYou`,
  `tripCompleteReceiptSent`, `backToHome`, `bookAgain`, `paid`, `submit`); `skip` and
  `addNoteForDriver` already existed and were reused.
  **Caught and fixed during verification:** the "fare unavailable" sentence was being
  passed as a `TaKVRow` value and overflowed the row by 369px — `TaKVRow` takes short
  pre-formatted values, so the explanation moved below the card.
  **Verified:** `dart analyze lib/presentation/screens/rating lib/presentation/screens/receipt
  lib/presentation/screens/calculate_fee lib/routes lib/translations
  test/presentation/screens/rating test/presentation/screens/receipt` → No issues ✓ ·
  app-wide `dart analyze lib test` → **0 errors, 0 warnings** (195 infos, all pre-existing
  legacy-token annotations) ✓ · new tests (`rating_screen_test.dart`, 14 ·
  `receipt_screen_test.dart`, 12: the full tone table, 5★→2★ tag clearing, chip toggle,
  submit gating, queue-not-send + one-per-booking, Skip queueing nothing and marking the
  trip handled, the unnamed-driver degrade, the PDD-02 notice, star/invoice formatting,
  every dropped-row case, and both exits) while the N-10 `rate_driver/rating_test.dart`
  passes **untouched** → **367/367 full suite pass** in mirror (341 + 26) ✓ · compile gate
  `flutter build apk --debug --no-pub --target lib/main.dart` (mirror) → `app-debug.apk`
  built ✓.
  Device-only → **carried to Q1/Q2**: the 5★ → Receipt → "Book again" → Home chain against
  a real completed trip, the `driverAcceptPayment` → Rating hand-off, star-pop and
  success-check motion, real-font overflow at scale 1.3, and the Khmer copy for the new keys.

### Phase 3 — Supporting Screens

- `[x]` S1 — History and history detail (`screens/history/`, `screens/history_detail/`)

  **Done 2026-09-19.** `history/view.dart` rebuilt to `03 §Screen 13`: the Material
  `AppBar` + `TabBar` gives way to a plain header and the `TaSegment` pill. The
  `TabController` stays the source of truth — `HistoryLogic.switchTabBarController` (filter
  swap + paging refresh) is still driven by its listener, untouched; the segment only moves
  the controller's index, and an `AnimatedBuilder` keeps the pill in step with swipes as
  well as taps. `history_detail/view.dart` rebuilt to `03 §Screen 14`: back button +
  invoice header, a 200px clipped/shadowed route preview, then the detail card (driver row,
  status badge, KV rows, address rows).
  **`completed_tab.dart` and `cancelled_tab.dart` were byte-identical** apart from a stray
  `withOpacity(.1)` / `withAlpha(10)` on a background the redesign drops. Both read the
  *same* paging controller, so duplicating them only risked drift — they are replaced by one
  `widgets/history_tab.dart` where `isCompleted` selects the empty-state copy, the only
  thing that genuinely differed. The 313-line `history_card_widget.dart` (a full detail view
  rendered per row, map placeholder included) is replaced by the compact `TaHistoryCard`.
  New pure `core/utils/history_cell_data.dart` holds every formatting and degrade rule, so a
  card and its detail screen cannot disagree (roadmap S1: "identical arguments and
  formatters") — the same split as `vehicle_cell_data.dart` (C3) and `fee_presentation.dart`
  (C6). The payload policy holds: the amount fails loudly (`—`, never a zero), everything
  else degrades.
  **Three real defects fixed:**
  1. **`TaHistoryCard.onTap` was declared but never wired** — no `InkWell`, no
     `GestureDetector`. The whole-card tap target S1 moves to would have silently done
     nothing. Now wrapped in `TaPressable`.
  2. **`HistoryItem.to` was required**, so a cancelled trip with no destination printed
     "Unknown" as if one had been chosen. It is now nullable and the row is dropped —
     directly the roadmap's S1 Risk note ("must not send a destination when none exists").
  3. **`DateTime.parse("${data?.createdAt}")` was unguarded** in the old card, so one
     unparseable timestamp threw and took the whole list down. `historyDate` now parses
     defensively.
  `TaHistoryCard` also gained an optional `statusLabel` so the badge is localised instead of
  hardcoded English (the same kind of additive component change C1 made to `TaNavItem`);
  the default keeps the spec wording and the existing F2 component tests pass untouched.
  **Both tabs now have real empty and error states** (S1 Done When) — they previously fell
  through to the shared delegate's defaults, so an empty account and a failed fetch looked
  identical. Completed and cancelled get their own empty copy; the error state explains and
  offers Retry; first-page load shows skeleton cards. New `.tr` keys `noCompletedTrips`,
  `noCancelledTrips`, `couldNotLoadHistory` in all three translation files.
  **Preserved untouched:** `history/logic.dart` and `state.dart` (paging, P-12's `pageNo`
  fix, the filter/tab switch), `history_detail/logic.dart` and `state.dart` (markers,
  polyline, camera), `binding.dart`, `x_paging_data_handler.dart`,
  `x_paged_child_builder_delegate.dart`, and the `Datum` argument passed to the detail route.
  **Verified:** `dart analyze lib/presentation/screens/history
  lib/presentation/screens/history_detail lib/core/utils/history_cell_data.dart
  lib/presentation/widgets/ta_history_card.dart lib/translations lib/routes
  test/presentation/screens/history test/core/utils/history_cell_data_test.dart` → No issues
  ✓ · app-wide `dart analyze lib test` → **0 errors, 0 warnings** (127 infos, down from 195
  — the three deleted legacy widgets took their deprecated-token uses with them) ✓ · new
  tests (`history_cell_data_test.dart`, 15 · `history_widgets_test.dart`, 12: invoice and
  date degrades, the no-destination case, money failing loudly, the completed/cancelled
  badge and label, whole-card tap reaching the detail route **with the same `Datum`**, both
  empty states, the error state's retry, and the detail card's rows) while the existing F2
  `ta_components_test.dart` `TaHistoryCard` tests pass **untouched** → **394/394 full suite
  pass** in mirror (367 + 27) ✓ · compile gate `flutter build apk --debug --no-pub --target
  lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: paging past page 1, pull-to-refresh feel, an empty
  account and an offline fetch against the live backend, tapping a completed and a cancelled
  card, the detail route preview rendering, and real-font overflow at scale 1.3.
- `[x]` S2 — Profile, Terms, Contact (`screens/profile/`, `screens/term_condition/`, `screens/contact_us/`)

  **Done 2026-09-19.** All three screens rebuilt to `03 §Screen 15/16/17`.
  **`PDD-03` resolved by the user (2026-09-19): restore Logout only.** The Profile screen's
  commented-out logout block becomes a real `TaProfileRow(isDanger: true)` calling
  `AppLogic.logout()` — which already raises its own confirm dialog (re-skinned at F3) and
  owns the token clear and the route to login, so the row only calls it and `AppLogic` stays
  read-only. The **Home header bell stays commented**: there is no notifications screen for
  it to open, and the Announcements screen is reachable from the Profile menu instead.
  **Profile (Screen 15):** header with the language flag `IconButton` replaced by the spec's
  `TaSegment` (`EN` / `ខ្មែរ`) — still driving `AppLogic.toggleLanguage`, and only calling it
  when the tap actually changes the language, since that method flips rather than sets. Then
  the profile card (avatar, name, phone), the `TaProfileRow` menu (Announcements → the
  existing route, Saved places → toast as the spec asks since no such feature exists, Terms,
  Contact, Log out) and the version label.
  **`state.errorMessage` finally renders** (roadmap S2 Risk / `05-blueprint` B5). P-14 added
  the error path but nothing displayed it, so a failed profile fetch showed an empty card
  with no explanation; it now shows the message and a Retry that re-runs `getProfile()`.
  Loading shows a skeleton.
  **The version is read through the existing `installedAppVersion()`**, not hardcoded to the
  spec's "1.2.1" — a stale version string on a support screen is worse than none — and
  renders nothing at all if the platform channel fails.
  **Terms (Screen 16):** numbered cards with the brand-tinted index badge. The legal copy is
  **unchanged**; S2 re-skins how it is presented, not what it says. The list moved to a
  top-level `kTermsAndConditions` const so a test can assert it is untouched.
  **Contact (Screen 17):** back + title row, the 72px gradient brand badge, and
  `TaProfileRow`s for both phone numbers, the email and the address. The **`tel:`/`mailto:`
  launches are kept exactly as they were** (roadmap S2 Risk) — the spec's "→ toast" is
  prototype behaviour, since a prototype cannot place a call. The address row is not tappable
  and carries no chevron. The company's **real** address is kept, not the spec's placeholder.
  `ProfileScreen`, `TermConditionPage` and `ContactUsPage` are now `const`-constructible
  (`ProfileScreen` resolves its controllers in `build` rather than in fields), which the
  bottom-nav host already assumed.
  New `.tr` keys `savedPlaces`, `savedPlacesComingSoon`, `version`, `taarraaPhnomPenh` in all
  three translation files.
  **Preserved untouched:** `profile/logic.dart` and `state.dart`, `AppLogic.logout()` and
  `toggleLanguage`, `SessionService`, the terms/contact logic and state, and all bindings.
  **Verified:** `dart analyze lib/presentation/screens/profile
  lib/presentation/screens/term_condition lib/presentation/screens/contact_us lib/routes
  lib/presentation/screens/bottom_nav lib/translations test/presentation/screens/profile`
  → No issues ✓ · app-wide `dart analyze lib test` → **0 errors, 0 warnings** (114 infos,
  down from 127) ✓ · new tests (`profile_screen_test.dart`, 15: phone formatting and its
  degrades, name/phone/initials rendering, the no-phone and no-name cases, **the error state
  rendering and its retry re-fetching**, the version label showing the installed version and
  hiding when unavailable, every term rendering with unchanged copy, the contact rows, the
  address row being untappable, and the phone/email rows keeping their launch handlers) →
  **409/409 full suite pass** in mirror (394 + 15) ✓ · compile gate `flutter build apk
  --debug --no-pub --target lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: the logout round-trip against a live session, the
  language toggle re-rendering the app, `tel:`/`mailto:` actually launching, a profile with
  and without an avatar image, terms scrolling, and real-font overflow at scale 1.3.
- `[x]` S3 — Announcements + detail (`screens/announcement/`, `screens/announcement_detail/`)

  **Done 2026-09-19.** Both screens rebuilt to `03 §Screen 18/19`. The Material `AppBar`
  gives way to the spec's back-button + title row; cards become white radius-16 `shadowMd`
  panels carrying title / excerpt / date; the detail becomes a `TaCard` with title, date,
  body and the attachment strip.
  New pure `core/utils/announcement_cell_data.dart` holds the display rules —
  `announcementTitle` (an untitled announcement still gets a heading, since it has a body
  and a date worth showing), `announcementExcerpt` (collapses the newlines a web editor
  leaves behind, cuts at 120 chars **on a word boundary**, and returns null when there is no
  body so the line is dropped rather than printing "Unknown" under every title),
  `announcementDate`, `announcementBody` and `announcementImageUrls`.
  **A shared `core/utils/display_date.dart` (`displayIsoDate`) was extracted** and S1's
  `historyDate` now delegates to it, so the history card and the announcement card cannot
  drift on what a missing date looks like. S1's tests pass unchanged.
  **Three real defects fixed, all the same payload-policy class:**
  1. The list card called `DateTime.parse("${item.createdAt}")` — string-interpolating a
     `DateTime?` and re-parsing it. On a null date that parses the literal `"null"` and
     **throws**, taking the whole list down. Now degrades to an em dash.
  2. The detail card indexed `files[index]["file_url"]` straight off a `List<dynamic>`, so a
     single non-map row threw. `announcementImageUrls` probes each entry and skips what it
     cannot read.
  3. The list had **no empty and no error state** — both fell through to the shared
     delegate's defaults, so an account with no announcements and a failed fetch looked
     identical. Each now has its own copy, the error offers Retry, and first-page load shows
     skeleton cards (roadmap S3 Done When).
  Card taps moved to the whole card via `TaPressable` and still pass the **same
  `{"id": ...}` argument**, which the detail controller and the FCM deep link both read —
  asserted by a test.
  **Deviation:** `03 §Screen 19` draws a gradient placeholder where the images go. Real
  announcements carry real attachments, so the existing `XNetworkImage` strip is kept and the
  spec's gradient is reused only as the *error* fallback for an image that will not load —
  a placeholder in place of real content would be a downgrade.
  **Known limitation, recorded not worked around:** `AnnouncementDetailLogic
  .getAnnouncementDetail` swallows its error and never calls `update()` on failure, so a
  failed detail fetch is indistinguishable from a slow one and the skeleton stays up.
  Surfacing a real error needs a flag on the controller, which S3 holds read-only. **Follow-up
  for S5 or a P-task: one line in the catch plus a state flag.**
  **Preserved untouched:** `announcement/logic.dart` and `state.dart` (paging, P-13's
  `pageNo` fix), `announcement_detail/logic.dart` and `state.dart` (the `Get.arguments["id"]`
  read the FCM deep link depends on), `announcement_api.dart`, both bindings, and
  `x_paging_data_handler.dart`.
  New `.tr` keys `untitledAnnouncement`, `noAnnouncements`, `couldNotLoadAnnouncements` in
  all three translation files. Both pages are now `const`-constructible.
  **Verified:** `dart analyze lib/presentation/screens/announcement
  lib/presentation/screens/announcement_detail lib/core/utils/announcement_cell_data.dart
  lib/core/utils/display_date.dart lib/core/utils/history_cell_data.dart lib/translations
  lib/routes test/presentation/screens/announcement
  test/core/utils/announcement_cell_data_test.dart` → No issues ✓ · app-wide
  `dart analyze lib test` → **0 errors, 0 warnings** (106 infos, down from 114) ✓ · new tests
  (`announcement_cell_data_test.dart`, 16 · `announcement_widgets_test.dart`, 13: the shared
  date degrades, the untitled fallback, excerpt whitespace-collapsing / word-boundary cutting
  / null-dropping, image-url probing against non-map and empty rows, card rendering, the
  missing-date degrade, whole-card tap reaching the detail route **with the same `{"id"}`
  argument**, empty vs error being distinguishable, and the detail card's dropped-body and
  malformed-files cases) while S1's `history_cell_data_test.dart` passes **untouched** →
  **438/438 full suite pass** in mirror (409 + 29) ✓ · compile gate `flutter build apk
  --debug --no-pub --target lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: the FCM deep link into the detail in background **and
  terminated** states (roadmap S3 Verification), paging past page 1, pull-to-refresh, an
  empty account and an offline fetch against the live backend, attachment rendering, and
  real-font overflow at scale 1.3.
- `[x]` S4 — Auth: splash, login, OTP, register (`screens/splash_screen/`, `screens/login/`, `screens/otp/`, `screens/register/`)

  **Done 2026-09-19.** All four screens rebuilt to `03 §Screen 1–4`. `PDD-04` built as
  specified: `TaStepIndicator(steps: 3)` at 0/1/2 on login/OTP/register.
  **The validation quirks were pinned before anything was re-skinned.** S4's Verification
  says "auth tests stay green" — **there were no auth tests**, so the quirks it warns are
  "easy to 'fix' by accident" were entirely unprotected. 14 characterization tests were
  written first and **run green against the pre-re-skin code**, then re-run after: the
  `PhoneRepo` table (empty / non-numeric / spaces / the real 8–15 bounds),
  `validatePhoneNumber` normalization (strip whitespace, prepend "0"), and
  `validatePhone`'s separate 10-char rule. 6 more pin the register submit rule.
  **Where the spec and the code disagreed, the code won** (roadmap S4 Scope says so
  explicitly), and each is now locked by a test:
  - **Register requires a photo.** `03 §Screen 4` calls it optional, enables Create at ≥2
    characters and adds a Skip button that registers with an auto-name. The code is
    `passengerName != '' && profileImage != null`. Extracted verbatim as
    `canSubmitRegistration`; **no Skip button was built**, and the caption now says the
    photo is required rather than repeating the spec's "optional". The timestamp name
    auto-generation stays a defensive submit-time path this rule keeps unreachable.
  - **`Pinput` was kept, not swapped for the spec's `TaOtpField`.** The real field carries
    `smsRetriever` (Android SMS autofill), `forceErrorState` and the `onCompleted`
    auto-submit S4 names. `TaOtpField` has none of them, so swapping would have silently
    dropped autofill. The `PinTheme` was restyled with tokens (64px, radius 14, 26/800)
    and every behavioural prop passed through unchanged.
  - **No `+855` in the submitted value.** The country code stays a display-only prefix, as
    before; `validatePhoneNumber` still owns normalization.
  - **No splash "Skip →" and no "Demo: type any 4 digits"** (`D14`, demo-only).
  Login keeps its exact `inputFormatters` chain (digitsOnly → cap 12 →
  `CardNumberInputFormatter`), so `state.phoneNumber` still holds the spaced string
  `phoneLogin` strips; both the Next button and the keyboard's done action still call
  `phoneLogin(state.phoneNumber.value, context)`; the shake is still `logic.phoneShake`.
  Splash gained the gradient badge and an indeterminate loading bar — `_checkAuthorization`
  (P-01's `SessionService` gate) is untouched. OTP now shows the number the code went to.
  New shared `screens/login/auth_language_toggle.dart` replaces the flag `IconButton` on
  login and register with the spec's `TaSegment`, guarded so the flip-style
  `toggleLanguage` is only called when the tap changes the language.
  `TaTextField` gained `onSubmitted` and `enabled` (additive, defaults preserve behaviour) —
  login needs submit-on-done, which the component could not express.
  **Preserved untouched:** all four `logic.dart`/`state.dart` files, `PhoneRepo`,
  `phone_formatter.dart`, `SessionService`, `AppLogic.toggleLanguage`, the OTP resend
  countdown, `SmsRetrieverImpl`, the register picker sheet, and `debug_auth_bypass.dart`.
  New `.tr` keys `taarraaTaxiSubtitle`, `tapToAddPhotoRequired`, `fullName`,
  `enterFullName` in all three translation files.
  **Two copy/logic mismatches found and pinned rather than fixed** (they change behaviour,
  so they belong to P2, not a re-skin): `PhoneRepo` checks `length < 8` but its message
  says "between 9 and 15 digits"; and `LoginLogic.validatePhone` requires 10 characters
  while `PhoneRepo.isValid` accepts 8 — the two rules genuinely disagree, and `phoneLogin`
  gates on `isValid`.
  **Verified:** `dart analyze lib/presentation/screens/splash_screen
  lib/presentation/screens/login lib/presentation/screens/otp
  lib/presentation/screens/register lib/presentation/widgets/ta_text_field.dart
  lib/translations lib/routes test/presentation/screens/login
  test/presentation/screens/register` → clean (4 remaining infos are pre-existing legacy
  tokens inside `register/logic.dart`'s picker sheet — S5 scope, and logic is read-only
  here) ✓ · app-wide `dart analyze lib test` → **0 errors, 0 warnings** (67 infos, down
  from 106) ✓ · the 14 characterization tests pass **both before and after** the re-skin ✓ ·
  **458/458 full suite pass** in mirror (438 + 20) ✓ · compile gate `flutter build apk
  --debug --no-pub --target lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: the manual matrix S4 lists (empty phone, short phone,
  formatted phone with spaces, wrong OTP, resend, register enable/disable), SMS autofill on
  a real Android device, `debug_auth_bypass` still working, and real-font overflow at 1.3.
- `[x]` S5 — Legacy token cleanup (delete `AppColors`/`ThemeConstands` + legacy widgets)

  **Done 2026-09-19.** `AppColors`, `ThemeConstands`, `AppTextStyles` and the `AppTheme`
  alias are **deleted, not commented out** — `core/theme/` now holds tokens only
  (`ta_colors`, `ta_radius`, `ta_shadow`, `ta_spacing`, `ta_text_styles`, `ta_theme`).
  **10 files deleted:** `core/theme/{colors,text_styles,app_theme}.dart` and the superseded
  widgets `x_text_field`, `text_field_decoration`, `decorated_input_border`, `fbtn_widget`,
  `x_button`, `card_atta_widget`, `t_image_widget`. **Each was verified to have zero
  remaining importers immediately before deletion**, and the chain was walked in dependency
  order — deleting `x_text_field` orphaned `text_field_decoration`, which orphaned
  `decorated_input_border`.
  **Two files had to be migrated first, because they were the last importers standing:**
  - `map_screen/widgets/driver_info_sheet.dart` was the only `fbtn_widget` user. C3 had left
    it deliberately untouched, so S5 re-skinned it: the hand-rolled avatar + name + model
    row is now `TaDriverCard`, so it matches the booking screen's driver card, and the phone
    line is a `TaProfileRow`. The `tel:` launch and the commented-out `requestBooking` call
    are unchanged.
  - `register/logic.dart`'s photo-picker sheet was the only `x_button` user — swapped to
    `TaPressable` in place. The sheet still lives in the controller; **moving it out is a
    known architectural smell** (the same "widget-building code in a controller" violation
    `driver_info_sheet` was extracted for) and is left as a follow-up rather than
    smuggled into a token task.
  `AppColors.main` → `TaColors.primary` across `app/logic.dart`, `app/google_map_logic.dart`,
  `booking_map_screen/logic.dart`, `map_screen/logic.dart`, `center_loading.dart` and
  `x_network_image.dart` — **identical value (`0xFFFF4500`), so a pure rename**, as was
  `AppColors.light2` → `TaColors.border` (`0xFFEBEBF0`) in the picker sheet. Five components
  had `Color(0xFFF6F6F7)` hardcoded where `TaColors.background` already existed
  (`ta_history_card`, `ta_driver_card`, `ta_stat_row`, `ta_vehicle_row`, `ta_note_field`) —
  swapped. The last raw colours in the three still-live legacy widgets were tokenized, and
  `card_board_shimmer_widget` now uses F3's shimmer pair so every skeleton shimmers alike.
  **A note on S5's own verification grep.** The roadmap's
  `grep -rn 'Colors\.\|Color(0x...' lib/presentation` reports ~328 hits, but the pattern
  matches **inside `TaColors.primary`** — most "findings" are the tokens themselves. The
  genuine raw uses are now only `Colors.white` (32) and `Colors.transparent` (8), both
  legitimate on coloured surfaces, plus a handful of hex literals the design system does not
  name (the splash and avatar gradients, the star amber, the shimmer pair, the timeline's
  inactive track). Those were **left alone**: inventing new semantic tokens for them is an
  F1/`02 §Colors` decision, not a cleanup. Recorded here so the next reader is not misled by
  a grep that flags its own solution.
  **A guard test replaces the runbook grep** (`test/core/theme/legacy_tokens_removed_test.dart`):
  it asserts the three theme files and the seven widgets are gone, and scans every `.dart`
  file in `lib/` for the deleted identifiers, ignoring doc comments. Reintroducing either
  table now fails the suite instead of waiting for someone to re-run a grep.
  **Verified:** app-wide `dart analyze lib test` → **0 errors, 0 warnings**, and infos fell
  **67 → 25** ✓ — the 25 left are unrelated lint categories (naming conventions, a few
  Flutter API deprecations, one `print`), none token-related. Legacy identifiers remaining in
  `lib/`: **3, all doc comments** recording the removal. · **461/461 full suite pass** in
  mirror (458 + 3) ✓ · compile gate `flutter build apk --debug --no-pub --target
  lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: walking every screen in both locales looking for
  off-palette greys and oranges (S5 Verification), and the re-skinned driver-info sheet on
  a live map.

### Phase 4 — Polish

- `[x]` P1 — Motion and micro-interactions

  **Done 2026-09-19.** New `core/utils/motion.dart` holds the motion tokens
  (`fast` 120ms / `medium` 200ms / `base` 280ms / `ambient` 1100ms) and the reduced-motion
  helpers `prefersReducedMotion`, `motionDuration` and `applyAmbientMotion`.
  **The driver-app failure mode this task warns about does not exist here — and that is now
  asserted, not assumed.** P1 flags that an `AnimationController` doubling as a real timer
  runs at 5% duration (≈20× early) when the OS disables animations, and says to check the
  OTP countdown and the auto-dismiss paths. **All four timed behaviours were already real
  timers**: the OTP resend countdown and the 10s booking poll are `Timer.periodic`, the
  toast auto-dismiss is `Future.delayed`, and the pickup-address debounce is a `Timer`.
  Nothing needed `AnimationBehavior.preserve`. A test now reads those four source files and
  fails if an `AnimationController` ever appears in one, so the property holds by
  construction rather than by memory.
  **One-shot transitions brought under the ~300ms ceiling:** the splash logo pop 600→280,
  the receipt success check 420→280, and the shake 400/500→280 (both callers' explicit
  500ms overrides removed). Everything else was already at or under it — dialog 250, sheets
  300, star pop 300, timeline step 200, button 120, press 100.
  **Reduced motion is honoured** (P1 Verification: "pulses stop, sheets/dialogs fade only"):
  - `TaStatusPill`'s pulse, `TaSkeleton`'s shimmer, `TaLoadingOverlay`'s bouncing car and
    the splash loading bar all **stop and park at a resting frame** — the skeleton still
    renders as a placeholder, the overlay still says a booking is in flight. The pill's
    existing `isPulsing` switch still wins independently.
  - `TaDialog` **fades instead of scaling**, and both bottom sheets collapse their slide to
    zero while the barrier still fades, so nothing appears out of nowhere.
  - `ShakeWidget.shake()` **returns without playing** rather than shaking in 0ms, which
    would be a visual glitch. The error signal is unaffected: callers still fire
    `HapticFeedback.heavyImpact()` and raise a dialog or snackbar alongside it.
  The ambient loops keep their 1100ms period — they repeat by design, so the ceiling does
  not apply to them; stopping them under reduced motion is what matters, and the token
  records that distinction explicitly.
  **Verified:** `dart analyze lib test` → **0 errors, 0 warnings** (25 infos, unchanged from
  S5 and all unrelated lint categories) ✓ · new `test/core/utils/motion_test.dart`, 10 tests:
  the token ceiling, `prefersReducedMotion` in both states, `motionDuration` collapsing, the
  pill and skeleton animating normally **and holding still** under
  `MediaQueryData(disableAnimations: true)`, the skeleton still rendering when stopped, and
  the no-real-timer-is-a-controller guard → **471/471 full suite pass** in mirror (461 + 10)
  ✓ · compile gate `flutter build apk --debug --no-pub --target lib/main.dart` (mirror) →
  `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: turning on "Remove animations" in OS accessibility
  settings and walking the app (P1 Verification), plus the map camera, which is the
  documented exception to the ceiling and is driven by the Google Maps SDK rather than by
  anything here.
- `[x]` P2 — Copy and localization sweep (`translations/`, EN+KM key sync)

  **Done 2026-09-19.** The roadmap's P2 Risk asks for exactly one thing first — "a test
  should pin identical key sets" — so `test/translations/key_parity_test.dart` was written
  before any copy was touched, and **it immediately found real bugs**:
  - **16 keys were declared on `AppLocale` and used with `.tr`, but wired into neither map.**
    Because this codebase uses the **English string itself as the map key**, GetX's
    fallback-to-key made them render correctly in English *by accident* while rendering
    **English under the Khmer locale** — the silent failure P2 names. Among them was
    **`retry`, used by every error state added in S1, S2 and S3**, plus `rideWithTrust`
    (C2's tagline), C4's whole search-panel vocabulary (`noPlacesMatch`, `checkSpelling`,
    `couldntSearch`, `resolvingAddress`, `pinnedLocation`, `weDontOperateHere`,
    `driversCantStopHere`, `noteHint`, `searchLocation`), `locationSelected`, `ok`, `price`,
    `startRide` and `waitingDriverArrived`. All 16 are now in both maps with real Khmer.
  - **`promoTag`'s Khmer entry pointed at its English key**, so it rendered in English.
    Translated.
  The test has four checks: identical key sets both ways, no duplicate key names (a repeated
  literal in a Dart map silently keeps the last entry), no Khmer value left pointing at its
  English key, and every `AppLocale` declaration wired into both maps. All four pass.
  **Hardcoded English removed from the redesigned surface:** `TaMinMaxSheet`'s tariff copy
  (`Tariff` / `Min fee` / `Price per km` / `Seats` / `Got it`), `TaLoadingOverlay`'s Cancel,
  `TaHistoryCard`'s default `Completed`/`Cancelled` badge (S1 added the `statusLabel`
  override but left the fallback English), and the two Google Map `InfoWindow` titles
  ("My Location" / "Destination") which were never translatable at all. New keys `tariff`,
  `minimumFee`, `seats`, `gotIt`; the rest reuse existing ones.
  **Left as-is, deliberately:** four `xPrettyLog`/`debugPrint` messages (logs, not UI) and
  the Contact screen's `Smart: +855 70 427 213` / `Cellcard: +855 12 285 048` — carrier
  names and phone numbers, not prose.
  **A copy inconsistency the suite caught:** `AppLocale.pricePerKM` read `"Price per Km"`
  while `03 §D7` and the C3 component test both write `"Price per km"`. Normalized to the
  spec's lowercase SI unit — the test then passed unchanged, which is the right direction
  since the test encodes the spec.
  **Still open for a native review, not claimed as done:** every Khmer string added across
  C2–C7 and S1–S4 was **drafted by me, not reviewed by a Khmer speaker**. P2's Verification
  asks for a native review, and the driver app has a `docs/l10n-km-review.md` pattern for
  it. Recorded as a blocker below rather than marked complete.
  **Verified:** `dart analyze lib test` → **0 errors, 0 warnings** (25 infos, unchanged) ✓ ·
  new `test/translations/key_parity_test.dart`, 4 checks, all passing ✓ · **475/475 full
  suite pass** in mirror (471 + 4) ✓ · compile gate `flutter build apk --debug --no-pub
  --target lib/main.dart` (mirror) → `app-debug.apk` built ✓.
  Device-only → **carried to Q1/Q2**: running the app fully in KM at text scale 1.3
  (P2 Verification), and the native Khmer review above.
- `[>]` P3 — Accessibility pass

### Phase 5 — QA

- `[ ]` Q1 — Visual QA against `docs/taarraa-ui-prototype.html`
- `[ ]` Q2 — Functional regression (device + live backend, oracle-driven)
- `[ ]` Q3 — Performance review

## Decision / Change Log

- 2026-09-14 — Created this tracker from `docs/roadmap.md` (22 items). Baseline the app and
  sign off G0 before starting F1. No application source modified by this change.
- 2026-09-15 — F1 (tokens/theme) marked done after `dart analyze lib/core/theme` clean +
  mirror compile gate. F2 (32 components) marked done after analyze clean + 262/262 tests +
  mirror APK gate. F3 (overlay re-skin) marked done after analyze clean + 262/262 tests +
  mirror APK gate. `ta_pressable.dart` helper added beyond the documented file list.
- 2026-09-15 — C1 (shell) done after analyze clean + 265/265 tests + mirror APK gate. C2
  (home) done after analyze clean + 272/272 tests + mirror APK gate. C3 (map)
  done after analyze clean + 281/281 tests + mirror APK gate. C4 (search + pickup MapDrag)
  done after analyze clean + 289/289 tests (map_drag test files untouched) + mirror APK
  gate. C4 deviations recorded: minimap preview dropped pending a static-map asset (live
  map stays behind results, visual parity → Q2); placeline distance absent so the
  `TaSearchResult` badge hides instead of faking.
  `TaDialog.show` gained `barrierDismissible`; `TaGrabHandle` exported from `ta_bottom_sheet.dart`.
  2026-09-15 — C1 (floating pill tab host) marked done after analyze clean + 265/265 tests
  + mirror APK gate. Host now uses `TaBottomNav` + `assets/nav_icon/*.svg` per Screen 5;
  `Icons.event` for "My Booking" replaced (P9). `TaNavItem` supports SVG active/inactive icons.
  2026-09-15 — C2 (Home) marked done after analyze clean + 272/272 tests + mirror APK gate.
  `home/view.dart` rewritten to Screen 6 (header, promo, search card, skeleton-shimmer list,
  EmptyData). Vehicle ETA derived via new `etaMinutesForVehicleId`; EasyLoading dropped from
  `getVehicleType` (shimmer + toast); `.tr` keys added EN/KM; `EmptyData` exported from the
  barrel; Home state widget tests added via GetX harnesses.
  2026-09-15 — C3 (Map) marked done after analyze clean + 281/281 tests + mirror APK gate.
  `map_screen/view.dart` rebuilt to Screen 7; bottom sheet + booking overlay extracted to
  `widgets/map_bottom_sheet.dart` / `widgets/booking_loading_overlay.dart`; nested D7 tariff
  via `TaMinMaxSheet.open`; `nearestDriverDistanceKm` haversine in `map_presentation.dart`;
  Home/Map cell formatting unified in `core/utils/vehicle_cell_data.dart`; new `.tr` keys
  EN/KM; map sheet + overlay widget tests added. Build lesson: always use
  `~/fvm/versions/3.44.1/bin/flutter` for `flutter build` (PATH `flutter` is 3.38.1 and mixes
  with FLUTTER_ROOT 3.44.1).
  2026-09-19 — C5 (Booking / active ride) marked done after analyze clean + 315/315 tests
  + mirror APK gate. `booking_map_screen.dart` rebuilt to Screen 9 (full-bleed map +
  floating status pill + docked sheet); sheet extracted to `widgets/booking_sheet.dart`
  with the pure `bookingPhaseFromStatus`/`bookingStatusText` pair driven by `data.status`
  only (D14 — no Skip button, no 17s auto-advance); shared `core/utils/initials.dart`
  added for C6/S1 reuse; `stepAccepted`/`stepArriving`/`stepOnTrip` keys added EN/KM.
  `logic.dart`/`state.dart`/`poll_policy.dart`/`binding.dart` untouched. Two view calls
  recorded: Call disabled without a driver phone, and a failed cancel keeps the passenger
  on the ride (navigation is conditional on the API confirming).
  Found and replaced a **non-compiling draft** of `widgets/booking_sheet.dart` left in the
  working tree (11 analyzer errors: `.trchem`, `10.ts`/`16.t`, `status2`,
  `makePhoneCallAggregate`, `app_size.dart`, `app_routes.dart`, a missing `_initials`).
  Nothing in it had ever been analyzed or run; it was rewritten against the real APIs.
  2026-09-19 — C6 (Fee / payment wait) marked done after analyze clean + 341/341 tests +
  mirror APK gate. `calculate_fee_screen.dart` rebuilt to Screen 10 and made stateless over
  the binding's controller; receipt extracted to `widgets/fee_card.dart`; new pure
  `core/utils/fee_presentation.dart` (money fails loudly, display degrades);
  `tripFare`/`vehicle`/`pickup`/`fareUnavailable` keys added EN/KM. No demo payment control
  (D14). Fixed two pre-existing presentation bugs: both address rows read `endAddress`, and
  an unguarded `formatDateTime(dynamic)` crashed the screen on a null/ISO `start_time`.
  Open and recorded: the "Payment confirmed" badge needs an undocumented `payment.status`
  mapping, so only the waiting badge is rendered.
  2026-09-19 — C7 (Rating + Receipt) marked done after analyze clean + 367/367 tests +
  mirror APK gate. **Phase 2 is complete (7/7).** Two new screens, two new routes (the
  redesign's only schema change), and the chain `Fee → Rating → Receipt → Home`.
  Spec conflict between the N-10 rules module and `03 §Screen 11` was put to the user and
  resolved: **N-10 governs the rules, C7 skins it, and the flow ends at the Receipt
  screen**; the ux-redesign chip labels are prototype placeholders. `rate_driver/rating.dart`
  reused read-only apart from a note recording the superseded navigation line.
  PDD-02 honoured: ratings are queued via the N-10 rules, never sent, and the screen says so.
  New `rating_prompt_store.dart` makes "Skip is unpunished" actually hold across restarts.
  One sanctioned logic edit: `CalculateFeeLogic.syncNavigateBack()` now routes through
  Rating when `shouldPromptForRating` allows. Fixed a 369px `TaKVRow` overflow found in
  verification (long copy does not belong in a KV value).
  2026-09-19 — S1 (History + detail) marked done after analyze clean + 394/394 tests +
  mirror APK gate. Screen 13 now uses `TaSegment` over the existing `TabController`;
  Screen 14 rebuilt with a 200px route preview and the shared formatters. The two
  byte-identical tab widgets collapsed into one `history_tab.dart`; the 313-line
  `history_card_widget.dart` replaced by `TaHistoryCard`; new pure
  `core/utils/history_cell_data.dart`. Three real defects fixed: `TaHistoryCard.onTap` was
  never wired (the whole-card tap did nothing), `HistoryItem.to` was required so a cancelled
  trip printed "Unknown" for a destination it never had, and an unguarded
  `DateTime.parse(createdAt)` could take the whole list down. `TaHistoryCard` gained an
  optional localised `statusLabel`. Both tabs got real empty and error states.
  All history/history_detail logic, state and paging left untouched.
  2026-09-19 — S2 (Profile, Terms, Contact) marked done after analyze clean + 409/409 tests
  + mirror APK gate. **PDD-03 resolved by the user: Logout restored, bell stays commented.**
  Profile rebuilt to Screen 15 (TaSegment language toggle over the existing
  `toggleLanguage`, TaProfileRow menu, real Logout row calling the untouched
  `AppLogic.logout()`); Terms to Screen 16 (numbered cards, legal copy unchanged); Contact
  to Screen 17 (brand badge, rows keeping their `tel:`/`mailto:` launches, real address
  kept over the spec's placeholder). `state.errorMessage` finally renders with a Retry —
  the B5 gap P-14 left. Version read via `installedAppVersion()` rather than hardcoded.
  All three screens are now const-constructible, as the bottom-nav host already assumed.
  2026-09-19 — S3 (Announcements + detail) marked done after analyze clean + 438/438 tests +
  mirror APK gate. Both screens rebuilt to Screen 18/19; new pure
  `core/utils/announcement_cell_data.dart`; shared `core/utils/display_date.dart` extracted
  and S1's `historyDate` now delegates to it. Three defects fixed: the list card's
  `DateTime.parse("${item.createdAt}")` threw on a null date (it parsed the literal
  "null"), the detail card's bare `files[i]["file_url"]` threw on a non-map row, and the
  list had neither an empty nor an error state. Card tap moved to the whole card, still
  passing the same `{"id": ...}` the FCM deep link reads. Deviation: the spec's gradient
  image placeholder is used only as the image *error* fallback, since real announcements
  carry real attachments. **Recorded limitation:** the detail controller swallows its fetch
  error and never calls `update()`, so a failed load cannot be told from a slow one — the
  skeleton stays up. Fixing it needs a controller flag, which S3 holds read-only; follow-up
  left for S5 or a P-task.
  2026-09-19 — S4 (Auth) marked done after analyze clean + 458/458 tests + mirror APK gate.
  All four screens rebuilt to Screen 1–4 with PDD-04's 3-step indicator.
  **S4's Verification assumed auth tests existed; none did.** 20 tests were written — 14 of
  them characterization tests run green against the pre-re-skin code first — so the
  validation quirks are now protected rather than merely described. Where spec and code
  disagreed the code won, per the roadmap: register still requires a photo (no Skip button,
  no >=2-char rule), `Pinput` was kept over `TaOtpField` to preserve SMS autofill and
  `forceErrorState`, and no `+855` entered the submitted value. No splash Skip, no demo OTP
  hint (D14). `TaTextField` gained `onSubmitted`/`enabled`; new shared
  `auth_language_toggle.dart`. Two pre-existing mismatches pinned for P2: PhoneRepo's
  length message contradicts its check, and `validatePhone` (10) disagrees with
  `isValid` (8).
  2026-09-19 — S5 (Legacy token cleanup) marked done after analyze clean + 461/461 tests +
  mirror APK gate. **Phase 3 is complete (5/5).** `AppColors`/`ThemeConstands`/
  `AppTextStyles`/`AppTheme` deleted outright along with 7 superseded widgets — 10 files
  removed, each verified importer-free first and walked in dependency order. Two blockers
  migrated to get there: `driver_info_sheet.dart` (last `fbtn_widget` user, now on
  `TaDriverCard`) and `register/logic.dart`'s picker sheet (last `x_button` user, now
  `TaPressable`). All colour swaps were value-identical renames. App-wide infos 67 → 25,
  0 errors/0 warnings. Added `legacy_tokens_removed_test.dart` so the deletion is enforced
  by the suite rather than by remembering to grep. Two things deliberately not done and
  recorded: the design system names no token for the gradient/shimmer/amber literals
  (an F1 decision, not a cleanup), and the register picker sheet still builds widgets
  inside its controller.
  2026-09-19 — P1 (Motion) marked done after analyze clean + 471/471 tests + mirror APK
  gate. New `core/utils/motion.dart` (tokens + `prefersReducedMotion`/`motionDuration`/
  `applyAmbientMotion`). Checked P1's headline risk: **no real timer in this app is an
  `AnimationController`** — the OTP countdown and booking poll are `Timer.periodic`, the
  toast is `Future.delayed`, the pickup debounce is a `Timer` — so no
  `AnimationBehavior.preserve` was needed, and a test now enforces that shape. One-shots
  brought under 300ms (splash pop 600→280, receipt check 420→280, shake 500→280). Under
  reduced motion the pill/shimmer/car/splash-bar stop at a resting frame, dialogs fade
  instead of scaling, sheets collapse their slide, and the shake is skipped rather than
  played in 0ms.
  2026-09-19 — P2 (Copy + localization) marked done after analyze clean + 475/475 tests +
  mirror APK gate. Wrote `test/translations/key_parity_test.dart` first, as P2's Risk asks;
  it found **16 keys declared and used but wired into neither map** — including `retry`,
  used by every error state S1–S3 added — which rendered as English under the Khmer locale
  because the key IS the English string. Also found `promoTag`'s Khmer entry pointing at its
  English key. All fixed with real Khmer. Removed the remaining hardcoded English from
  `TaMinMaxSheet`, `TaLoadingOverlay`, `TaHistoryCard`'s badge default and the two map
  `InfoWindow` titles. Normalized `pricePerKM` to the spec's "Price per km". **New blocker
  recorded: the Khmer copy itself is unreviewed** — parity is enforced by test, quality is
  not.
  2026-09-19 — QA mock / demo mode (ported from `pu_driver`) — done: analyze clean
  (0 errors, 1 pre-existing warning), 488 tests pass (474 existing + 14 new
  `test/mock/mock_flow_test.dart`), mirror APK gate built (`flutter build apk --debug
  --no-pub --target lib/main.dart`; a bare `flutter build apk` without `--target` picks
  up a phantom `lib/main1.dart` at the Gradle default — pre-existing, use the explicit
  target). `docs/qa/MOCK_MODE.md` written as the mirror of the driver's. What it does:
  `USE_MOCK_DATA` define builds in `MockMode.enabled = USE_MOCK_DATA && !kReleaseMode`,
  tree-shaken out of release; red MOCK tab (left edge, ~42% height) opens the dev panel;
  runtime kill switch ("Use mock backend"); scenarios `NORMAL_FLOW` / `BOOKING_FAILED` /
  `NO_DRIVER_AVAILABLE` / `DRIVER_CANCELLED` / `NETWORK_ERROR` / `SESSION_EXPIRED` /
  `LOCATION_ERROR`; Auto/Manual dispatch; speed 1x/2x/5x/10x; Cash/Wallet/Card payment
  method. No screen changed: the seams are `MockHttpInterceptor` on the shared Dio client,
  the `SocketService` mock listener (same handlers — booking refresh, Fee redirect,
  Fee→Rating→Receipt→Home, cancel dialog), `LocationService.source`
  (`MockLocationSource`, passenger parked at pickup, no fix under LOCATION_ERROR),
  `GoogleMapLogic`/map polyline → `mockRoute`, and `location_imp`/`places_api` (fixed
  landmarks). State persists to SharedPreferences; relaunch resumes through the real
  `get-request-booking-info` path; never-accepted requests are dropped on restore. Two
  interesting test-side facts: the remaining APIs that sit on `BaseApiService`
  (CheckBookingApi, GetVehicalRemoteDataSource, AppVersionRepoApi) cannot be reached from
  a unit test (they read the global
  `BaseHttpClient.dio`), so `test/mock/mock_flow_test.dart` drives the HTTP ones through a
  real `ApiClient` + injected interceptor and asserts the others indirectly; and the
  socket pushes are wrapped in the same `status/message/data` envelope as the REST
  responses because the app parses `driverDropDrive`/`onDriverCancelDrive` payloads as a
  `RequestBookingModel`. One unrelated failure surfaced and is deliberately NOT fixed here:
  `test/translations/key_parity_test.dart` "no key is declared and then never translated"
  fails on `clearDestination`/`language`/`refresh` — three `AppLocale` keys added since P2
  that are absent from the English map. Untracked test file, translations untouched by this
  task; flagged for the owner.
