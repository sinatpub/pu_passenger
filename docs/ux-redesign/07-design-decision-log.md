# 07 — Design Decision Log

All decisions are based on the authoritative prototype at `taarraa-ui-prototype.html`.

---

## D1: Preserve #FF4500 as Primary Brand Color

**Decision:** Keep Taarraa Orange (#FF4500) as the primary brand color.

**Rationale:**
- Distinctive for the Cambodian taxi market
- High visibility (4.52:1 contrast on white for large text)
- Already established in brand assets

**Tradeoffs:**
- #FF4500 needs `primaryDark` (#CC3700, 5.94:1) for small text to meet WCAG AA

---

## D2: Navy (#232838) as Dark Accent

**Decision:** Use navy (#232838) as the dark color for status pills, promo bg, toast, plate badge, pickup dot, dark buttons.

**Rationale:**
- Pure black (#000) is too harsh on mobile
- Navy adds sophistication without being cold
- Already used in the prototype for high-contrast elements

---

## D3: 22px Radius for Sheets and Tab Bar

**Decision:** Use 22px radius (not 16px or 12px) for bottom sheets and the floating tab bar.

**Rationale:**
- 22px gives a modern, rounded feel that distinguishes sheets from cards (16px)
- Consistent between sheets and tab bar creates visual harmony
- The larger radius works well with the floating/inset design

---

## D4: Floating Pill Tab Bar

**Decision:** Replace full-width Material BottomNavigationBar with a floating pill (inset 12px, radius 22, shadowLg).

**Rationale:**
- More modern appearance (Grab, Bolt use similar patterns)
- Inset design creates breathing room from screen edge
- Active pill (brand-50 bg) provides clear visual feedback
- Shadow creates depth separation from content

**Tradeoffs:**
- Slightly less touch target area than full-width
- Must ensure sufficient padding (8px internal)

---

## D5: Vertical Vehicle List (Not Grid)

**Decision:** Use a vertical list of vehicle rows instead of a 2×2 grid with VIP circle.

**Rationale:**
- Grid layout confused users (VIP circle overlapped grid items)
- Vertical list is the standard pattern in ride-hailing (Uber, Grab, Gojek)
- Each row shows more information (SVG art + name + seats/km + price + ETA)
- Eliminates the confusing "VIP" special treatment

---

## D6: 3-Step Timeline (Not 4-Step)

**Decision:** Use 3-step ride progress timeline (Accepted → Arriving → On trip) instead of 4-step.

**Rationale:**
- The prototype chains: fee → rating → receipt (rating is post-ride, not a ride phase)
- "Requested" and "Accepted" happen too fast in the demo to warrant separate steps
- 3 steps match the actual user-perceived phases: driver accepted, driver coming, riding

**Tradeoffs:**
- Does not show "Request sent" phase — but this is transient and covered by the booking overlay

---

## D7: Keep Tariff Bottom Sheet (Nested)

**Decision:** Keep the Tariff button + nested bottom sheet for vehicle pricing details.

**Rationale:**
- Users need to see min fee, price/km, and seats before booking
- A nested sheet is a common pattern for detail-on-demand
- Inline display would make the map bottom sheet too long
- The tariff info is secondary — a tap to reveal is appropriate

---

## D8: Bold Typography (800/700/400)

**Decision:** Use ExtraBold (800), Bold (700), and Regular (400) font weights.

**Rationale:**
- 800 for screen titles and brand creates strong visual hierarchy
- 700 for buttons, labels, and section headers provides clear emphasis
- 400 for body text is comfortable for reading
- The existing `ExtraWeight` extension and `font10SemiBold` bug are eliminated

**Tradeoffs:**
- ExtraBold is heavy — must be used sparingly (titles, brand, prices only)
- Some developers may find 3 weights limiting

---

## D9: Cards Use 16px Radius (Not 12px)

**Decision:** All cards (`.card`, `.hcard`, `.veh`, `.promo`, etc.) use 16px border radius.

**Rationale:**
- 16px is the dominant radius in the prototype
- Creates a softer, more modern appearance than 12px
- Consistent across all card types

---

## D10: Navy Toast (Not White)

**Decision:** Toast notifications use navy background (#232838) with white text and a mint check icon (#7CFFB2).

**Rationale:**
- Navy toast stands out from white card-based content
- High contrast ensures readability
- Mint check icon adds a distinctive brand touch
- Matches the dark accent system (navy)

---

## D11: Step Indicators Across Auth Flow

**Decision:** Add a 3-dot step indicator to Login (1/3), OTP (2/3), Register (3/3).

**Rationale:**
- Users need to know how many steps remain in registration
- Progress indicators reduce abandonment
- Simple dots are lightweight and non-intrusive
- The indicator also serves as a visual anchor for the top of each auth screen

---

## D12: Segmented Controls (Not TabBar or Dropdown)

**Decision:** Use segmented controls (`.seg`) for language toggle and history tab switching.

**Rationale:**
- Segmented controls are more visually distinct than Material TabBar
- The pill-style active state (white bg, shadow) is consistent with the floating pill design language
- Works well for 2-3 options
- Avoids the need for separate AppBar styling per screen

---

## D13: Rating + Receipt Screens (New)

**Decision:** Add Rating and Receipt screens after CalculateFee.

**Rationale:**
- The RateDriver widget exists in the codebase but is not wired up
- Rating provides valuable driver feedback data
- Receipt gives users a clear trip completion confirmation
- The chain Fee → Rating → Receipt → Home matches Grab/Uber patterns

---

## D14: DEMO Prototype Behaviors

**Decision:** Several prototype behaviors are demo-only and will NOT be implemented in production.

**Demo-only features:**
- Splash "Skip →" button → production uses auto-navigate only
- "Skip ▸" on Booking screen → production uses auto-transition
- "Simulate payment" button → production waits for real socket event
- "Demo: type any 4 digits" → production verifies against real OTP API
- Prototype sidebar/screen navigator → internal tool only

**Production behaviors:**
- Splash: auto-navigate after token check (2200ms if no cached user)
- OTP: verify against real API, show error on invalid code
- Payment: wait for socket event `paymentConfirm`
- Booking: wait for real driver accept

---

## D15: Price Currency is USD

**Decision:** Display prices in USD ($) not Cambodian Riel (៛).

**Rationale:**
- The prototype uses `$` throughout (`money()` = `'$'+n.toFixed(2)`)
- USD is widely used in Cambodia for ride-hailing pricing
- Riel can be shown as an alternative in a future update

---

## D16: No Dark Mode

**Decision:** Light theme only. Dark mode deferred.

**Rationale:**
- The token system supports future dark mode by swapping values
- Cambodia market has low dark mode adoption
- Would require testing all 20 screens × 2 themes

---

## D17: Keep Existing .d Responsive Extension

**Decision:** Retain the diagonal-based `.d` extension for responsive sizing.

**Rationale:**
- Used in 50+ call sites
- The app targets phones only
- Migration to ScreenUtil is not justified

---

## D18: Minimal AppBar (Icon-Button Only)

**Decision:** Use icon-button back (42×42, radius 12, white, shadowSm) instead of Material AppBar.

**Rationale:**
- The prototype does not use Material AppBar — screens use simple h2 titles with optional back icon-btn
- The floating icon-btn on map screens provides consistent back behavior
- Less visual weight than a full AppBar

---

## Decision Summary

| # | Decision | Impact | Risk |
|---|---|---|---|
| D1 | Preserve #FF4500 | Low | None |
| D2 | Navy as dark accent | Medium | Low |
| D3 | 22px radius for sheets/tab | Low | None |
| D4 | Floating pill tab bar | Medium | Low |
| D5 | Vertical vehicle list | Medium | Low |
| D6 | 3-step timeline | Low | None |
| D7 | Keep tariff sheet | Low | None |
| D8 | Bold typography (800/700/400) | Medium | Low |
| D9 | 16px card radius | Low | None |
| D10 | Navy toast | Low | None |
| D11 | Step indicators on auth | Low | None |
| D12 | Segmented controls | Low | None |
| D13 | Rating + Receipt screens | Medium | Low |
| D14 | Demo vs production behaviors | Medium | Medium |
| D15 | USD currency | Low | None |
| D16 | No dark mode | Low | None |
| D17 | Keep .d extension | Low | None |
| D18 | Minimal AppBar | Low | None |
