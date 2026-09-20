# 03 — Screen Redesign

20 screens total (17 existing + 3 new: Rating, Receipt, Design Tokens). All specs match `taarraa-ui-prototype.html`.

---

## Screen 1: Splash

**Route:** `/splash` | **Purpose:** Brand + auth gate

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7):
  Center:
    Column(center):
      // Logo badge (animated pop2 600ms)
      Container(96×96, borderRadius:28, gradient: linear-gradient(135deg,#FF6A00,#FF4500 60%,#E63E00), shadow: 0 16px 40px rgba(255,69,0,.4)):
        Icon(star, 52×52, white)
      SizedBox(h:16)
      // Brand name
      Text("TAARRAA", 30/800/letterSpacing:3)
      // Subtitle
      Text("តារា · Taxi", 15/700, #FF4500)
      SizedBox(h:34)
      // Loading bar (animated load 1s infinite)
      Container(120×5, borderRadius:99, bg:#E4E5EB, clip:
        Container(40% width, borderRadius:99, bg:#FF4500, slide animation)
      )
      SizedBox(h:26)
      // Skip link
      TextButton("Skip →", #FF4500, 14/700, → s-login)
```

### Interactions
- Skip button → `show('s-login')`
- Auto-transition → `show('s-login')` after 2200ms

---

## Screen 2: Login

**Route:** `/login` | **Purpose:** Phone number input

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    // Top row: step indicator + language toggle
    Row(mainAxisAlignment: spaceBetween):
      TaStepIndicator(steps:3, current:0)
      TaSegmentedControl(["EN","ខ្មែរ"], selected, → toggleLang)
    SizedBox(h:18)
    Text("Welcome back", 24/800)
    SizedBox(h:6)
    Text("Enter your phone number to continue", 13/400, #6B7588)
    SizedBox(h:18)
    Text("Phone number", 13/600, #6B7588) // label
    SizedBox(h:8)
    TaTextField:
      prefix: Text("+855", 15/700, border-right: 1px #EBEBF0, paddingRight:10)
      hint: "Enter phone number"
      keyboardType: numeric, maxLength: 12
    // Error area (minHeight: 18)
    Text(error, 13/400, #D32F2F, marginTop:6)
    Spacer()
    TaPrimaryButton("Next", → doLogin)
    SizedBox(h:14)
    Text("Taarraa Taxi · prototype v2.0", 12/400, #9AA0B4, centered)
```

### Validation
- On "Next" press: ≥8 digits after +855
- Invalid: shake animation on field + error text + haptic (60ms vibration)

---

## Screen 3: OTP

**Route:** `/otp` | **Purpose:** 4-digit verification

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding same):
  Column:
    Row(spaceBetween):
      TaStepIndicator(steps:3, current:1)
      TaIconButton(icon: chevron_left, → s-login)
    SizedBox(h:18)
    Text("OTP Verification", 24/800)
    SizedBox(h:6)
    Text("Enter the 4-digit code sent to") + Text(phoneNumber, 15/800, #191C24)
    SizedBox(h:18)
    // 4 OTP inputs
    Row(gap:12):
      ForEach(4): TaOTPField (64px height, 26/800, radius 14)
    // Error area
    Text(error, 13, #D32F2F)
    SizedBox(h:14)
    // Timer row
    Row:
      Text("Didn't get the code?", 14, #6B7588)
      // Timer pill (when active)
      Container(bg: #FFF4ED, borderRadius:99, padding:4px 12):
        Text("0:28", 14/800, #FF4500, tabular-nums)
      // Resend link (when timer expired)
      TextButton("Send again", #FF4500, 14/700, → resendOtp)
    Spacer()
    TextButton("New here? Complete your profile →", #FF4500, 14/700, → s-register)
    SizedBox(h:14)
    Text("Demo: type any 4 digits to verify", 12, #9AA0B4, centered)
```

### Interactions
- Auto-focus first OTP box on open
- Auto-advance on input
- Auto-back on backspace
- On 4 digits entered → verify → navigate to s-home
- Timer: 30s countdown, then show "Send again"
- Resend → restart timer + toast "Code resent"

---

## Screen 4: Register

**Route:** `/register` | **Purpose:** Complete profile

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding same):
  Column:
    Row(spaceBetween):
      TaStepIndicator(steps:3, current:2)
      TaSegmentedControl(["EN","ខ្មែរ"])
    SizedBox(h:18)
    Text("Complete profile", 24/800)
    SizedBox(h:6)
    Text("Add your name and photo", 13/400, #6B7588)
    // Avatar picker (120×120, centered)
    Center:
      Container(120×120, borderRadius:99, bg:white, shadow:shadowMd):
        Icon(person, 28, #9AA0B4) // placeholder
        // Camera button (38×38, positioned bottom-right)
        Container(38×38, borderRadius:99, bg:#FF4500, shadow:0 4px 12px rgba(255,69,0,.4)):
          Icon(camera, 16, white)
    SizedBox(h:6)
    Text("Tap to add photo (optional)", 12, #9AA0B4, centered)
    SizedBox(h:18)
    Text("Full name", 13/600, #6B7588)
    SizedBox(h:8)
    TaTextField(hint: "Full name", → onChanged: enable button if ≥2 chars)
    Spacer()
    TaPrimaryButton("Create", disabled: name<2, → finishRegister(false))
    SizedBox(h:12)
    Text("or", 13, #9AA0B4, centered)
    SizedBox(h:12)
    TaButton(variant: ghost, "Skip", → finishRegister(true))
```

### Interactions
- Camera tap → bottom sheet (Gallery / Camera) — toast "Photo picker coming soon"
- Name ≥2 chars → enable "Create"
- Create → `passengerRegister()` → s-home
- Skip → `passengerRegister()` with auto name → s-home

---

## Screen 5: Bottom Navigation Host

**Purpose:** 3-tab floating pill navigation

### Layout
```
Scaffold:
  body: pages[selectedIndex]
  bottomNavigationBar: TaBottomNav (floating pill)
```

### Tabs
| Index | Label | Active Icon | Inactive Icon | Screen |
|---|---|---|---|---|
| 0 | Home | `home-angle-2-svgrepo-com.svg` | `home.svg` | s-home |
| 1 | My Booking | `book.svg` | `book_outline.svg` | s-history |
| 2 | Profile | `profile_fill.svg` | `profile.svg` | s-profile |

### Active State
- Tab button gets `bg: #FFF4ED`, `color: #FF4500`
- Icon: primary color
- Label: primary color, fontWeight 600

---

## Screen 6: Home

**Route:** Tab 0 | **Purpose:** Vehicle selection + booking entry

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides, paddingBottom:96px):
  SingleChildScrollView:
    Column:
      // Brand header
      Row(spaceBetween, align: flex-start):
        Column:
          Text("TAARRAA", 24/800)
          Text("តារា · Ride with trust", 13/400, #6B7588)  // km word in #FF4500
        Row(gap:10):
          TaIconButton(icon: bell, showDot:true, → s-news)
          TaIconButton(icon: text "ខ្មែរ" or "EN", 13/800, → toggleLang)
      SizedBox(h:14)

      // PROMO banner
      TaPromoBanner:
        tag: "PROMO"
        title: "20% off airport rides"
        subtitle: "Use code FLY20"
        onTap: toast("Promo applied: FLY20")
      SizedBox(h:14)

      // "Where to?" search card
      TaSearchCard("Where to?", → goMap)
      SizedBox(h:18)

      // Section header
      Row(spaceBetween):
        Text("Choose your ride", 17/700)
        TaIconButton(icon: refresh, size:36, → loadHome(true))
      SizedBox(h:12)

      // Skeleton loading (when loading)
      ForEach(3): TaSkeleton (row: 84×52 art block + two text lines)

      // Vehicle list (when loaded)
      ForEach(VEHICLES):
        TaVehicleRow(vehicle, selected: vehicle.id == selected.id, → goMap(id))
```

### States
| State | UI |
|---|---|
| Loading | 3 skeleton rows |
| Loaded | Vehicle list |
| Error | Toast + keep skeleton |

### Interactions
- Tap bell → `show('s-news')`
- Tap lang → toggle EN/KM
- Tap promo → toast
- Tap "Where to?" → `show('s-map')`
- Tap refresh → reload vehicles + toast "Refreshed"
- Tap vehicle → `goMap(vehicleId)`

---

## Screen 7: Map (Booking Request)

**Route:** `/map` | **Purpose:** Select destination, book ride

### Layout
```
Scaffold(bg: transparent):
  Stack:
    // Map (full screen)
    GoogleMap (or SVG map placeholder)

    // Top bar
    Positioned(top:48, left:16, right:16):
      Row(gap:10):
        TaIconButton(icon: back, → s-home)
        Container(bg:white, borderRadius:99, shadow:shadowMd, padding:10px 16px):
          Row(gap:6):
            Icon(locate, sm, #FF4500)
            Text("My Location", 13/700)

    // Center pin (when no destination)
    CenterPin (40×40 pin SVG, drop-shadow)

    // FAB
    Positioned(right:16, bottom:340):
      TaIconButton(icon: locate, → centered toast)

    // Bottom sheet
    TaBottomSheet:
      // When no destination:
      TaSearchCard("Where to go?", → s-search)

      // Pickup address row
      TaAddressRow(pickup, dot: navy, name: "No. 128, St. 271", sub: "Toul Kouk")

      // When destination set:
      Divider
      TaAddressRow(destination, dot: brand, name, addr) + X button to clear
      TaStatRow([distance, duration, fare])
      TaNoteField("Add a note for driver")

      Divider
      // Vehicle mini row
      TaVehicleRow(compact, vehicle) + Tariff pill → openTariff

      SizedBox(h:6)
      // Book Now button (disabled if no destination)
      TaPrimaryButton("Booking Now", disabled: !dest)
      // Hint text when no destination
      Text("Select a destination to continue", 12, #9AA0B4, centered)

    // Booking overlay (when booking)
    TaLoadingOverlay(visible: bookingInProgress):
      Spinner (64×64)
      Car bounce icon
      Text("Contacting nearby drivers…")
      Text("Tuk-Tuk · 0.4 km away", 12, #6B7588)
      TaButton(variant: dangerGhost, "Cancel", maxWidth:220)
```

### Tariff Sheet
```
openTariff() → TaBottomSheet:
  Title: "Tuk-Tuk · Tariff"
  TaKVRow("Minimum fee", "$1.00")
  TaKVRow("Price per km", "$0.45")
  TaKVRow("Seats", "3")
  TaPrimaryButton("Got it", → closeSheet)
```

---

## Screen 8: Search (MapDrag)

**Route:** `/dragMap` | **Purpose:** Find destination

### Layout
```
Scaffold(bg: white):
  SafeArea:
    Column:
      // AppBar
      Row(gap:12):
        TaIconButton(icon: back, → s-map)
        Text("Set destination", 17/700)
      SizedBox(h:12)

      // Mini map preview (170px)
      Container(170px, borderRadius:16, shadow:shadowMd, clip:
        SVG map with center pin
      )
      SizedBox(h:12)

      // Search field
      Row(gap:10):
        Icon(search, sm, #9AA0B4)
        TextField(placeholder: "Search for a place", → renderSearch)
      SizedBox(h:6)

      // Search results
      ForEach(places):
        TaSearchResult(place, → pickPlace(name))
      // OR empty state
      Container(bg:white, borderRadius:16, shadow:shadowMd, centered, muted): "No places match"

      // Footnote
      Text("📍 Showing places near Phnom Penh", 12, #9AA0B4, centered)
```

### Interactions
- Type in search → filter places by name/km/addr
- Tap place → set destination → `show('s-map')` + toast "Destination set ✓"
- Back → `show('s-map')`

---

## Screen 9: Booking (Active Ride)

**Route:** `/booking` | **Purpose:** Track ride progress

### Layout
```
Scaffold:
  Stack:
    // Map (full screen, read-only tracking)
    GoogleMap (or SVG) with route polyline

    // Status pill
    Positioned(top:52, centered):
      TaStatusPill(statusText, pulsing: true)

    // Skip button (demo)
    Positioned(top:52, right:12):
      Button("Skip ▸", bg: rgba(35,40,56,.75), white, 11/700, → finishTrip)

    // Bottom sheet
    TaBottomSheet:
      // Ride progress timeline
      TaTimeline(steps: ["Accepted","Arriving","On trip"], current: phase)

      // Driver card
      TaDriverCard(name, rating, vehicleInfo, plate, initials)

      // Action buttons
      Row(gap:10):
        TaButton(variant: dark, flex:1.2, "Call", icon:phone, → toast("Calling"))
        TaButton(variant: ghost, flex:1, "Safety", icon:shield(green), → toast("Safety coming soon"))
      SizedBox(h:10)
      // Cancel button (hidden during On trip)
      TaButton(variant: dangerGhost, "Cancel", visible: phase<2, → askCancel)
```

### States
| Phase | Status Pill | Timeline | Driver Card | Cancel Visible |
|---|---|---|---|---|
| 0: Accepted | "Driver accepted" (pulse) | Step 1 active | Full | Yes |
| 1: Arriving | "Driver is arriving" (pulse) | Step 2 active | Full | Yes |
| 2: On trip | "On trip · enjoy!" (pulse) | Step 3 active | Full | No |

### Interactions
- Skip → `finishTrip()` → s-fee
- Call → toast
- Safety → toast "coming soon"
- Cancel → dialog "Cancel booking?" → Yes → s-home + toast / No → close dialog
- Auto → finishTrip after 17s (demo)

---

## Screen 10: Fee (CalculateFee)

**Route:** `/calculatefee` | **Purpose:** Display fare after ride

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    // Header (no back button)
    Text("Trip fare", 17/700, centered)

    // Fee card
    TaCard:
      // Driver row
      TaDriverCard(name, vehicleInfo, initials) // no rating, no plate in fee

      Divider
      TaKVRow("Distance", "6.1 km")
      TaKVRow("Duration", "18 min")
      TaKVRow("Vehicle", "Tuk-Tuk")
      TaKVRow("Date", "11 Sep 2026 · 09:41")

      Divider
      // Route summary
      TaAddressRow(start, dot: navy, "No. 128, St. 271")
      TaAddressRow(end, dot: brand, "Aeon Mall Phnom Penh")

    // Total box
    TaTotalBox(amount: "$4.85", label: "Total · Cash")
    SizedBox(h:12)

    // Payment status
    TaCard(centered):
      // When waiting:
      TaBadge("⏳ Waiting for driver to confirm payment", warning)
      // When paid:
      TaBadge("Payment confirmed ✓", success)

    SizedBox(h:12)
    // Simulate payment button (demo)
    TaButton(variant: ghost, sm, "Simulate: driver confirms payment", → markPaid)
```

### States
| State | Payment Box | Button |
|---|---|---|
| Waiting | Warning badge | "Simulate payment" visible |
| Paid | Green badge "Payment confirmed ✓" | hidden → navigate to Rating |

### Interactions
- Auto-pay after 9s (demo)
- Mark paid → 900ms → `show('s-rating')`

---

## Screen 11: Rating (NEW)

**Route:** `/rating` | **Purpose:** Rate driver after trip

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column(centered):
    // Driver avatar
    TaAvatar(initials, gradient: blue→purple, 72×72, fontSize:24)
    SizedBox(h:12)
    Text("Rate your driver", 24/800)
    SizedBox(h:6)
    Text("How was your trip?", 13/400, #6B7588)

    // Star rating (5 stars)
    TaStarRating(rating, → setStar)

    // Tag chips
    Wrap(gap:8, center):
      TaChip("Polite", selected, → toggle)
      TaChip("Clean car", selected, → toggle)
      TaChip("Safe driving", selected, → toggle)
      TaChip("Fast pickup", selected, → toggle)

    // Note textarea
    TextField(multiline, placeholder: "Add a note for driver", height:76, radius:14, border:1.5px #EBEBF0)

    Spacer()
    TaPrimaryButton("Submit", disabled: rating==0, → submitRating)
```

### Interactions
- Tap star → set rating (1-5), enable Submit
- Tap chip → toggle selection
- Submit → `show('s-receipt')`

---

## Screen 12: Receipt (NEW)

**Route:** `/receipt` | **Purpose:** Trip completion confirmation

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column(centered):
    // Success check (animated pop2)
    Container(96×96, borderRadius:99, bg:#E6F8EF, centered):
      Icon(check, 48, #0EAF6B, strokeWidth:3)
    SizedBox(h:16)
    Text("Thank you!", 24/800)
    SizedBox(h:6)
    Text("Your trip is complete. Receipt sent.", 13/400, #6B7588)
    SizedBox(h:16)

    // Receipt card
    TaCard:
      TaKVRow("INV-2042", "★★★★★ · 4/5")
      TaKVRow("Aeon Mall Phnom Penh", "$4.85")
      TaKVRow("Cash", "Paid" (green))

    Spacer()
    TaPrimaryButton("Back to Home", → show('s-home'))
    SizedBox(h:10)
    TaButton(variant: ghost, "Book again", → show('s-map'))
```

---

## Screen 13: History

**Route:** Tab 1 | **Purpose:** Booking history

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides, paddingBottom:96px):
  Column:
    // Header
    Row: Text("Riding History", 17/700)
    SizedBox(h:14)

    // Segmented tabs
    Container(bg: #E8EAF0, borderRadius:14, padding:4):
      Row:
        Button("Completed", active: tab==0, → setHistTab(0))
        Button("Cancelled", active: tab==1, → setHistTab(1))

    SizedBox(h:14)

    // History list
    ForEach(filteredHistory):
      TaHistoryCard(item, onTap: → s-hdetail)
```

### States
| State | UI |
|---|---|
| No data | Empty state |
| Has data | History cards |

---

## Screen 14: History Detail

**Route:** `/historydetail` | **Purpose:** Single history item

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-history)
      Text("INV-2041", 17/700)
    SizedBox(h:12)

    // Mini map (200px)
    Container(200, borderRadius:16, shadow:shadowMd, clip:
      SVG map with route + markers
    )
    SizedBox(h:12)

    // Detail card
    TaCard:
      Row(gap:10, align: center):
        TaAvatar(havatar, 44px, gradient: orange→purple)
        Column:
          Text(invoice, fontWeight:800)
          Text("driver · date", 12, #6B7588)
        Text(amount, fontWeight:800, fontSize:16) // marginLeft: auto

      SizedBox(h:8)
      TaBadge("Completed", success)

      TaKVRow("Distance", "6.1 km")
      TaKVRow("Duration", "18 min")
      TaKVRow("Cash", "Paid" (green))
```

---

## Screen 15: Profile

**Route:** Tab 2 | **Purpose:** User account + settings

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides, paddingBottom:96px):
  Column:
    // Header row
    Row(spaceBetween):
      Text("Profile", 17/700)
      TaSegmentedControl(["EN","ខ្មែរ"], selected, → toggleLang)
    SizedBox(h:14)

    // Profile card
    Container(bg:white, borderRadius:16, shadow:shadowMd, padding:16):
      Row(gap:14, align: center):
        TaAvatar(gradient: orange→purple, initials: "ML", 48px)
        Column:
          Text("Mey Lin", 17/700)
          Text("+855 12 345 678", 12/400, #6B7588)

    SizedBox(h:14)

    // Menu rows
    TaProfileRow(icon:bell, "Announcements", → s-news)
    TaProfileRow(icon:pin, "Saved places", → toast("Saved places coming soon"))
    TaProfileRow(icon:doc, "Terms & Conditions", → s-terms)
    TaProfileRow(icon:mail, "Contact Us", → s-contact)
    TaProfileRow(icon:out, "Log out", isDanger:true, → askLogout)

    // Version
    SizedBox(h:14)
    Text("Version 1.2.1", 12/400, #9AA0B4, centered)
```

---

## Screen 16: Terms & Conditions

**Route:** `/termcondition` | **Purpose:** Legal terms

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-profile)
      Text("Terms & Conditions", 17/700)
    SizedBox(h:14)
    ForEach(terms):
      Container(bg:white, borderRadius:14, shadow:shadowSm, padding:14, marginBottom:8):
        Row(gap:12):
          Container(26×26, borderRadius:99, bg:#FFF4ED):
            Text(index+1, 13/700, #CC3700, centered)
          Text(term, 14/400, flex:1)
```

---

## Screen 17: Contact Us

**Route:** `/contactus` | **Purpose:** Company info

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-profile)
      Text("Contact Us", 17/700)
    SizedBox(h:12)

    // Logo badge (72×72)
    Center: Container(72×72, borderRadius:28, gradient: orange):
      Icon(star, 36, white)
    SizedBox(h:12)
    Text("Taarraa Taxi · Phnom Penh", 12/400, #6B7588, centered)
    SizedBox(h:14)

    // Contact rows
    TaProfileRow(icon:phone, "Smart: +855 70 427 213", → toast("Calling"))
    TaProfileRow(icon:phone, "Cellcard: +855 12 285 048", → toast("Calling"))
    TaProfileRow(icon:mail, "tarataxi24@gmail.com", → toast("Email"))
    TaProfileRow(icon:pin, "St. 271, Toul Kouk, Phnom Penh", onTap: null, noTrailing)
```

---

## Screen 18: Announcements

**Route:** `/announcement` | **Purpose:** List of announcements

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-home)
      Text("Announcements", 17/700)
    SizedBox(h:14)

    ForEach(news):
      Container(bg:white, borderRadius:16, shadow:shadowMd, padding:16, marginBottom:10, onTap):
        Text(title, 15/700)
        Text(excerpt + "…", 13/400, #6B7588, marginTop:4)
        Text(date, 12/400, #9AA0B4, marginTop:8, as block)
```

---

## Screen 19: Announcement Detail

**Route:** `/announcement_detail` | **Purpose:** Single announcement

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-news)
      Text("Announcements", 17/700)
    SizedBox(h:14)

    TaCard:
      Text(title, 17/700)
      Text(date, 12/400, #9AA0B4, marginTop:6)
      Text(body, 14/400, #6B7588, lineHeight:1.6, marginTop:8)
      // Image placeholder
      Container(120px, borderRadius:12, bg:linear-gradient(120deg, #FFE4D3, #D8E6FF)):
        Icon(bell, 28, #FF4500)
```

---

## Screen 20: Design Tokens (NEW)

**Route:** `/design-tokens` | **Purpose:** Internal reference (prototype sidebar only, not in prod app)

### Layout
```
SafeArea → Scaffold(bg: #F6F6F7, padding: 46px top, 20px sides):
  Column:
    Row(gap:12):
      TaIconButton(icon: back, → s-home)
      Text("Design tokens · v2", 17/700)
    Text("Proposal: semantic color scale, type, spacing, radius", 12, #6B7588)
    SizedBox(h:10)

    // Brand swatches
    TaCard:
      Text("Brand", fontWeight:700)
      Row(gap:8):
        Swatch(FFA84C, "400") | Swatch(FF4500, "500") | Swatch(CC3700, "600")

    // Neutrals
    TaCard:
      Text("Neutrals", fontWeight:700)
      Grid(4col):
        Swatch(191C24, "ink") | Swatch(6B7588, "sub") | Swatch(EBEBF0, "line") | Swatch(F6F6F7, "bg")

    // Type scale
    TaCard:
      Text("Type · Kantumruy Pro", fontWeight:700)
      Row: "Heading 24 / ExtraBold" (24/800)
      Row: "Title 17 / Bold" (17/700)
      Row: "Body 15 / Regular · សួស្តី ខ្មែរ" (15/400)
      Row: "Caption 13 / Regular" (13/400, #6B7588)

    // Components
    TaCard:
      Text("Components", fontWeight:700)
      TaPrimaryButton("Primary · 52h · r16", sm)
      SizedBox(h:8)
      TaButton(variant:ghost, sm, "Secondary")
      Row(gap:8):
        TaBadge("Completed", success) | TaBadge("Arriving", warning) | TaBadge("Cancelled", error)

    // Spacing
    TaCard:
      Text("Spacing scale", fontWeight:700)
      Row(aligned bottom, gap:8):
        SpacingBar(4) | SpacingBar(8) | SpacingBar(12) | SpacingBar(16) | SpacingBar(24) | SpacingBar(32) | SpacingBar(48)
```

---

## Screen Summary

| # | Screen | Route | Type | Key Change from Current |
|---|---|---|---|---|
| 1 | Splash | `/splash` | Existing | Animated logo, loading bar, Skip |
| 2 | Login | `/login` | Existing | Step indicator, segmented lang, "Next" |
| 3 | OTP | `/otp` | Existing | 4-box inputs, timer pill, step indicator |
| 4 | Register | `/register` | Existing | Step indicator, "Create"/"Skip" |
| 5 | BottomNav | Tab host | Existing | Floating pill nav |
| 6 | Home | Tab 0 | Existing | Vertical list, promo, search card, bell |
| 7 | Map | `/map` | Existing | Restructured sheet, tariff sheet |
| 8 | Search | `/dragMap` | Existing | Minimap, place cards w/ distance |
| 9 | Booking | `/booking` | Existing | Timeline, status-pill, driver card, plate |
| 10 | Fee | `/calculatefee` | Existing | Total-box, payment badge, simulate button |
| 11 | Rating | `/rating` | **NEW** | Stars, chips, textarea |
| 12 | Receipt | `/receipt` | **NEW** | Green check, invoice, Book again |
| 13 | History | Tab 1 | Existing | Segmented tabs, simplified cards |
| 14 | HistoryDetail | `/historydetail` | Existing | Minimap + detail card |
| 15 | Profile | Tab 2 | Existing | 5 menu rows, lang toggle, version |
| 16 | Terms | `/termcondition` | Existing | Numbered cards |
| 17 | Contact | `/contactus` | Existing | Logo, 4 contact rows |
| 18 | Announcements | `/announcement` | Existing | News cards |
| 19 | AnnouncementDetail | `/announcement_detail` | Existing | Full content + image placeholder |
| 20 | Design Tokens | (internal) | **NEW** | Style reference (prototype only) |
