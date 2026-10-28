# Pu Taxi Passenger vs PassApp — Competitive UX/UI Audit

> A read-only, evidence-based comparison of the Flutter **Pu Taxi passenger app**
> (`com.tara.passenger`) against the current **PassApp** passenger app
> (`kh.com.passapp.passenger`), Cambodia's market leader. **No application code,
> dependency, config, or asset is modified.** The only writes are the documents
> under `docs/competitive_audit/`.

- Pu Taxi repo: `/Users/sinatnon/open_source/pu_taxi_system/pu_passenger`
- Pu Taxi stack: Flutter + **GetX only** (screen-per-folder: `binding/logic/state/view.dart`; routes in `lib/routes/app_pages.dart`)
- PassApp: native Android/iOS app by PassApp Technologies, Phnom Penh — **not open source**
- Audit date: 2026-10-13
- Auditor model note: **this model cannot view images**. PassApp screenshots were
  analysed by OCR (Apple Vision) of the official store assets, not by eye — see
  §2 and `passapp_reference_evidence.md`.

---

## 1. Objective

Understand where PassApp's current passenger experience is stronger, where Pu
Taxi falls behind, and which changes deliver the greatest improvement. The goal
is **not** to copy PassApp. It is to borrow proven patterns and produce a
modern, consistent, Pu-Appropriate design that preserves Pu Taxi's business
rules, API contracts, and product requirements.

## 2. The central evidence limitation (read this first)

**PassApp is closed-source and there is no device, emulator, or screenshot set
of the current 5.0.x interface in this workspace.** What *is* verifiable, and
what is not:

| Can verify now | Source |
|---|---|
| PassApp's **feature set, information architecture, screen text and flow structure** | Official App Store + Google Play listing screenshots (OCR'd), store descriptions, release notes, official website `passapptaxis.com` |
| PassApp's **release cadence and recent shipped changes** | App Store version history + Play "What's new" |
| Pu Taxi's **everything** — layout, tokens, states, code paths | Source read + line citations |

| **Cannot** verify | Why |
|---|---|
| PassApp's current **colours, exact spacing, typography, radii, shadows** | I cannot view images; OCR gives text + vertical order, not colour/geometry |
| Whether the store screenshots reflect the **current 5.0.x build** | The iOS screenshots internally print **"Version 2.3.6"**; release notes say "New Home Screen layout" shipped later — so they may be **stale marketing art** |
| Dark mode, animations, live interaction states, performance | No device, no screen recording |

Therefore every comparison row is tagged with evidence confidence. Where a
visual dimension cannot be evidenced, it is written **"Unknown"**, never
guessed. §5 of `passapp_reference_evidence.md` lists the **exact screenshots
needed** to close each gap.

## 3. Evidence standards

| Tag | Meaning |
|---|---|
| **[SRC]** | Source-verified for Pu Taxi (file + line) or for PassApp (OCR text from the official store asset). Trustworthy. |
| **[OCR]** | PassApp text extracted from an official store screenshot. Verifies **text and rough vertical order only** — not colour, spacing, or fidelity to the live 5.0.x build. |
| **[STORE]** | PassApp store listing text, release notes, or website copy. Verifies the claim exists, not the UI. |
| **[INFER]** | Inference from verified evidence. Not yet seen on a device. |
| **[UNKNOWN]** | Evidence insufficient. Explicitly requested in §5. |

**Rule:** a "PassApp does X visually" claim is only made when OCR'd from an
official asset **and** flagged that the asset may be pre-5.0.x. Anything else
is Unknown.

## 4. Severity scale

| Severity | Definition |
|---|---|
| **P0 — Critical** | Blocks a core task or a serious usability problem on the booking journey. |
| **P1 — High** | Significantly increases friction or causes confusion. |
| **P2 — Medium** | Weakens usability or visual consistency; workaround exists. |
| **P3 — Low** | Cosmetic or minor refinement. |

## 5. Scope

In scope: every screen reachable from `lib/routes/app_pages.dart`, mapped to the
equivalent PassApp surface where evidence exists. Out of scope: the driver app
(`../pu_driver`), the backend, secrets, and any code change.

## 6. Feature map & tracker

Pu Taxi routes (`lib/routes/app_pages.dart:41-62`) mapped to the booking
journey. `PassApp` column is what evidence supports.

| # | Feature | Pu Taxi routes / screens | PassApp equivalent | Status |
|---|---|---|---|---|
| 01 | **Home & Map** | `/bottomnav`→Home, `/map` | Home tab + booking map | ✅ **Detailed comparison done** — `features/01_home_and_map.md` |
| 02 | Location selection & search | `/dragMap` (MapDrag + SearchPanel) | "Pick Up / And Drop Off" search + Saved Places | ⛔ Needs current screenshots (visual only) |
| 03 | Vehicle & fare selection | `/map` chips + `calculate_fee` | "Please choose service" + Fare row | ⛔ Needs current screenshots |
| 04 | Booking review & confirmation | `/map` Book button | "Confirm Booking" | ⛔ Needs current screenshots |
| 05 | Driver matching & waiting | `BookingLoadingOverlay`, `/booking` | — | ⛔ Needs current screenshots |
| 06 | Active trip tracking | `/booking` (BookingMapScreen) | — | ⛔ Needs current screenshots |
| 07 | Trip completion, payment, rating | `/calculatefee`, `/rate_driver`, `/rating`, `/receipt` | Trip rating (new category), invoice | ⛔ Needs current screenshots |
| 08 | Trip history & detail | `/history`, `/historydetail` | "My Booking" | ⛔ Needs current screenshots |
| 09 | Wallet, promotions, invitations | `/invite-rewards`, RideCreditRow, promo banner | Reward / Points / Referral / Coupon | ⛔ Needs current screenshots |
| 10 | Profile, notifications, settings | `/profile`, `/termcondition`, `/contactus`, `/announcement` | Account tab | ⛔ Needs current screenshots |
| 11 | Onboarding & authentication | `/splash`, `/login`, `/otp`, `/register` | Login / Sign Up (see `../ux_ui_audit/features/01_...`) | ⏳ Pu Taxi side already audited; PassApp needs screenshots |

Status legend: ✅ detailed · ⏳ partial · ⛔ blocked on evidence.

**Feature 01 is complete and this audit stops there for review**, per the rule
"complete a detailed comparison of the first feature before proceeding". The
remaining rows are blocked on the current-screenshots request in
`passapp_reference_evidence.md` §5 — filling them without those screenshots
would mean inventing PassApp's UI, which this audit will not do.

## 7. Reference documents already in the repo

- `docs/ux_ui_audit/` — the source-level Pu Taxi UX/UI audit (Feature 01 done).
- `docs/passenger_design_system.md` — code-derived design system (tokens + components).
- `docs/ux-redesign/`, `docs/ui-reference/`, `docs/reverse-engineering/` — pre-existing design/tech references.
- `docs/competitive_audit/evidence/passapp/` — the downloaded official PassApp screenshots + OCR transcripts.

## 8. Files

| File | Contents |
|---|---|
| `README.md` | This file — scope, method, evidence rules, feature map. |
| `passapp_reference_evidence.md` | What is and is not verifiable about PassApp + the exact screenshots needed. |
| `pu_taxi_current_state.md` | Pu Taxi's current home/map/booking state, source-cited. |
| `feature_comparison.md` | The 12-feature comparison matrix. |
| `prioritized_recommendations.md` | P0–P3 findings + quick wins / core UX / visual / technical. |
| `features/01_home_and_map.md` | The detailed first-feature comparison. |
| `evidence/passapp/` | Official store screenshots (`ios/`, `play/`) + `*_ocr.txt` transcripts + `appstore.json`. |
