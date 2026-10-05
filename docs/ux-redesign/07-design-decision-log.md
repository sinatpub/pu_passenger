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

**Superseded by D33:** the tab bar is docked to the screen edges again.

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

**Amended by D24:** still three steps, now "On the way → Arrived → On trip", drawn as a bar under the sheet's headline instead of numbered circles.

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

**Amended by D20:** on OTP and Register the indicator sits on its own row under a top-left back button.

---

## D12: Segmented Controls (Not TabBar or Dropdown)

**Decision:** Use segmented controls (`.seg`) for language toggle and history tab switching.

**Rationale:**
- Segmented controls are more visually distinct than Material TabBar
- The pill-style active state (white bg, shadow) is consistent with the floating pill design language
- Works well for 2-3 options
- Avoids the need for separate AppBar styling per screen

**Extended by D19:** one shared language segment on every screen that switches language.

---

## D13: Rating + Receipt Screens (New)

**Decision:** Add Rating and Receipt screens after CalculateFee.

**Rationale:**
- The RateDriver widget exists in the codebase but is not wired up
- Rating provides valuable driver feedback data
- Receipt gives users a clear trip completion confirmation
- The chain Fee → Rating → Receipt → Home matches Grab/Uber patterns

**Superseded in part by D27:** the rating is a dialog over the Thank you page, and the chain is Fee → Thank you → Home.

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

> D19–D32 were decided by the user in October 2026, screen by screen, from screenshots of the mock build. Each was proposed with a sketch first; "Options the user chose" records the alternatives that were on the table.

## D19: One Language Toggle, Everywhere

**Decision:** Every screen that switches language uses the same `EN` / `ខ្មែរ` segment (`AuthLanguageToggle`), sized to its two labels: Login, Register, Home and Profile.

**Rationale:**
- Home had a single-label icon button showing the language you would switch *to*; Profile and the auth screens had a segment — two looks for one action
- The segment's fixed 132px width left an empty track after "ខ្មែរ"; hugging the labels removes it
- One widget means the screens cannot drift apart again

---

## D20: Auth Screens — Action by the Field, Back Button Top-Left

**Decision:** On Login, `Next` sits directly under the phone field instead of being pinned to the bottom of the screen. On OTP and Register the back button is top-left, with the step indicator on its own row beneath it. Login has no back button.

**Rationale:**
- A bottom-pinned button is far from the field it submits
- Back belongs at the top-left, where every other screen has it; the step indicator (D11) keeps its place as the anchor under it
- Login is the root of the stack — splash, logout and session expiry all replace the stack with it — so a back button there would have nowhere to go

---

## D21: A Destination Is Optional

**Decision:** A passenger can book without choosing a drop-off. The booking sheet's button is always live ("Book {vehicle}"); it is disabled only when no vehicle type has loaded. Without a drop-off the fare is by meter, and the sheet says so.

**Rationale:**
- Product rule from the user: passengers are not required to give a destination
- The booking request and the API payload already treated the destination as optional; only the UI blocked it
- A disabled button with a grey hint told the passenger nothing about what they could do

**Tradeoffs:**
- No fare estimate before the trip; the vehicle chips show "from {minimum fare}" instead
- Every later screen has to handle a trip with no drop-off (D24, D25, D27, history detail): it reads "No drop-off · fare by meter", never a dash and never a route to (0, 0)
- Not yet confirmed against the production backend that a booking without `end_latitude` / `end_longitude` is accepted

---

## D22: Booking Sheet — One Route Card, Vehicle Chips

**Decision:** The map's bottom sheet holds one bordered route card (the pickup, then the drop-off or "Add drop-off (optional)"), a horizontal row of vehicle chips with a fare on each, and the Book button, which carries the estimate once there is a route ("Book Rickshaw · 9,800 ៛"). The map's app bar is the back button alone.

**Rationale:**
- The separate "Where to?" card and pickup row were two blocks for one route
- The sheet showed only the vehicle chosen on Home; chips let the passenger compare types and fares without going back
- The "My Location" pill duplicated the my-location button
- A failed address lookup read "Error"; it now reads "Can't find your address. Tap to retry"

**Tradeoffs:**
- Chips scroll sideways, so not every vehicle is visible at once
- The fare is still the app's own estimate, not the server's

**Extended by D34:** the drop-off address is itself a button that reopens the picker on that place, so it can be changed without being cleared first.

---

## D23: Set Destination — Opens on the Map, Search Opens Over It

**Decision:** The page opens on the map with the pin, its address and "Confirm Drop Off". A search bar floats at the top; tapping it opens a search view with the results directly under the field, and "Set location on the map" always the first row. Choosing a search result sets the destination and returns to booking at once.

**Rationale:**
- The page used to open in search mode, where the pin could be dragged but not confirmed: Confirm existed only in a "map mode" reached through a row that appeared after a search had returned
- Results were at the bottom of the screen, far from the field at the top
- The pin had no address for a destination; it now resolves one each time the map settles
- Google's zoom buttons, toolbar, compass, location button and the traffic layer are off, as on the booking map

**Options the user chose:** open on the map (not in search); a search result returns immediately (not "move the map there, adjust the pin, then confirm"); show the address under the pin.

**Tradeoffs:**
- One reverse-geocode request each time the map stops moving
- Typing a destination takes one more tap than before

---

## D24: Active Ride — Status in the Sheet, Arrival Time, One Action

**Decision:** The ride's stage is the sheet's headline ("Driver is on the way", "Driver has arrived", "On trip") over a three-segment bar. While the driver is coming, the header shows the minutes and distance to the pickup. Below it: the driver with the car's make, model and colour and its plate; the trip (pickup and drop-off); a single "Call driver" button; and, until the trip starts, a "Cancel Booking" link. The map sits above the sheet, with a recenter button.

**Rationale:**
- The status pill over the map and the timeline in the sheet said the same thing twice
- The passenger's first question — when does the driver arrive — had no answer on the screen
- Cancel was the largest button on the sheet; Safety only raised a "coming soon" toast
- With the map running under the sheet, the driver's marker was framed behind the status bar

**Options the user chose:** minutes and distance (not distance only, not nothing); remove Safety until the feature exists; Cancel as a link; no grab handle on sheets that do not drag — this one and the booking sheet.

**Tradeoffs:**
- The arrival time is read from the Directions response that already draws the route, so it costs no extra request — but that parsing has not been checked against a live response; when no duration comes back, the header shows none
- No remaining time while on trip: the route there runs from the pickup, not from the car
- In mock mode the time is the mock route at 25 km/h, not a real figure

---

## D25: Trip Fare — What Is Owed First

**Decision:** The fare page leads with the amount, large, and the payment method as a chip beneath it. A full-width banner under it reads "Waiting for the driver to confirm payment". The driver, the trip and the details (distance, duration, date) follow as three bordered cards. If the trip cannot be loaded, the page says "Couldn't load the fare — ask your driver for the amount" and offers Retry.

**Rationale:**
- The amount sat third on the page, under a long card, in an orange gradient box unlike anything else in the redesign
- The waiting message was a small pill at the bottom; it is the state of the whole page
- "Classic Car" appeared twice; the Vehicle row is gone and the car is named once, under the driver
- A failed load showed a receipt made of dashes, with no way to try again

**Options the user chose:** a flat dark amount (not the gradient box moved up); Retry on a failed load; the same waiting message for every payment method.

**Tradeoffs:**
- No cash-specific instruction ("pay the driver in cash"): the payment-method names the production backend sends are not known

---

## D26: One Date Format

**Decision:** Dates read "5 Oct 2026, 2:03 PM" everywhere: the fare page, the Thank you page, the history list and announcements.

**Rationale:**
- The app had two formats, "Mon/05/Oct/2026 02:03 PM" and "Mon/5/Oct/2026 - 14:03PM"; the second put an AM/PM marker on a 24-hour clock

**Tradeoffs:**
- Month names are English in both languages, as before

---

## D27: Rating Is a Dialog; the Thank You Page Returns Home by Itself

**Decision:** The rating is no longer a page. After the driver confirms payment the app goes to the Thank you page, and the rating opens over it as a dialog when the trip has not been rated or skipped. The Thank you page shows the amount paid, the trip, and labelled invoice, date and rating rows. It returns to Home on its own after 60 seconds; the countdown is shown on "Back to Home".

**Rationale:**
- User decision: one page fewer, and at least one tap fewer, after every trip
- A passenger who pockets the phone should not come back to a finished trip's page
- The old Thank you card put the drop-off address in a label slot, which pushed the amount off the card
- "Receipt sent" was dropped from the subtitle: nothing in the app sends one

**Options the user chose:** stars, optional tags, then Submit (not submit-on-tap); one 60-second countdown that touching the rating restarts, and that closes an untouched dialog as a skip; the countdown visible on the button.

**Tradeoffs:**
- Any close without Submit is a skip, and that trip is never asked about again (N-10: skip is unpunished) — including stars chosen but not submitted when the minute runs out
- The note field is gone; the page it replaced never saved it
- Ratings still have no endpoint (`PDD-02`): they are queued in memory and lost on restart

---

## D28: The Brand Is PU Taxi

**Decision:** The passenger app is "PU TAXI", with "ពូ តាក់ស៊ី" as its Khmer name — the same as the driver app. That covers the Home header, the splash, the contact page, the app's name on the phone and its notification channel. The star badge on the splash and contact page is replaced by the PU Taxi mark (the launcher icon).

**Rationale:**
- User decision: the product is PU Taxi; "Taarraa" was the previous name, and the star was its symbol (តារា, "star")
- The launcher icon was already the PU Taxi mark, so the splash now matches the icon the passenger tapped

**Tradeoffs:**
- Not renamed: the package id (`com.tara.passenger`), the Firebase project, and the Android notification channel id — kept so existing installs keep their notification settings
- The contact email and phone numbers on the contact page are unchanged
- `Ta*` widget and token names in the code still carry the old initials

---

## D29: Drawn Service Art; Tuk Tuk Replaces Rickshaw

**Decision:** Each vehicle type on Home shows its own flat drawing, chosen by the type's id: a Cambodian tuk tuk (a motorbike pulling a canopied carriage), a sedan, a mini van, an SUV and a VIP van. Vehicle type 1 is called "Tuk Tuk", not "Rickshaw".

**Rationale:**
- Every row showed the same grey placeholder car, so the list could only be told apart by reading
- D5 specified SVG art per vehicle; the drawings use the prototype's colour per type
- The photos already in the repo were not used: the three-wheelers in them are not a Cambodian tuk tuk, they are about 250px wide, and their source and licence are not recorded

**Tradeoffs:**
- The drawings are illustrations, not photos of the fleet
- On Home the name is whatever the server sends for the vehicle type; the app's own data (mock, history) says "Tuk Tuk", but the production record has to be renamed on the server
- Map markers are unchanged: a tuk tuk on the map is still the old top-down three-wheeler

---

## D30: "Your Ride Did Not Happen" — Two Real Dialogs

**Decision:** A driver cancelling and a booking failing are both shown in the app's standard dialog: a tinted icon, a short title, one line of text, and two buttons. "Your driver cancelled" offers Close and Book again; "Couldn't book your ride" offers Close and Try again. Both stay until the passenger answers.

**Rationale:**
- The driver-cancel message was the loading spinner's "info" popup restyled as a card: off-centre, gone after 8 seconds or at any tap, and in hard-coded English
- The booking failure was a one-second "✕ Try again" that looked like a button and was not one, and said nothing about what failed
- Neither gave the passenger a way forward; both now do

**Options the user chose:** Book again opens the booking map with the same vehicle and drop-off filled in, and the passenger taps Book (not an automatic re-request — they may have moved); a dialog for a failed booking (not a message on the sheet); the driver-cancel dialog stays open (no auto-close).

**Tradeoffs:**
- "Book again" takes its vehicle and drop-off from the request made in this run of the app; after a restart mid-ride it just opens the booking map
- Only two causes are told apart for a failed booking: no location, and everything else
- Still no screen for "no driver accepted": the waiting overlay stays until the passenger cancels

---

## D31: Booking History — Compact Cards

**Decision:** Each trip in the history list is one compact, bordered card: the vehicle's drawing, the date and time with the fare beside it, the vehicle type and driver, the pickup and drop-off on one line each, and — for a completed trip — distance and time ("10.3 km · 28 min"). The page is titled with the tab's own name, "My Booking", and the Completed / Cancelled switch fills the width in two equal halves.

**Rationale:**
- The old card was about 226px tall with its gap, so three trips filled a screen; four to five fit now
- Its headline was the invoice number, the detail a passenger recognises least
- "Completed" was repeated on every card under a tab that already says Completed
- The route sat in a grey box inside the card; every other screen uses the plain pickup and drop-off rows
- The duration read "27 m 57 s"

**Options the user chose:** date and time as the headline, with the invoice number on the detail page only; the vehicle drawing as the card's mark (not the driver's initials); no status badge on the card; the title matching the tab (not "Riding History").

**Tradeoffs:**
- The card's date drops the year for trips from the current year ("5 Oct, 2:59 PM"), a shorter form than D26's
- A cancelled trip shows no fare and no distance, whatever the record holds
- A cancelled trip with no drop-off drops the row; a completed one reads "No drop-off · fare by meter"
- The detail page a card opens was redesigned next (D32)

---

## D32: Trip Details — The Trip, Then the Record

**Decision:** The page a history card opens is titled "Trip details" and reads top to bottom: a small still map of the route, the fare with a "Paid · {method}" badge, the driver with the car's make, model, colour and plate, the pickup and drop-off, then a record of date, distance, duration and invoice number. "Book again" is pinned at the bottom and opens the booking map with the same vehicle and drop-off. A cancelled trip shows a "Cancelled" badge and "No fare was charged" in place of the fare.

**Rationale:**
- The invoice number was the title and was repeated in the card; the fare was small, in a corner
- A cancelled trip could read "Paid": that row showed whenever the record had a payment method
- The map panned under the finger, so the page could not be scrolled from it; its pins were a car labelled "Driver" on the pickup and a person labelled "Passenger" on the drop-off
- The car's model, colour and plate were in the record and not shown — what a passenger needs to describe it afterwards

**Options the user chose:** a still map preview (not pannable, not removed); a Book again button; no Call driver button — it would expose the driver's own number long after the trip; "Trip details" as the title (not the invoice number).

**Tradeoffs:**
- The route cannot be explored on this page
- A passenger who left something in the car reaches the driver through Contact us, not directly
- "No fare was charged" is shown only when the record has no amount or zero; a cancelled trip with a charge shows the charge

---

## D33: Docked Tab Bar

**Decision:** The tab bar is a white bar flush to the left, right and bottom edges under a 1px `border` hairline, with no shadow and no radius. Its white continues behind the system gesture area; the tabs sit above it. The active tab is the brand colour under a 28×3 indicator hanging from the hairline; inactive tabs are `textSecondary`, icon and label alike. Labels are 12/600. This replaces the floating pill of D4.

**Rationale:**
- The pill sat a fixed 12px from the bottom and ignored the system inset, so the gesture handle lay across its lower edge
- The active tab was a brand-50 block a third of the bar wide: it read as a button, not as the tab you are on
- 11px labels are small for Khmer script, and `textMuted` on white was faint
- The three outline icons were drawn in two greys (`#292D32` and `#A2A2A2`), so inactive tabs did not match each other

**Options the user chose:** the docked bar, over a refined pill (tint behind the active icon only) and a pill whose active tab expands to show its label.

**Tradeoffs:**
- The floating look of D4 is gone; D3's 22px radius now applies to sheets only
- The tab screens' bottom padding drops from 96 to 24: the bar no longer needs clearance, as the page ends where the bar begins
- The History tab keeps its book icon

---

## D34: Trip Markers Are the Route Card's Symbols

**Decision:** On a map, the pickup is a dark circle and the drop-off a brand-orange rounded square, each with a white outline and a white centre: the two symbols of the booking sheet's route card. They are drawn in code (`core/utils/trip_marker.dart`) at the screen's own density, sit centred on their point, and draw above the nearby drivers. They are used on the booking map, the trip details map and, for the drop-off, the active ride map. The drop-off row of the route card is a button: tapping the address reopens the picker on that place; the cross still clears it.

**Rationale:**
- Both ends were red, the colour of the route line too: a teardrop pin for the pickup and a ring on a stick for the drop-off, with nothing to say which was which
- The route card already had a legend — dark circle, orange square — that the map did not use
- The pins were 42×42 images scaled up, so they were soft on dense screens
- A nearby driver's icon could cover the pickup
- A drop-off could only be changed by clearing it and adding it again, and the picker always opened on the passenger's own position rather than on the place being changed

**Options the user chose:** the route card's shapes, over the same shapes with "Pickup" / "Drop-off" labels and over classic pins in two colours.

**Tradeoffs:**
- The markers carry no text; the info window and the route card name the ends
- The active ride map keeps its orange passenger figure for the pickup: there it marks the person waiting, not an end of the route
- The pickup still cannot be changed while a drop-off is set, short of clearing the drop-off
- `passenger_marker.png` and the `passengerMarker` / `destinationMarker` constants are no longer used by any screen

---

## D35: Home Has No "Where To?" Card

**Decision:** Home is the header, the promo banner and the vehicle list. The "Where to?" search card between the banner and the list is removed.

**Rationale:**
- User decision
- The card did not search: it opened the same booking map a vehicle row opens, only without a vehicle chosen
- The drop-off is chosen on the booking map (D22, D23), and is optional (D21)

**Tradeoffs:**
- A passenger now always starts by picking a vehicle; the map's chips still let them change it
- `TaSearchCard` and the `whereTo` string are no longer used by any screen

---

## D36: Home Header Is a Brand Bar

**Decision:** The Home header is one row on a single centre line: the PU Taxi mark (the launcher icon, 40×40, radius 12), "PU TAXI" (22/800) over the tagline (13), and the language segment. It starts 12px under the status bar. The tagline is translated: "Ride with trust" in English, "ពូ តាក់ស៊ី · ជិះដោយទំនុកចិត្ត" in Khmer, the Khmer name still in the brand colour.

**Rationale:**
- 46px of empty space sat above the title and pushed the vehicle list down
- The header was text alone; the mark the passenger tapped to open the app was not on it
- "Ride with trust" was a hardcoded English string, so the Khmer header read in two languages
- The language segment sat at the top of a two-line title rather than centred on it

**Options the user chose:** the brand bar, over a greeting bar (avatar and name) and a pickup-location bar — both need data Home does not load. The language segment stays on Home (D19); the bell stays hidden (PDD-03).

**Tradeoffs:**
- On a narrow screen the name and tagline shrink to fit rather than wrap
- The header still scrolls away with the page
- The Khmer tagline is the prototype's wording; `rideWithTrust` used to hold "ពូ តាក់ស៊ី · ធ្វើដំណើរដោយទុកចិត្ត" and was not shown anywhere

---

## D37: Khmer Is the Default Language

**Decision:** The app opens in Khmer until the passenger picks a language (`AppConstant.defaultLanguageCode`). A saved choice still wins.

**Rationale:**
- User decision
- The app started in English and fell back to English when no choice was saved, for a Khmer-speaking market

**Tradeoffs:**
- A passenger who never touched the language segment had no saved choice, so an update moves them from English to Khmer; one tap on the segment switches back and is remembered

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
| D19 | One language toggle everywhere | Low | None |
| D20 | Auth: action by the field, back top-left | Low | None |
| D21 | Destination optional | High | Medium |
| D22 | Booking sheet: route card + vehicle chips | Medium | Low |
| D23 | Set destination opens on the map | Medium | Low |
| D24 | Active ride: status in sheet, arrival time | Medium | Medium |
| D25 | Trip fare: amount first | Medium | Low |
| D26 | One date format | Low | None |
| D27 | Rating dialog; Thank you auto-returns | Medium | Low |
| D28 | Brand is PU Taxi | Medium | Low |
| D29 | Drawn service art; Tuk Tuk replaces Rickshaw | Medium | Low |
| D30 | Driver-cancel and booking-failed dialogs | Medium | Low |
| D31 | Booking history: compact cards | Medium | Low |
| D32 | Trip details page | Medium | Low |
| D33 | Docked tab bar (replaces D4) | Medium | Low |
| D34 | Trip markers match the route card; drop-off editable | Medium | Low |
| D35 | Home: no "Where to?" card | Low | None |
| D36 | Home header: brand bar | Low | None |
| D37 | Khmer is the default language | Medium | Low |
