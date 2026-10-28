# Pu Taxi Passenger — Current State (source-cited)

**Scope of this file:** the current, as-shipped state of the passenger app's
core booking journey, read from source with file/line citations. It is the
**baseline half** of every comparison. Visual/interaction depth for the rest of
the app already exists in `docs/ux_ui_audit/` and is cross-referenced, not
duplicated.

- State management: **GetX only** (`lib/routes/app_pages.dart`).
- Design tokens: `lib/core/theme/ta_*.dart` (the "Taarraa" system) — palette,
  `KantumruyPro` type scale, radius/shadow/motion tokens. See
  `docs/passenger_design_system.md`.
- `.d` diagonal scaling (`lib/core/utils/app_ext.dart:29-43`) is used **only** in
  map/booking screens, not on Home.

---

## 1. Navigation & shell

**Bottom nav — 3 tabs** (`lib/presentation/screens/bottom_nav/view.dart:23-37`):
`Home`, `My Booking`, `Profile`. Custom `TaBottomNav`
(`lib/presentation/widgets/ta_bottom_nav.dart:11-142`): docked, top hairline,
active tab = brand colour + a 3px indicator bar, SVG icons tinted.

`BottomNav` binds `BottomNavBinding`, `HomeBinding`, `HistoryBinding`,
`ProfileBinding` together (`app_pages.dart:77-86`) — so the three tabs share one
route. `/home` is also a standalone route (`app_pages.dart:96-100`).

**Route constants** (`app_pages.dart:41-62`): `SPLASH, BOTTOMNAV, LOGIN, OTP,
REGISTER, HOME, MAP, BOOKING, MYBOOKING, CALCULATEFEE, RECEIPT, WHERETOGO,
DRAGMAP, TERMCONDITION, CONTACTUS, INVITE_REWARDS, HISTORYDETAIL,
ANNOUNCEMENT, ANNOUNCEMENTDETAIL`. **`MYBOOKING` and `WHERETOGO` are declared
but not registered as pages** — dead constants.

## 2. Home tab (`/bottomnav` → Home)

**Files:** `lib/presentation/screens/home/{view,logic,state,binding}.dart`,
`booking_redirect.dart`; widgets `ta_vehicle_row.dart`, `ta_promo_banner.dart`.

Layout (`home/view.dart:30-84`): `Scaffold(background)` → `SafeArea(bottom:false)`
→ `RefreshIndicator` → `SingleChildScrollView` → `Column(start)`:
1. `_buildHeader` — 40×40 launcher icon (r12) + `PU TAXI` (22/w800) + a Khmer/EN
   tagline + **`AuthLanguageToggle`** (`view.dart:88-173`). A bell/announcement
   entry exists but is **commented out** pending sign-off (`view.dart:159-166`).
2. `TaPromoBanner` — dark gradient card (`#232838→#3A2C28→#572C12`), a `PROMO`
   pill, title `20% off airport rides`, subtitle `Use code FLY20`
   (`view.dart:47-52`, `ta_promo_banner.dart:24-92`). **Static demo copy.**
3. `_buildSectionHeader` — `Choose your ride` + a refresh `TaIconButton`
   (`view.dart:175-199`).
4. Vehicle list — `GetBuilder<HomeLogic>`: **skeleton** while loading/error,
   `EmptyData` when empty, else one `TaVehicleRow` per vehicle; a tap opens
   `/map` with `{vehicleId}` (`view.dart:56-77`).

**`TaVehicleRow`** (`ta_vehicle_row.dart:26-99`): a card (r16, `shadowMd`,
selected = `primaryBg` + 1.5 `primary` border) with 84×52 vehicle SVG art, name
(15/w800), `seats · $X/km`, `from $Y` (14/w800 `primaryDark`) and an ETA with a
clock icon. Presentation data is centralised in
`vehicleCellData()` (`lib/core/utils/vehicle_cell_data.dart`) so Home and Map
cannot drift. There is also a `compact` variant and a `Tariff` pill.

**FAB:** `InviteFab` when `inviteFeatureEnabled` (`view.dart:34`).

**HomeLogic** (`home/logic.dart`): constructor-injected deps (P-03). `onInit`
inits the socket, fetches vehicle types, app-update, pushes the FCM token, and
fetches ride credit. `onReady` requests location + notification permission, then
`checkingBookingStatus()` — resuming any active booking via
`bookingRedirectRoute()` and `Get.offNamed` (`logic.dart:116-128`).

**UI states on Home** [SRC]: loading → `TaSkeletonCard` shimmer; error → same
skeleton + a `TaToast` "something went wrong" (`logic.dart:86-93`); empty →
`EmptyData(noVehicleAvailable)`; pull-to-refresh → `RefreshIndicator`.

## 3. Booking map (`/map`)

**Files:** `map_screen/{view,logic,state,map_presentation}.dart`,
`widgets/{map_appbar,map_bottom_sheet,booking_loading_overlay,driver_info_sheet,detail_service_dialog}.dart`.

Layout (`map_screen/view.dart:23-39`): `Scaffold` → `LayoutBuilder` → `Column`:
`Expanded(GoogleMap)` + **`MapBottomSheet(maxHeight)`**, with
`BookingLoadingOverlay` on top. The map is **Google Maps** (`myLocationEnabled`,
custom trip + driver markers, polylines), centre-pinned with `TaCenterPin(60.d)`
when there is no destination (`view.dart:75-78`).

**MapAppbar** (`map_appbar.dart:13-29`): just a back `TaIconButton` over the map.
The old "My Location" pill was removed; a my-location `TaIconButton` sits at
bottom-right (`view.dart:89-98`).

**MapBottomSheet** (`map_bottom_sheet.dart:37-167`) — a card riding above the map
(not a modal, so the map stays interactive), capped at **55% of screen height**
(`:64-70`), `radiusXxl` top corners, `shadowLg`. Contents top→bottom:
1. **`_RouteCard`** — bordered card (r16): a pickup row (`Current Location` +
   reverse-geocoded address, retry on failure) and either a **destination row**
   (tap to re-pick, close to clear) or an **`Add drop-off (optional)`** row
   (`:184-343`).
2. **`TaNoteField`** "Add a note for driver" — only when a destination is set
   (`:88-95`); presentational, not sent (`state.dart:69-72`).
3. **`_VehicleChips`** — a horizontal ListView of chips (min-width 96, r12,
   selected = `primaryBg` + `primary` border), each showing vehicle name + a
   **fare**: the route estimate when a destination exists, else `from $minFare`
   (`:365-435`).
4. **`_VehicleCaption`** — `6.2 km · 4 Seats · ~3 min` + a `Tariff` pill that
   opens the tariff sheet (`:438-485`).
5. **`RideCreditRow`** (D40) — only when the passenger has credit (`:120-134`).
6. **`TaButton`** — `Book Tuk Tuk · $fare`, `isEnabled: vehicle != null`
   (`:138-148`); label built by `_bookLabel` (`:171-178`).
7. **`fareByMeterHint`** — shown only when there is no destination (`:150-161`).

**Pickup model:** the pickup is the **centre of the map**. `onCameraIdle`
computes the visible-region centre and reverse-geocodes it
(`logic.dart:251-263, 301-324`); the pin is fixed and `IgnorePointer`d.
`addressFailed` shows a retry (`state.dart:46`).

**Destination model:** optional. Adding one opens **`/dragMap`**
(`map_bottom_sheet.dart:298-308`); the returned `LatLng` triggers
`updateDestinationLocation` → reverse-geocode, `calculateDistance`,
`drawPolyline` (Google Directions, mock route in QA), `refreshMarkers`
(`logic.dart:327-357`).

**Fare:** `estimateFare(distanceKm, pricePerKm, minimumFare)`
(`logic.dart:375-379, 388-395`). **Pricing is USD** (`formatMoney`); commit
`d099043` "Adopt USD pricing".

**Booking** (`requestBooking`, `logic.dart:630-713`): re-entrancy-guarded on the
`BookingSession`; looks up a missing pickup address; `session.beginRequest`;
calls `RequestBookingApi`; on ok → `markAwaitingDriver`, starts a **5s poll**
(`kAwaitDriverPollInterval`) as a backstop to the socket, emits `rideRequest`.
On any failure → `_failBooking` → a **`BookingFailure` dialog whose retry
actually re-runs `requestBooking()`** (`logic.dart:525-535`) — a real retry,
unlike the auth screens. `BookingLoadingOverlay` has a cancel that clears the
overlay first (`cancelBooking`, `:717-722`).

**UI states on the map** [SRC]: booking → `BookingLoadingOverlay` (busy);
driver-waiting → overlay stays up + 5s poll; failure → dialog + real retry;
address-reverse-geocode fail → retry icon in the pickup row; no vehicle →
`noVehicleAvailable`; no location → `BookingFailure.noLocation`.

## 4. Location selection (`/dragMap`)

**Files:** `presentation/shared/map_drag/{view,logic,state,args,pickup_label,search_state}.dart`,
`widgets/{pin_confirm_sheet,search_view,search_panel}.dart`.

Layout (`map_drag/view.dart:47-79`): map + fixed centre `TaCenterPin` with a
**floating address callout** (`_callout`, `:212-238`) + a floating header =
back button + a **pill search bar** (h46, `radiusFull`, `shadowMd`) that opens
`MapDragSearchView` over the map (`:145-193`). `PinConfirmSheet` sits under
(`:68`).

**`PinConfirmSheet`** (`pin_confirm_sheet.dart:31-71`): purpose label, the
address split into name + context lines (with skeleton while resolving), an
optional driver-note field (pickup only), and a full-width `Confirm` button that
is **disabled until the pickup address resolves** (`:123-137`).

**Search** (`search_view.dart`, `search_panel.dart`): a live place search that
**requires a minimum number of characters** ("Type at least 3 letters to
search", `app_locale.dart:281`). States: min-chars hint, skeleton results,
no-result (`noPlacesMatch` + `checkSpelling`), error (`couldntSearch` + a
**Retry** button), and a `Set location on map` escape (`search_panel.dart:48-186`).

**⚠ Confirmed gap:** the search has **no recent places, no saved addresses, and
no home/work shortcuts** — verified by a content search of
`search_view.dart`/`search_panel.dart` returning zero matches for
recent/saved/home/work. A destination must be re-typed or re-dragged every trip.

## 5. The rest of the journey (summary)

| Surface | Route | Notable [SRC] |
|---|---|---|
| Trip fare | `/calculatefee` | Fare as `displayLarge` 40px; **`FeeWaitingBanner`** only — no "paid" state; explicit **`fareUnavailable`** card + Retry (`calculate_fee_screen.dart:119-135, 174-199`); `FeeErrorView` keeps waiting + Retry (`:205-251`). No back button (trip is over). |
| Active ride | `/booking` (`booking_map_screen.dart`, `booking_sheet.dart`) | Driver card, cancel, socket-driven. |
| Rating | `/rating`, `/rate_driver` | Star rating. |
| Receipt | `/receipt` | Trip summary. |
| History | `/history`, `/historydetail` | `My Booking` tab. |
| Invite / credit | `/invite-rewards`, `RideCreditRow`, `InviteFab` | D40 ride credit; `inviteFeatureEnabled => true`. |
| Announcements | `/announcement`, `/announcement_detail` | Bell entry commented out on Home. |
| Profile / settings | `/profile`, `/termcondition`, `/contactus` | Logout, language, terms, contact. |
| Auth | `/splash`, `/login`, `/otp`, `/register` | Detailed in `docs/ux_ui_audit/features/01_authentication_onboarding.md`. |

**No wallet / payment-method management screen exists** (no route; `calculate_fee`
only *displays* the backend's `paymentMethod`). **No saved-places feature exists.**

## 6. Strengths (already strong vs any competitor)

1. **Real error recovery on booking** — `_failBooking` retry re-runs the same
   request from a persisted `BookingSession` (`logic.dart:525-535, 630-646`).
   Most competitors' "Try again" only dismisses a dialog.
2. **Re-entrancy safety** — booking is guarded by the session, not a view toggle;
   the double-tap/stuck-overlay defects are explicitly fixed (`logic.dart:500-535`).
3. **Socket backstop** — a 5s server poll covers a lost/driver-side socket push
   (`logic.dart:546-605`). Resilient by design.
4. **Skeleton loading, not spinners**, on Home and Fare — layout-stable shimmer.
5. **Centralised vehicle presentation** — `vehicleCellData()` keeps Home and Map
   from drifting (`vehicle_cell_data.dart`).
6. **Address honesty** — `addressFailed` retry + "no address is said to be
   none, rather than leaving a stale one" (`logic.dart:319-323`).
7. **Constructor injection** across `MapLogic`/`HomeLogic` — testable controllers.
8. **Optional destination / metered booking** — a deliberate, documented product
   choice (`map_bottom_sheet.dart:26-31`).

## 7. Weaknesses (source-confirmed)

1. **No map on Home** — Home is a promo + list; the map only appears at `/map`.
2. **No recent/saved places** — every trip re-enters the destination.
3. **No coupon / promo-code entry** on the booking sheet — the Home banner is
   static demo copy (`app_locale.dart:30-32`) that only fires a toast.
4. **No cash / payment-method choice** on the booking sheet.
5. **No Support / Help surface** with canned issue categories.
6. **No points / rewards / referral UI** on the Profile tab (only invite/credit).
7. **Pickup = map-centre drag**, which is precise but has no search fallback for
   the pickup itself (search is destination-only via `/dragMap`).
8. **Auth screens** carry 4 High issues (cross-controller `LoginLogic` coupling,
   AND-of-nulls OTP success, fake "Try again", non-scrollable Login) — see
   `docs/ux_ui_audit/features/01_authentication_onboarding.md`.
9. **Announcement bell is commented out** (`home/view.dart:159-166`), so the
   `/announcement` feature is unreachable from Home.
