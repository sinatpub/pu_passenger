# 05 — Interactions & States

> Every interaction below is traceable to an `onclick`/addEventListener or a `later`/`every`
> timer in the HTML. **SIMULATED vs REAL** is called out explicitly — strengths and all.
> Punctuation of toasts is verbatim from the source (the "·" separators included).

## 1. Navigation behaviour

- Router `show(id)`: cancels all pending simulation timers (`clearSim()`), closes sheet/dialog,
  hides `#bookOv`, toggles `.active` via `fadeUp .28s`, updates the tab bar and panel, then runs
  the screen renderer. Charts and maps re-render on each visit.
- TABBED screens (`s-home`, `s-history`, `s-profile`) show the floating pill tab bar; all other
  screens hide it.
- Exit paths are the explicit back buttons (`.appbar` `.icon-btn` with `i-back`), the map-top
  back, history card taps, tab bar, or the auto-advance timers documented below.
- Modals (sheet/dialog) close on backdrop tap and on `Escape`; both also cancel sim timers.

## 2. Auth flow

1. **Splash:** `show('s-splash')` on boot; auto-advance to `s-login` after **2.2s** (`later`),
   or instantly via "Skip →" link.
2. **Login:** `doLogin()` strips non-digits from the phone input; if `digits.length < 8` →
   `phoneErr` (red text) + full-width `shake` class on the `.field` + `navigator.vibrate(60)`.
   Otherwise stores `+855 <digits>` into the OTP screen `#otpPhone` and moves to `s-otp`.
   The phone field receives Enter → `doLogin()`. `#loginBtn` is disabled until input is non-empty
   (input listener).
3. **OTP:** 4 single-digit inputs auto-advance on keyup; backspace steps back; when all 4 are
   filled → after **700ms** land on `s-home` and toast "🎉 Welcome!". A 30s countdown runs
   (`later` 1000ms), at 0 hides `#otpTimer` and shows `#resendBtn`; `resendOtp()` restarts the
   countdown + toasts "📩 New code sent — type any 4 digits". Back → `s-login`.
4. **Register:** entering name enables `#regBtn` only when `name.trim().length >= 2`.
   `#cam` button toasts "📸 Photo picker coming (connect image_picker)". "Create" →
   `finishRegister(false)` (guards name length); "Skip" → `finishRegister(true)`. Both → `s-home`
   + "🎉 Welcome!".

> **SIMULATED:** any 4 digits accept the OTP; no backend/auth is involved. Real app verifies OTP
> at `register/login` GetX flows with real endpoints.

## 3. Loading states

- **Home skeleton:** `loadHome(true)` renders three `.skel` shimmer placeholders into `#vehList`;
  after **900ms** `renderVehicles(S.vehicles)` replaces them (first visit has no shimmer —
  `once` flag). Refresh button re-runs the shimmer + toasts "↻ Refreshed".
- **Booking overlay:** `requestBooking()` sets `#bookOv` visible with spinner + "Contacting
  nearby drivers…"; after 1.8s → "Driver found!"; after 2.8s → `show('s-booking')`. Cancel
  (`cancelRequest()`) hides it + toasts "Trip cancelled".
- **Fee wait:** after the booking `finishTrip`, `markPaid()` runs after 9s (or on the demo
  "Simulate: driver confirms payment" button); before that the `#payBox` badge reads "Waiting for
  driver to confirm payment" (amber).

## 4. Error states

- **Login invalid:** `#phoneErr` red label + `.shake` field + 60ms vibrate.
- **Booking with no destination:** "Book Now" is `disabled` until a destination is set (via
  search); there is no toast on tap.
- **OTP demo:** the prototype has no wrong-code state (any 4 digits pass).
- **Search no match:** `.place.empty` card "No places match your search" with an icon.
- **SIMULATED (no real error domain):** there is no network/API error handling — the prototype
  simulates success end-to-end. Real app surfaces socket/API failures via GetX snackbars and its
  polling policies (see `roadmap.md` C5/Q2).

## 5. Toast

`toast(msg)` renders a navy pill with a green check (~2.4s auto-hide). Verbatim messages:

- "🎉 Welcome!", "📩 New code sent — type any 4 digits", "📍 Centered on your location"
  (map locate fab), "Destination set ✓" (pickPlace), "📸 Photo picker coming (connect
  image_picker)", "📞 Calling…", "🛡️ In-app emergency SAFETY (coming in v2)",
  "🏠 Saved places coming in v2", "Trip cancelled", "↻ Refreshed", "🎉 Promo applied: FLY20",
  "🚪 Logged out", "✉️ Email us for office hours" (contact), "Calling Smart: 015 755 133" /
  "Calling Cellcard: 012 345 678" (contact rows).

## 6. Dialog

`openDialog(html)` → `.dialog` + `.backdrop` (Escape closes). Used for:

- **Cancel booking** (`askCancel`): "Cancel booking?" / "Your driver will be notified if you
  cancel a 5-min ride."; "Yes, cancel" (danger) → `s-home` + "Trip cancelled"; "Keep waiting"
  → close.
- **Logout** (`askLogout`): "Log out?" / "You'll need to log in again to schedule rides.";
  "Log out" (danger) → `s-login` + "🚪 Logged out"; "Not now" → close.

## 7. Bottom sheet

`openSheet(html)` → `.sheet` + `.grab` (Escape closes). Used for:

- **Tariff sheet** (`openTariff`): per-vehicle fare preview (`.kv` rows + "Minimum $1.50 · $0.60/km" +
  "Got it").
- **Prototype jump sheet** (`openJumps`): the `s-ds` screen list (prototype-only).

## 8. Micro-interactions

- **Splash progress bar** `.splash-load` fills to `width:46%` on boot.
- **Fade-up** screen transition (`.fadeUp .28s`).
- **Hover states** on `.place`, `.hcard`, `.news` (rotate/translate), thumbnail hover.
- **Focus rings** on `.field` (brand border on `:focus-within`), `.otp`.
- **Pulse** on `.status-pill` (scale ring) and the bell `.dot` when unread-ish.
- **Car bounce** on the booking overlay (`.car-bounce` vertical).
- **vibrate(60)** on invalid login; **`.tstep.done` check** animate the fee steps.
- **Home skeleton shimmer** (described in §3).
- **Mini-map** marker slide to destination (`.moveMarker`, `transition 1.2s`).

## 9. Keyboard handling

- OTP: Enter on the phone field triggers `doLogin()`; OTP inputs auto-advance; Escape closes
  sheets/dialogs. `data-i18n`/JA behaviour outside of inputs is not otherwise intercepted.

## 10. Accessibility (as implemented in the prototype)

- `aria-hidden` behind phone frame; icon buttons have `aria-label` on interactive controls
  (buttons), labels via `aria-labelledby` where present. Not a fixture for a11y-of-record in the
  HTML — treat as investigation-flagged (matches `roadmap.md` P3 contrast note).
- **Khmer/EN runtime language toggle** (`.seg` on login/register/profile) switches
  `data-i18n`/`data-i18n-ph` text on the fly — the real app's locale maps live in
  `lib/translations/` and are kept in sync (see `roadmap.md` F2).

## 11. State inventory

| State | Owner | Re-render trigger | Notes |
| --- | --- | --- | --- |
| `S` global (vehicle, dest, star, tags, once, histTab, paid) | prototype | `show()`/demo functions | source of truth for all renders |
| vehicle selection | `goMap(id)`/`renderMap` | tariff sheet / map sheet | single `S.vehicle` |
| destination | `pickPlace` (`S.dest`) | map + fee + receipt | defaults to `PLACES[0]` inside map screens if unset |
| star rating | `setStar(n)` | `.lit` toggle on 5 stars | only state that gates `#rateBtn` |
| tone tags | chip `.on` toggle | CSS only | visual only, no `S` effect |
| history tab | `setHistTab(i)` | re-render list | Completed/Cancelled |
| payment | `markPaid(true)` | badge flip + move to rating | amber→green |
| lang | `setLang('en'/'km')` | re-apply i18n | persists in-memory only |

> **SIMULATED vs REAL (summary)** — see `roadmap.md` D14: simulated elements (maps, GPS, OTP,
> bookings, fare USD, payment confirm, calls, safety, saved places, promo, photo picker, rating
> submit) must be replaced by real integrations in the app; the UI reference reproduces exactly
> what the prototype shows so the redesign can be verified 1:1.