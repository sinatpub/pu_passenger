# PassApp — Reference Evidence Inventory

**Purpose:** record exactly what is known about the current PassApp passenger
app, how it was verified, and — critically — what is **not** verifiable in this
environment, so no comparison row rests on a guess.

- App: **PassApp — Transport & Delivery** (a.k.a. "PassApp Taxi and Delivery")
- Publisher: PassApp Technologies Co., Ltd., Phnom Penh
- Bundle: `kh.com.passapp.passenger` (Android) / iOS id `1535615747`
- Current version: **5.0.2** (iOS released **2026-09-10**; Play "updated Sep 12, 2026")
- **Closed source** — no code access. Native Android (per third-party binary analysis, FlyTrap, version analysed 3.3.3).
- Evidence date: 2026-10-13

---

## 1. Where the evidence came from

| Source | Type | Confidence |
|---|---|---|
| **App Store lookup API** (`itunes.apple.com/lookup?id=1535615747`) | Official metadata + 8 portrait screenshots + release notes | High for metadata; **screenshot UI may be stale** (see §2) |
| **Google Play listing** (`play.google.com/store/apps/details?id=kh.com.passapp.passenger`) | Official 10 promotional screenshot assets + "What's new" | High for metadata; screenshots are marketing composites |
| **Official website** `passapptaxis.com` | Stated 4-step booking flow | Medium (marketing copy) |
| Store descriptions (both stores) | Feature list | High that the feature exists; not a UI spec |
| Third-party (AppBrain, MWM, apkpure) | Version history, install counts, tech stack | Medium |

All downloaded artifacts live in `evidence/passapp/`:
- `ios/passapp_01..08.png` + `ios/appstore.json` + `ios_ocr.txt`
- `play/play_11..20.png` + `play_ocr.txt`

## 2. The staleness problem (important)

The 8 official App Store screenshots OCR to internal version labels
**"Version 2.3.6"** and **"Version : 2.3.6"** (screenshots 01 and 08
respectively, `ios_ocr.txt`). Yet the listing ships app **5.0.2**, and the
release notes record a **"New Home Screen layout"** shipped in 2025 and repeated
**"UX/UI improvements"** through 5.0.0/5.0.1/5.0.2.

**Conclusion:** the iOS store screenshots are **marketing art that may not
depict the current 5.0.2 interface.** They are used in this audit **only** for
text/structure (what labels and screens exist), never as proof of current
visual design.

The **Google Play** assets are somewhat more current (they show a **"Request
Code"** login button, a **"Reward"** account row, and a **"Please choose
service"** sheet absent from the iOS set), but they are **landscape marketing
composites** (1052×592) with an orange branded frame, not clean screen captures.

## 3. Verified PassApp surfaces (OCR text, [OCR] / [STORE])

> Normalised `y` = vertical position from bottom (1.0 = top). Use only for
> top-to-bottom order, not pixel metrics.

### 3.1 Splash
`PassAPP` / `Cambodia Taxi Booking` brand lockup, spinner, `Getting data...`,
`Version 2.3.6`. [OCR ios_01]

### 3.2 Login / Sign up
Top-right language selector `English` (flag icon); brand lockup;
`Welcome` / `Sign To Continue`; `+855` chip + `Phone Number` field;
primary button `Login` (iOS) **or** `Request Code` (Play — newer);
`Not yet has an account?` / `Sign Up`. [OCR ios_02, play_15, play_17]

### 3.3 Home
Section `Promotion` (card), section `Special Offer` (card, e.g. `5%` /
`R&F City Phnom Penh`); a **horizontal vehicle row** of circular art with
labels `Rormork`, `Rickshaw`, `Classic`, `SUV`; **bottom nav: `Home`,
`My Booking`, `Support`, `Account`** (4 tabs). [OCR ios_03, play_16, play_18]

### 3.4 Booking map
Full-screen map, centre pin labelled `My Location`; a search row `Where to?`;
a selected-vehicle row (`Rickshaw` + a percentage/ETA figure); an **action row
`Cash` · `Coupon` · `Option` · `Note`**; primary CTA `Confirm Booking`.
Nearby-vehicle markers and a "1 min" ETA bubble on the map. [OCR ios_04]

### 3.5 Location selection
Title `Pick Up` / `And Drop Off.`; a place-search **list** (named POIs +
plus-codes, e.g. `SAMAI SQUARE`, `TK Avenue Mall`, `HVMW+CXM, Street 317,
Phnom Penh`); current location row `My Location`; a two-address summary; and
an explicit **`Fare: 3,200 KHR`** row above `Confirm Booking`. [OCR ios_05, ios_06]

### 3.6 Service selection
Sheet: `Please choose service` / `Book quick and easy` / `or choose other
services.` — an explicit vehicle/service chooser step. [OCR play_13]

### 3.7 Support
Title `Message` / `Easy Chat With Support.`; `Help` search; pre-canned issue
list: `Report driver cheat`, `Report driver ask to cancel`, `Cannot booking.`,
`Forgot stuff.`, `Cannot link with ABA`, `Other.` [OCR ios_07]

### 3.8 Account
Header `Access your account,` / `Booking History And More.`; user name;
`Earned Points: 10` (or 20); `Referral: 12039`; **`Reward`** row (Play, newer);
menu: `My Booking`, `Saved Places`, `Payment method`, `Settings`,
`Contact Us`, `Log Out`; `Version : 2.3.6`. [OCR ios_08, play_19]

### 3.9 Verified feature list (store copy) [STORE]
- Vehicle types: **TukTuk, Rickshaw, Cab (Classic), SUV** — matches the home row.
- **Metered taximeter** pricing; currency shown as **KHR** (`Fare: 3,200 KHR`).
- **Scheduled / advanced booking** ("pre-order taxi to arrive at any time").
- **Rate drivers**; **live map tracking** of the car; **notes to drivers**;
  **delivery point**; **invoice emailed** after the trip; **points & referral**;
  **coupon / promo** codes; **ABA** bank link (`Cannot link with ABA` support item).
- Cities: Phnom Penh, Siem Reap, Battambang, Sihanoukville, Kampot, Poipet, Kampong Cham.
- Languages (iOS): English, Khmer, French, Japanese, Korean, Chinese (Simp/Trad), Thai, Vietnamese.

### 3.10 Release cadence (version history) [STORE]
- **5.0.2 / 5.0.1 / 5.0.0** (Aug–Sep 2026): "UX/UI Improvements", "Bug Fixes".
- **3.2.2–3.2.6** (Dec 2025–May 2026): **"New Home Screen layout"** + UX/UI improvements.
- **3.1.23** (Jul 2025): **"New trip rating category"**, **"New announcement on booking screen"**, **"Coupon improvements"**.
- Store rating: ~3.56★ (Play, ~20.7k ratings), 4.1★ (iOS); 5M+ installs (Play).

## 4. What is NOT verifiable

1. **Current 5.0.x colours, type, spacing, radii, shadows** — no eye access, no device.
2. **Whether the store art reflects 5.0.x** — see §2.
3. **Dark mode / theming** — not evidenced.
4. **Animations, micro-interactions, loading/empty/error states** — not in static art.
5. **Wallet / payment-method UI detail** — only the `Payment method` menu row is known.
6. **Scheduled-booking, coupon, announcement, rating UIs** — features confirmed by copy, UI not evidenced.
7. **Live performance, offline handling, permission flows** — no runtime.

## 5. Exact screenshots needed to close the gaps

Please capture the following from a **real device running PassApp 5.0.2**
(screenshots, not photos). Each maps to a blocked feature row in `README.md` §6.

| # | Screen to capture | Why / which feature it unblocks |
|---|---|---|
| S1 | **Home** (cold open, after login) | F01 — current home layout, vehicle selector, promo placement, bottom nav |
| S2 | **Home** scrolled to bottom | F01/F09 — full vehicle list + any banner/nav |
| S3 | **Booking map, no destination** | F01/F03/F04 — sheet content, Cash/Coupon/Option/Note row, CTA, fare display |
| S4 | **Booking map, with destination set** | F03/F04 — route card, fare, chip states |
| S5 | **Location search / Pick Up & Drop Off** | F02 — search list, recents, **Saved Places**, address rows |
| S6 | **Saved Places screen** (Account → Saved Places) | F02/F09 — home/work saved addresses |
| S7 | **Service / vehicle selection sheet** | F03 — the "Please choose service" chooser |
| S8 | **Driver matching / searching** | F05 — waiting state, cancel affordance |
| S9 | **Active trip in progress** | F06 — driver card, ETA, route, options |
| S10 | **Trip completion / fare / payment** | F07 — fare breakdown, payment method |
| S11 | **Rating screen** (new category) | F07 — the 2025 "new trip rating category" |
| S12 | **Receipt** | F07 — invoice layout |
| S13 | **My Booking / history list** | F08 |
| S14 | **Trip detail** | F08 |
| S15 | **Account tab (full)** | F10 — Reward, Points, Referral, Saved Places, Payment method |
| S16 | **Payment method screen** | F09 — wallet/ABA/cards |
| S17 | **Rewards / points / referral screen** | F09 — the `Reward` row's destination |
| S18 | **Promotions / coupon entry on booking** | F09 — Coupon action |
| S19 | **Support / Help screen** | F10 |
| S20 | **Announcement** (if shown on booking) | F10 — the "New announcement on booking screen" |
| S21 | **Settings / language** | F10 |
| S22 | **Login + OTP + Sign-up** | F11 — the current auth flow (`Request Code` variant) |
| S23 | **Any error state** (no drivers, network loss, booking failed) | All — error/recovery parity |

Also useful, if available: a **short screen recording** of the full booking
start→confirm, and the **Khmer-language** equivalents of S1, S3, S5 for Khmer
text-rendering comparison.

## 6. Evidence caveats for every downstream claim

1. "PassApp shows text X" = **[OCR] from a possibly-stale marketing asset**.
2. "PassApp has feature Y" = **[STORE] copy**, not a UI spec.
3. "PassApp's design is better/worse" on colour/spacing/type = **[UNKNOWN]** until S1–S23 arrive.
4. Structural/IA comparisons (nav count, presence of a feature, flow order) are the **reliable** part of this audit and are what the recommendations lean on.
