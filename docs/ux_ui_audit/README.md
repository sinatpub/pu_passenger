# PU Taxi Passenger — UX/UI Audit

> Read-only audit of the Flutter passenger app (`com.tara.passenger`), one feature
> at a time, benchmarked against PassApp. **No application code, theme,
> dependency, or existing file is modified by this audit.** The only writes are
> the documents under `docs/ux_ui_audit/`.

- Repository root: `/Users/sinatnon/open_source/pu_taxi_system/pu_passenger`
- App entry: `lib/main.dart` → `lib/app/root_main.dart` (`GetMaterialApp`, `initialRoute: /splash`)
- State management: **GetX only** (screen-per-folder: `binding.dart`, `logic.dart`, `state.dart`, `view.dart`; `lib/routes/app_pages.dart` holds routes + DI)
- Design tokens: `lib/core/theme/ta_*.dart` (the "Taarraa" system)
- Audit date: 2026-10-13

---

## 1. Scope

In scope:

- The complete passenger user journey across every screen reachable from
  `lib/routes/app_pages.dart`.
- Visual/UI specification (colors, type, spacing, radius, elevation, icons,
  assets), states, flows, and Flutter implementation quality.
- Comparison of the running code against the intended redesign specs in
  `docs/ux-redesign/` and the prototype in `docs/taarraa-ui-prototype.html`.

Out of scope:

- The driver app (`../pu_driver`), the backend, and DNS/secrets.
- Code changes of any kind. Every section that proposes a change is marked
  **Proposed** and separated from observed behaviour.

## 2. Evidence standards

Every finding carries an evidence tag. This audit does **not** use the built-in
browser, an emulator, or screenshots (none are checked into the repo — a search
for image files outside `assets/`, `android/`, `ios/` and `build/` returns
nothing). Therefore:

| Tag | Meaning |
|---|---|
| **[SRC]** | Source-verified. Read directly from the file; a path (and line where useful) is cited. Trustworthy. |
| **[INFER]** | Source-based inference about runtime/visual behaviour (e.g. "this reads as cramped"). Not yet seen on a device. |
| **[RUNTIME]** | Confirmed on a device/emulator or from a screenshot. **Not available in this environment** — flagged where verification is still owed. |

Wording rules:

- Layout/visual statements from code are **[SRC]** for "what the code draws" and
  **[INFER]** for "how it feels/looks".
- If an exact pixel value cannot be verified, it is not asserted; the token or
  literal is quoted instead.
- "Spec says X, code does Y" is only written when both are quoted from files.

## 3. Severity definitions

| Severity | Definition |
|---|---|
| **Critical** | Blocks a core task, loses data/session, or crashes. e.g. a flow that cannot complete. |
| **High** | Major friction or a broken/contradictory state on a core path; likely to cause abandonment or wrong actions. |
| **Medium** | Noticeable usability or consistency problem; workaround exists; degrades polish or clarity. |
| **Low** | Cosmetic, wording, minor inconsistency, or a nit; no task impact. |

## 4. Method (how each feature is audited)

For every feature the report follows sections **A–H**:

- **A** Feature overview (purpose, actors, entry/exit, dependencies, paths)
- **B** Screen inventory (route, file, hierarchy, scroll/safe-area/keyboard, assets)
- **C** User flow & interaction (action → response → controller → API → state → navigation/error), with Mermaid where useful
- **D** Detailed UI specification (tokens vs hardcoded; type, spacing, radius, shadow, icons, hierarchy, Khmer/Latin, a11y)
- **E** UI states (initial, loading, success, empty, validation, error/offline, disabled, permission, double-submit, keyboard, long text)
- **F** UX evaluation (numbered issues `F01-01`… with severity, evidence, recommendation, confirmation status)
- **G** Flutter implementation review (architecture, logic-in-UI, duplication, hardcoded styles, rebuilds, responsiveness)
- **H** Future modernization opportunities (UX / UI / Engineering), each marked **Proposed**

## 5. Progress tracker

| # | Feature | Doc | Status |
|---|---|---|---|
| 01 | Authentication & Onboarding (Splash, Login, OTP, Register) | `features/01_authentication_onboarding.md` | ✅ Complete — awaiting review |
| 02 | Home & Vehicle Selection | `features/02_home_vehicle_selection.md` | ⏳ Pending |
| 03 | Map, Location Search & Booking Request | `features/03_map_location_booking.md` | ⏳ Pending |
| 04 | Active Ride Tracking | `features/04_active_ride.md` | ⏳ Pending |
| 05 | Fare & Payment | `features/05_fare_payment.md` | ⏳ Pending |
| 06 | Rating & Receipt | `features/06_rating_receipt.md` | ⏳ Pending |
| 07 | Ride History & Detail | `features/07_history.md` | ⏳ Pending |
| 08 | Profile & Settings (incl. Terms, Contact, language, logout) | `features/08_profile_settings.md` | ⏳ Pending |
| 09 | Invite, Rewards & Ride Credit | `features/09_invite_rewards.md` | ⏳ Pending |
| 10 | Announcements | `features/10_announcements.md` | ⏳ Pending |
| 11 | Notifications, App Update & App Shell | `features/11_notifications_shell.md` | ⏳ Pending |

Status legend: ✅ complete · 🔄 in progress · ⏳ pending · ⛔ blocked

## 6. How to continue the audit

The workflow is strictly sequential (one feature per pass):

1. Read the feature's `binding.dart`, `logic.dart`, `state.dart`, `view.dart`,
   its `data/` layer, and every shared widget it renders.
2. Fill sections A–H of the feature document with **evidence-tagged** findings.
3. Update the progress tracker above.
4. **Stop** and wait for the reviewer.

Reviewer commands:

- `Next feature` — audit the next `⏳ Pending` feature in the tracker.
- `Re-audit` — revisit the current feature; incorporate any screenshots or new
  information supplied, and revise findings/tags.

## 7. Reference documents already in the repo

These pre-date this audit and are cross-referenced, not duplicated:

- `docs/passenger_design_system.md` — the code-derived design-system report (tokens + component inventory + inconsistencies).
- `docs/reverse-engineering/` — tech stack, app flow, UI inventory, design tokens, redesign blueprint.
- `docs/ui-reference/` — prototype screen map, component inventory, tokens, interactions, assets, Flutter mapping.
- `docs/ux-redesign/` — design direction, design system, screen redesign specs, component spec, interaction/state spec, implementation plan, decision log.
- `docs/taarraa-ui-prototype.html` — the interactive prototype (the visual target for PassApp-style redesign).
