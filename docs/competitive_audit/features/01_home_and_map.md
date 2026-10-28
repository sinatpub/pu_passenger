# Feature 01 — Home & Map (detailed comparison)

**Pu Taxi:** `/bottomnav`→Home tab + `/map` (booking map).
**PassApp:** Home tab + booking map.
**Status:** ✅ Detailed — this is the completed first feature; the audit stops
here for review.
**Evidence:** Pu Taxi = **[SRC]** (file:line). PassApp = **[OCR]** from official
store assets (which may be pre-5.0.x — see `passapp_reference_evidence.md` §2) or
**[STORE]** copy. Visual colour/type/spacing comparisons are **[UNKNOWN]**.

---

## A. What each app's Home actually is

| | Pu Taxi Home [SRC] | PassApp Home [OCR] |
|---|---|---|
| Structure | Brand header → promo banner → `Choose your ride` → **vertical vehicle list** (`home/view.dart:42-78`) | `Promotion` card → `Special Offer` card → **horizontal circular vehicle row** (`Rormork/Rickshaw/Classic/SUV`) (`ios_03`, `play_18`) |
| Has a map? | **No** | **No** |
| Vehicle affordance | Full-width rows: art + name + `seats · $X/km` + `from $Y` + ETA (`ta_vehicle_row.dart:44-97`) | Small circular icons + label only (`ios_03` y≈0.142) |
| Promo | One **static demo** banner; tap = toast only (`home/view.dart:47-52`) | Two scrollable sections (`Promotion`, `Special Offer`) with real cards (`ios_03`) |
| Language | In-app `AuthLanguageToggle` in the header (`home/view.dart:168`) | Top-right language selector (`ios_02`, `play_15`) |
| Bottom nav | **3 tabs**: Home / My Booking / Profile (`bottom_nav/view.dart:23-37`) | **4 tabs**: Home / My Booking / **Support** / Account (`ios_03`, `play_19`) |
| Notifications | Bell **commented out** (`home/view.dart:159-166`) | Unknown |

**Read:** PassApp's Home is a **promotion-first landing** with a compact vehicle
chooser; Pu Taxi's is a **vehicle-catalogue landing** with one demo banner.
Neither uses a map at Home. PassApp has one more bottom-nav tab (**Support**).

## B. Comparison table (core dimensions)

| Dimension | Pu Taxi Passenger | PassApp | Difference & evidence | Recommendation |
|---|---|---|---|---|
| **Visual hierarchy** | Header → single banner → `Choose your ride` → long vertical list. The list dominates; the CTA is buried inside each row. [SRC `home/view.dart:42-78`] | Promo cards first, then a compact vehicle row. Content-first, chooser-last. [OCR `ios_03`] | Pu Taxi pushes the vehicle choice (the primary action) **below** a demo banner and a list; PassApp surfaces promos then a one-glance chooser. **Colour/type parity unknown.** | Keep the vehicle list, but promote a **single primary "Where to?" entry** so booking starts from Home in one tap. |
| **Primary CTA** | Implicit — tapping a vehicle row opens `/map`. No explicit "Book / Where to?" button on Home. [SRC `home/view.dart:70-74`] | Implicit — the `Where to?` search lives on the **booking map** (`ios_04`), not Home; vehicle row is a chooser. [OCR `ios_04`] | Both defer the explicit CTA to the map. Pu Taxi requires: Home → tap vehicle → map → tap drop-off → drag map → book. | Add a **`Where to?` search card on Home** that opens `/map` with a pre-set destination — collapses 3 steps to 2. |
| **Map visibility** | No map at Home; map appears only at `/map` with a **fixed centre pin** for pickup. [SRC `map_screen/view.dart:75-78`] | Map is the booking surface with a **`My Location`** centre pin + nearby-vehicle markers + a **"1 min" ETA bubble**. [OCR `ios_04`] | Roughly equivalent structure. PassApp shows **live nearby-vehicle ETA on the pin**; Pu Taxi shows nearby-driver markers but **no ETA bubble** on the map. | Show a **"~N min"** badge near the pickup pin from the `driverAround` data already fetched (`logic.dart:463-489`). |
| **Vehicle selection UI** | Inline **chips** on the map sheet (name + fare) + full rows on Home. [SRC `map_bottom_sheet.dart:365-435`] | A dedicated **`Please choose service`** sheet (`play_13`) **and** a compact Home row (`ios_03`). | PassApp **separates** vehicle choice into its own sheet; Pu Taxi inlines it. PassApp also offers a Home-level quick pick. | Optional: a compact vehicle strip on Home mirroring the map chips, reusing `vehicleCellData()`. |
| **Fare display** | Per-chip estimate + **inside the Book button label** (`Book Tuk Tuk · $fare`). No standalone fare row. [SRC `map_bottom_sheet.dart:171-178`] | An explicit **`Fare: 3,200 KHR`** row above `Confirm Booking`. [OCR `ios_05`, `ios_06`] | PassApp gives fare its **own labelled row**; Pu Taxi embeds it in the CTA text. PassApp uses **KHR**; Pu Taxi uses **USD** (commit `d099043`). | Add a **dedicated fare row** (`Fare: $X`) above the Book button; keep the CTA label short ("Book Tuk Tuk"). |
| **Booking options** | Note field (if destination), Ride-credit toggle (D40), Tariff link. **No cash / coupon / option.** [SRC `map_bottom_sheet.dart:88-134`] | Action row **`Cash` · `Coupon` · `Option` · `Note`** on the booking sheet. [OCR `ios_04`, `ios_05`] | PassApp exposes **payment method, coupons and options inline** before booking. Pu Taxi exposes only Note + credit. **Coupon is a confirmed gap** (`pu_taxi_current_state.md` §7.3). | Add a **booking-options row** (Payment / Coupon / Note) reusing the existing `TaNoteField`; coupon needs backend support. |
| **Pickup selection** | **Drag the map**; the fixed centre pin commits on `onCameraIdle`; reverse-geocode + retry. No pickup search. [SRC `map_screen/view.dart:75-78`, `logic.dart:251-263`] | Centre pin labelled **`My Location`** + nearby markers; a `My Location` / recenter control. [OCR `ios_04`] | Both use a centre-pin model. Pu Taxi's drag-to-set is precise but has **no search fallback for pickup**; PassApp's pin is labelled and near-by cars are shown with ETA. | Keep drag, but add a **"Search pickup"** shortcut and surface the resolved address more prominently. |
| **Destination selection** | Optional. `Add drop-off (optional)` → `/dragMap` search (min 3 chars, **no recents/saved**). [SRC `map_bottom_sheet.dart:310-329`, `search_panel.dart:48`] | A **place-search list** of named POIs + plus-codes, and a **`Saved Places`** menu in Account. [OCR `ios_05`, `ios_08`, `play_19`] | **Confirmed gap:** PassApp has **Saved Places**; Pu Taxi has **no recents and no saved addresses** — every trip re-enters the destination. | Add **recent + saved places** (Home/Work) to the `/dragMap` search panel. **Highest-value single feature.** |
| **UI states** | Home: skeleton/empty/toast. Map: booking overlay, 5s driver-wait poll, **real retry** on failure, address-retry. [SRC `logic.dart:525-605`] | Not verifiable from static art. | Pu Taxi's **error/recovery is demonstrably strong** (real retry, session-backed). PassApp's states **[UNKNOWN]** — see screenshots S8/S23. | No change needed; this is a Pu Taxi **strength** to preserve. |
| **Accessibility** | `TaIconButton` semantic labels + 48px targets; `TaBottomNav` labels; Khmer via `.tr`. Contrast of `textMuted` on white is borderline. [SRC `pu_taxi_current_state.md`] | Unknown. | Pu Taxi has explicit a11y affordances; PassApp **[UNKNOWN]**. | Fix `textMuted` contrast; add live-region for booking state. |
| **Loading** | Skeleton shimmer (Home, Fare), overlay (booking). [SRC `home/view.dart:201-227`] | Unknown. | Pu Taxi avoids spinner-spikes on content; PassApp **[UNKNOWN]**. | Preserve skeleton approach. |

## C. Interaction / flow comparison

Pu Taxi booking, start→confirm (all [SRC]):

```
Home tab → tap a vehicle row (/map with vehicleId)
  → map opens, centre pin = pickup, reverse-geocode (retry on fail)
  → (optional) tap "Add drop-off (optional)" → /dragMap → search (≥3 chars) or drag
      → Confirm → back to /map, polyline + fare computed
  → (optional) note field, ride-credit toggle
  → tap "Book Tuk Tuk · $fare"
  → BookingLoadingOverlay (cancel) + 5s driver-wait poll + socket
```

PassApp booking (order from [OCR], not a full runtime trace):

```
Home tab → vehicle row / service sheet ("Please choose service")
  → map with "My Location" pin, nearby cars + "1 min" ETA
  → "Where to?" search → Pick Up / And Drop Off list → Fare: 3,200 KHR
  → Cash / Coupon / Option / Note
  → "Confirm Booking"
```

**Friction delta:** PassApp reaches a priced, option-configured booking from a
clear `Where to?` + `Confirm Booking` pair. Pu Taxi's path is longer (Home →
vehicle → map → optional drag map → search → book) and **lacks recents/saved
places**, so the destination step is the biggest repeat cost.

**Where Pu Taxi is ahead:** a genuine **retry** on booking failure backed by
`BookingSession` (`logic.dart:525-535`), a **socket-independent 5s poll**
(`:546-605`), and a **metered/optional-destination** mode (`map_bottom_sheet.dart:26-31`).

## D. Architecture comparison

| Aspect | Pu Taxi [SRC] | PassApp |
|---|---|---|
| State mgmt | **GetX**, screen-per-folder, constructor injection (`MapLogic({...})`, `logic.dart:76-100`) | Native Android (per binary analysis) — **[UNKNOWN]** internals |
| Shared tokens | `TaColors`/`TaTextStyles`/`TaRadius`/`TaShadows`; but **`.d` scaling & literals** for spacing (`20.d`, `55%`, `62.d`) | Unknown |
| Component reuse | High — `TaVehicleRow`, `TaButton`, `TaIconButton`, `TaPressable`, `TaSkeleton`, `vehicleCellData()` | Unknown |
| Logic in UI | Low on Home/Map — controllers own logic; view is mostly declarative. `canSubmitRegistration`-style pure helpers exist. | Unknown |
| Duplication risk | `AuthDatasource/Repository` re-registered in 3 bindings (auth only); Map/Home are clean. | Unknown |

**Verdict:** Pu Taxi's architecture is **not** the gap. The gaps are **feature
parity** (saved places, coupon, payment choice, support, rewards) and **a few
flow shortcuts** — not component quality or state management.

## E. Feature 01 findings (numbered, P0–P3)

### H-01 · No recent or saved places — every trip re-types the destination
- **Pu Taxi:** `/dragMap` search has min-3-chars, no recents, no saved
  addresses, no Home/Work (`search_panel.dart:48-186`; grep = 0 matches).
- **PassApp:** `Saved Places` menu in Account + a rich place-search list
  [OCR `ios_05`, `ios_08`, `play_19`].
- **Problem:** the single highest-frequency action (entering a destination) is
  the most expensive. Repeat trips to Home/Work cost a full search each time.
- **Severity:** **P1 — High.** Confidence **High** for the gap; **Medium** for
  how PassApp presents it.
- **Benefit:** fewer taps per booking; faster, happier repeat use.
- **Complexity:** Medium (local store or backend `saved_places`).

### H-02 · No explicit fare row — fare buried in the CTA label
- **Pu Taxi:** `Book Tuk Tuk · $fare` (`map_bottom_sheet.dart:171-178`).
- **PassApp:** `Fare: 3,200 KHR` as its own row [OCR `ios_05`, `ios_06`].
- **Problem:** the amount is secondary to the action label; harder to scan and
  compare across vehicle chips.
- **Severity:** **P2 — Medium.** Confidence **High** (both sides visible).
- **Benefit:** clearer price transparency before commit.
- **Complexity:** Low.

### H-03 · No payment-method / coupon / options row on the booking sheet
- **Pu Taxi:** only Note + Ride-credit (`map_bottom_sheet.dart:88-134`).
- **PassApp:** `Cash` · `Coupon` · `Option` · `Note` [OCR `ios_04`].
- **Problem:** passengers cannot choose cash/ABA or apply a promo at booking;
  the Home promo banner is static demo copy that only toasts (`home/view.dart:51`).
- **Severity:** **P2 — Medium** (coupon/payment need backend support — flag as
  a product dependency, not just UI). Confidence **High** for the gap.
- **Benefit:** promo redemption + payment flexibility; aligns with PassApp's
  verified coupon feature.
- **Complexity:** Medium–High (backend).

### H-04 · No Support / Help surface; bottom nav has 3 tabs vs PassApp's 4
- **Pu Taxi:** Home / My Booking / Profile; a `/contactus` route exists but is
  not a nav tab (`bottom_nav/view.dart:23-37`, `app_pages.dart:57`).
- **PassApp:** Home / My Booking / **Support** / Account [OCR `ios_03`].
- **Problem:** self-serve issue reporting (PassApp's canned list: "Report driver
  cheat", "Cannot booking", "Forgot stuff"…) is not reachable in one tap.
- **Severity:** **P2 — Medium.** Confidence **High** for the nav-count gap.
- **Benefit:** deflection of support load; trust.
- **Complexity:** Medium.

### H-05 · No nearby-vehicle ETA bubble on the map
- **Pu Taxi:** fetches `driverAround` and draws markers (`logic.dart:463-489`)
  but shows no ETA.
- **PassApp:** a **"1 min"** bubble on the pickup pin [OCR `ios_04`].
- **Problem:** an existing data source isn't surfaced; the passenger can't judge
  wait time before booking.
- **Severity:** **P3 — Low.** Confidence **Medium** (PassApp's bubble is on a
  possibly-stale asset).
- **Benefit:** set expectations; reduce pre-booking hesitation.
- **Complexity:** Low.

### H-06 · Home has no map; the booking map is a separate route
- **Pu Taxi:** Home is list-only; `/map` is pushed. [SRC]
- **PassApp:** Home is also list-only, map is separate [OCR `ios_03` vs `ios_04`].
- **Problem:** **not actually a gap** — both apps do this. Recorded to avoid a
  false "add a map to Home" recommendation that PassApp also doesn't do.
- **Severity:** N/A (no change). Confidence **High**.

### H-07 · Announcement bell commented out → `/announcement` unreachable
- **Pu Taxi:** the bell is commented out pending sign-off (`home/view.dart:159-166`);
  `/announcement` + `/announcement_detail` routes exist (`app_pages.dart:59-61`).
- **PassApp:** shipped **"New announcement on booking screen"** in 3.1.23 [STORE].
- **Problem:** a built feature is dark; PassApp surfaces announcements on booking.
- **Severity:** **P3 — Low** (product decision pending). Confidence **High**.
- **Benefit:** reach the existing announcement feature.
- **Complexity:** Low (uncomment + route).

### H-08 · Static demo promo banner
- **Pu Taxi:** `promoTitle = '20% off airport rides'`, `promoSubtitle = 'Use code FLY20'`
  are **hardcoded** (`app_locale.dart:30-32`); tap → toast only.
- **PassApp:** real `Promotion` + `Special Offer` cards with imagery
  [OCR `ios_03`, `play_16`].
- **Problem:** a non-functional banner that reads as a real offer; erodes trust.
- **Severity:** **P2 — Medium.** Confidence **High**.
- **Benefit:** either remove it or back it with real promotions.
- **Complexity:** Low (remove/link) or High (backend promos).

### Strengths to preserve (no change)
- **Real booking retry** + session persistence (`logic.dart:525-545`).
- **Socket-independent 5s poll** (`:546-605`).
- **Skeleton loading** over spinners (`home/view.dart:201-227`).
- **Centralised vehicle presentation** (`vehicle_cell_data.dart`).
- **Address honesty** + reverse-geocode retry (`logic.dart:301-324`).
- **Metered / optional-destination** booking (`map_bottom_sheet.dart:26-31`).

## F. What is still Unknown for Feature 01

- PassApp's **colours, type, spacing, radii** on Home and the booking map.
- Whether PassApp's store art matches **5.0.x** (`passapp_reference_evidence.md` §2).
- PassApp's **loading/empty/error/offline** states on Home and booking.
- PassApp's **dark mode**, animation, and exact tap targets.

To close these: screenshots **S1–S5, S7, S23** from
`passapp_reference_evidence.md` §5.

## G. Verdict for Feature 01

Pu Taxi's Home/Map is **architecturally sound and, in error handling, ahead of
what PassApp can be shown to do**. It falls behind on **feature parity and flow
efficiency**, not on code quality:

1. **P1 H-01** saved/recent places — the one change with the largest repeat-use payoff.
2. **P2 H-02/H-03/H-08** fare row, booking options (coupon/payment), real promo.
3. **P2 H-04** a Support tab.
4. **P3 H-05/H-07** ETA bubble, announcement bell.

None of these require copying PassApp's look. They require **closing feature
gaps** and **shortening the booking path** — both achievable within Pu Taxi's
existing Taarraa design system and GetX architecture.
