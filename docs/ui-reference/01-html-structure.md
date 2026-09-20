# 01 — HTML Structure & Architecture

> Source of truth: `docs/taarraa-ui-prototype.html` (single file, 994 lines, ~62 KB).
> Inspection date: 2026-09-14. This document describes what the prototype **actually contains**;
> nothing is inferred beyond the code. It is the passenger counterpart of `pu_driver/docs/ui-reference/01`.

## 1. Prototype type

| Question | Answer | Confidence |
| --- | --- | --- |
| One file or many? | **One** self-contained HTML file | CONFIRMED |
| Page model | Single-file **SPA** (single `<html>` document; "pages" are `<section class="screen">` elements toggled by a vanilla-JS router) | CONFIRMED |
| Static or JS-driven? | **JavaScript-driven** — the pages are static shells; most content is rendered by JS render functions | CONFIRMED |
| CSS approach | **Custom CSS** (hand-written). No Tailwind, no Bootstrap, no framework | CONFIRMED |
| JS framework | **None** — vanilla ES6. No jQuery, React, Vue, GetX, etc. | CONFIRMED |
| Build artifacts | None (no bundler output, no minified app code) | CONFIRMED |
| Design tokens | **CSS custom properties** in `:root` (colour, radius, shadow) | CONFIRMED |
| Theme | **Light theme only** (`--bg:#F6F6F7`, white cards/sheets) — unlike the driver prototype, which is dark | CONFIRMED |
| Icons | **Inline SVG `<symbol>` sprite** (27 symbols, stroke icons, 24×24 viewBox) referenced via `<use>` | CONFIRMED |
| Maps | **Procedurally generated inline SVG** (a `mapSVG()` JS function draws a stylized light grid map) — no real map provider | CONFIRMED |
| Audio | **None** — no WebAudio, no sample files (contrast: the driver prototype synthesizes sounds) | CONFIRMED |
| i18n | Runtime **EN / Khmer dictionary** (`I18N` object + `data-i18n`/`data-i18n-ph` attributes, `~98` keys) | CONFIRMED |
| Data | Hard-coded **JS object literals** (vehicles, places, driver, trips, news, terms) | CONFIRMED |

**Conclusion:** light-theme static-prototype SPA, fully self-contained, no network dependencies for UI rendering.

## 2. File structure (logical)

```
taarraa-ui-prototype.html
├── <head>
│   ├── meta viewport (width=device-width, initial-scale=1, viewport-fit=cover)
│   ├── meta theme-color (#FF4500)
│   └── <style>  — ALL CSS (single block, ~270 lines, lines 8–284)
├── <body>
│   ├── <svg> icon sprite — 27 <symbol> definitions (i-home … i-send)
│   ├── .stage (flex row: prototype sidebar + phone frame)
│   │   ├── .panel (prototype control sidebar — NOT part of app UI)
│   │   └── .phone > .host (device frame — the "app viewport")
│   │       ├── .statusbar (static: 9:41 · 5G · ▂▄▆ · 🔋)
│   │       ├── 19 × <section class="screen">  (s-splash … s-ds)
│   │       ├── nav.tabbar (floating pill tab bar, 3 tabs — APP UI)
│   │       ├── #protoFab (prototype-only jump control — NOT app UI)
│   │       ├── #sheetRoot (generic bottom sheet + backdrop)
│   │       ├── #dialogRoot (generic dialog + backdrop)
│   │       └── #toast (global toast)
│   └── <script>  — ALL application JS (single block, lines 598–991)
│       ├── data constants (VEHICLES, PLACES, PICKUP, DRIVER, HIST_*, NEWS, TERMS)
│       ├── I18N dictionary + t()/applyLang()/setLang() helpers
│       ├── state object S{} + simulation helpers (later/every/clearSim)
│       ├── toast / openSheet / openDialog helpers
│       ├── vSVG() vehicle art (tuk / sedan / suv / van / vip)
│       ├── mapSVG() / moveMarker() (procedural map + marker animation)
│       ├── router: show() / goMap() / NAMES / JUMPS / TABS / openJumps()
│       ├── auth: doLogin / otpInit / startOtp / resendOtp / finishRegister
│       ├── home: loadHome / renderVehicles (skeleton shimmer)
│       ├── booking: renderMap / openTariff / requestBooking / startBookingSim / renderBookingChrome / askCancel
│       ├── search: renderSearch / pickPlace
│       ├── fee/rating/receipt: renderFee / markPaid / renderRating / setStar / submitRating
│       ├── history/detail: renderHistory / renderHDetail
│       └── news/terms: renderNews / openNews / renderTerms / askLogout
│   └── <script> Cloudflare artifacts (see §5)
```

## 3. Top-level DOM structure (semantic)

```
<body>
└── .stage                              # flex row; prototype presentation shell
    ├── .panel                          # PROTOTYPE CONTROL PANEL (not app UI)
    │   ├── header (title + happy-path hint "1 Splash → … → 10 Rating → Receipt")
    │   ├── #jumpList (screen jump buttons, generated from JUMPS)
    │   ├── row2: language toggle (🌐 EN/ខ្មែរ) + reset (↺)
    │   └── #curName (current screen label)
    └── .phone > .host                  # the simulated mobile device
        ├── .statusbar                  # 9:41 · 5G · ▂▄▆ · 🔋 (static, pointer-events:none)
        ├── [ 19 × <section class="screen"> ]   # the "pages" (see 02-screen-map)
        ├── nav.tabbar                  # floating pill tab bar — APP UI (3 tabs, shows on home/history/profile only)
        ├── #protoFab                   # "Prototype" FAB → jump sheet (prototype-only)
        ├── #sheetRoot > .backdrop + .sheet   # generic bottom sheet
        ├── #dialogRoot > .backdrop + .dialog # generic dialog
        └── #toast                      # global toast notification
```

## 4. Screen switching mechanism (the "router")

- Every page is a `<section class="screen">`; CSS keeps them `display:none` and only `.screen.active`
  is visible (`.screen-center.active` → `display:flex`). `.screen.active { animation: fadeUp .28s ease }`.
- `show(id)` is the router: `clearSim()` (kills all timers/RAF), closes sheet + dialog, hides the
  booking overlay `#bookOv`, toggles the `.active` class, updates the `.tabbar` and the panel
  `#curName`/`#jumpList` highlight, then calls the screen's render function when one exists.
- A convenience detail in `show()`: entering `s-map`/`s-booking`/`s-fee`/`s-rating`/`s-receipt`
  without a chosen destination silently defaults `S.dest = PLACES[0]` (so the demos always run).
- `goMap(id)` sets `S.vehicle` (from the home vehicle row) then `show('s-map')`.
- `key` values come from `NAMES`/`JUMPS` (19 destinations, all physical screens — there are no
  `shell:<tab>` pseudo-screens because navigation is per-screen with a tabbar, not a drawer).
- Screen transition: `.screen.active { animation: fadeUp .28s ease }` (opacity + 10px translateY).
- Keyboard: `Escape` closes the sheet + dialog.

## 5. Artifacts / non-app content (excluded from target-UI analysis)

| Element | Why it's not app UI | Confidence |
| --- | --- | --- |
| `.panel` sidebar | Prototype-only navigation/demo console rendered next to the phone | CONFIRMED |
| `#protoFab` + `openJumps()` sheet | Prototype-only "jump to screen" control | CONFIRMED |
| `#curName` / `#jumpList` | Prototype-only current-screen indicator and screen list | CONFIRMED |
| `s-ds` screen | In-prototype "Design tokens · v2" reference page — it IS the style guide for the producers, not a shipping app screen | CONFIRMED (reference screen) |
| Demo affordances — splash "Skip →", OTP "type any 4 digits", booking "Skip ▸", fee "Simulate: driver confirms payment", register "Skip" | Simulation shortcuts present in the HTML so reviewers can run the happy path manually | CONFIRMED (see `roadmap.md` §0 — `D14` explicitly excludes all of these) |
| Cloudflare scripts (3: `email-decode.min.js` at line 598, `beacon.min.js` module at 992, libs challenge at 993) | Copied-page artifacts; not part of the prototype's intent | CONFIRMED (artifact) |
| Static `.statusbar` (9:41, 5G, ▂▄▆, 🔋) | Cosmetic device chrome inside the phone frame | CONFIRMED |

## 6. Architectural summary

- **Light map-first booking.** The primary booking state is a light-grey full-bleed map with a
  persistent bottom sheet (pickup → destination → stats → note → vehicle → Book Now). Everything
  is rendered by `renderMap()` into `#mapSheet`; the tariff sheet, dialogs, and overlays are
  generic containers filled at runtime.
- **19 static screens + runtime renderers.** Only the screen shells + icon sprite are static HTML;
  vehicle rows, search results, booking chrome, fee receipt, rating, history and news content are
  built by template-literal renderers.
- **Single shared state object `S`** drives the selected vehicle, destination, star rating, tag
  selection, home "once loaded" flag, history tab, and payment flag; demo events mutate `S` and re-render.
- **Simulation utilities** (`later`, `every`, `clearSim`) manage all timers so navigation can
  cleanly cancel pending work.
- **Tab bar is real app UI.** The floating pill `.tabbar` (Home / My Booking / Profile) shows only
  on `s-home`, `s-history`, `s-profile` (driven by the `TABS` map) — consistent with the app's
  three-tab bottom nav (see `roadmap.md` C1).