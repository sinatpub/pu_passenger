# Phase 3 — UI Inventory

## 1. Screen Inventory

### Screen 1: Splash Screen

| Property | Value |
|---|---|
| Purpose | Branding splash + auth gate |
| File | `lib/presentation/screens/splash_screen/view.dart` |
| Feature | Authentication |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold` → `Center` → `Column` (centered vertically, mainAxisSize: min)
  - `Image.asset("logo_app.png")` — width: 120
  - `SizedBox(height: 10)`
  - `Text("TAARRAA Taxi")` — `ThemeConstands.font20SemiBold`, color: `AppColors.main`

**UI States:**
- Loading: token check runs in background (no visible spinner — 1s delay)
- No explicit empty/error states

**Interactions:** None

---

### Screen 2: Login

| Property | Value |
|---|---|
| Purpose | Phone number input for authentication |
| File | `lib/presentation/screens/login/view.dart` |
| Feature | Authentication |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(backgroundColor: AppColors.light4)` → `SafeArea` → `Container(margin: horizontal 16)` → `SingleChildScrollView` → `Column`:
  - `SizedBox(28)`
  - Language toggle `IconButton` (top-right): English flag / Khmer flag
  - `SizedBox(28)`
  - `Text("titleLogin")` — `font20SemiBold`
  - `SizedBox(18)`
  - `Text("desLogin")` — `font16Regular`
  - `SizedBox(48)`
  - Phone input section:
    - `Text("phoneNumber")` label
    - `SizedBox(12)`
    - `ShakeWidget` → `XTextField`:
      - prefix: `+855` (Cambodia)
      - inputFormatters: digits only, max 12, `CardNumberInputFormatter`
      - hintText: "enterPhoneNumber"
      - keyboardType: phone
  - `SizedBox(38)`
  - `FBTNWidget` — label: "Next", color: `AppColors.main`

**UI States:**
- Normal: form ready for input
- Invalid phone: shake animation + haptic feedback + snackbar error
- Loading: `EasyLoading.show()` during API call
- Error: `showErrorCustomDialog` with retry

**Interactions:**
- Language toggle (EN/KM)
- Phone number input
- Tap "Next" or keyboard submit → `phoneLogin()`

---

### Screen 3: OTP Verification

| Property | Value |
|---|---|
| Purpose | 4-digit OTP verification |
| File | `lib/presentation/screens/otp/view.dart` |
| Feature | Authentication |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(backgroundColor: light4)` → `SafeArea` → `Column`:
  - Back button (arrow_back_ios_new)
  - `SingleChildScrollView` → `Column`:
    - `SizedBox(28)`
    - `Text("otpVerification")` — `font20SemiBold`
    - `SizedBox(18)`
    - `Text("desOtpVerification")` — `font16Regular`
    - `SizedBox(48)`
    - `Pinput` (4 digits, autofocus):
      - ShakeWidget wrapper
      - Custom themes: default, focused, error (red border), submitted
      - Auto-read SMS via `SmsRetrieverImpl`
    - `SizedBox(28)`
    - Row: `Text("didNotGetCode")` + `SlideCountdown` timer
    - Conditional: `TextButton("sendAgain")` when timer reaches 0
  - Loading overlay: `LoadingWidget` (semi-transparent)

**UI States:**
- Loading: `LoadingWidget` overlay
- Timer running: countdown visible
- Resend: enabled/disabled based on timer
- Error: pin border turns red, shake animation, error dialog
- Auto-verify: triggers on 4 digits entered

**Interactions:**
- Type OTP → auto-verifies on completion
- Tap "Send Again" → resend OTP + restart timer
- Back → `Get.back()`

---

### Screen 4: Register

| Property | Value |
|---|---|
| Purpose | Complete profile after OTP (new users only) |
| File | `lib/presentation/screens/register/view.dart` |
| Feature | Authentication |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(backgroundColor: light4)` → `SafeArea` → `Container(margin: h18)` → `Column`:
  - Language toggle (top-right)
  - `SingleChildScrollView` → `GetBuilder<RegisterLogic>` → `Column`:
    - `Text("completeProfile")` — `font20SemiBold`
    - `Text("desRegister")` — `font16Regular`
    - `CardUploadAttachment` (160x160):
      - Circle avatar with selected image
      - Camera icon button (bottom-right positioned)
      - Remove icon (top-right)
    - `SizedBox(48)`
    - `Text("Full Name")` — bilingual label
    - `TextFormField` for name
    - `SizedBox(32)`
    - `FBTNWidget("Create")` — disabled if name empty OR no image
    - `SizedBox(18)`
    - `Text("or")`
    - `TextButton("Skip")`

**UI States:**
- Normal: form ready
- Loading: `EasyLoading.show()` during registration
- Create button: disabled state when name empty or no profile image
- Image picker: bottom sheet (Gallery / Take Photo)

**Interactions:**
- Language toggle
- Tap camera icon / profile image → image picker bottom sheet
- Type full name
- Tap "Create" → `passengerRegister()`
- Tap "Skip" → auto-generate name → register
- Remove profile image

---

### Screen 5: Bottom Navigation Host

| Property | Value |
|---|---|
| Purpose | 3-tab navigation container |
| File | `lib/presentation/screens/bottom_nav/view.dart` |
| Feature | Navigation |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold`:
  - `body`: `Obx` → `logic.pages[logic.selectedIndex.value]`
  - `bottomNavigationBar`: `BottomNavigationBar` with 3 items:
    - Tab 0: Home (`Icons.home`) → `HomeScreen()`
    - Tab 1: My Booking (`Icons.event`) → `HistoryScreen()`
    - Tab 2: Profile (`Icons.person`) → `ProfileScreen()`

**UI States:** N/A (container)

**Interactions:** Tap bottom nav tabs → `changePage(index)`

---

### Screen 6: Home

| Property | Value |
|---|---|
| Purpose | Vehicle selection grid + booking entry |
| File | `lib/presentation/screens/home/view.dart` |
| Feature | Core Booking |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(backgroundColor: AppColors.main)` → `SafeArea` → `RefreshIndicator` → `SingleChildScrollView` → `Stack` → `Column`:
  - **Header** (height: 100):
    - `Text("TAARRAA")` — `font28SemiBold`, white
    - `Text("តារា")` — `KhmerMoul` font, white
  - **Vehicle grid** (`GetBuilder<HomeLogic>`):
    - Loading: `SizedBox.shrink()` (empty)
    - Error: centered `Text("noVehicleAvailable")`
    - Success: `Container(white)` → `SingleChildScrollView`:
      - Row 1: Vehicle[0] (tuk-tuk) + Vehicle[1] (classic car)
      - Center: Vehicle[4] (alphard VIP) — `CircleAvatar` overlay
      - Row 2: Vehicle[2] (SUV) + Vehicle[3] (minivan)
      - Each card: `InkWell` → `Container` (red@80% alpha, rounded 12):
        - `TImageWidget` (network image with asset fallback)
        - Vehicle name text below

**UI States:**
- Loading: empty space (SizedBox.shrink)
- Error: "No vehicle data available" text
- Success: 5 vehicle cards in 2x2 + center VIP circle

**Interactions:**
- Pull to refresh → `getVehicleType()`
- Tap vehicle card → `Get.toNamed(AppRoutes.MAP, arguments: {vehicleId})`

---

### Screen 7: Map Screen (Booking Request)

| Property | Value |
|---|---|
| Purpose | Select pickup + destination, request booking |
| File | `lib/presentation/screens/map_screen/view.dart` |
| Feature | Core Booking |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold` → `Stack`:
  - **Column:**
    - **Expanded → Stack:**
      - **GoogleMap** (full screen):
        - myLocationEnabled, compass, no zoom controls
        - polylines, markers from state
        - onCameraIdle: updates pickup location
      - **MapAppbar** (positioned top):
        - Back button (white, shadow)
        - "My Location" label
      - **Current location FAB** (bottom-right)
      - **Pin marker** (center, SVG marker, only when no destination)
    - **Bottom sheet** (height: 330-350):
      - **SearchWhereToGo** (when no destination):
        - Grey rounded container with search icon + "Where to go"
      - Current location address row (marker icon + address text)
      - **When destination set:**
        - Divider
        - Destination address row (with delete icon)
        - Distance + Fare row
        - Divider
      - Vehicle type section:
        - Vehicle image + name + seat capacity
        - "Tarif" button → `DetailServiceDialog`
      - `FBTNWidget("Booking Now")`
  - **Booking loading overlay** (`requestBookingLoading`):
    - Semi-transparent white
    - `CircularProgressIndicator` + car icon
    - `FBTNWidget("Cancel")`

**UI States:**
- No destination: show "Where to go" search + center pin
- Destination set: show route, distance, fare, booking button
- Booking loading: full-screen overlay with spinner + cancel
- Map camera moving: pin slides up

**Interactions:**
- Drag map → updates pickup location
- Tap "Where to go" → navigate to DRAGMAP
- Tap "Tarif" → DetailServiceDialog bottom sheet
- Tap "Booking Now" → `requestBooking()`
- Tap cancel → dismiss overlay
- Tap "My Location" FAB → recenter map
- Tap driver marker → DriverInfoSheet

**Child Widgets:**
- `MapAppbar` — `map_screen/widgets/map_appbar.dart`
- `SearchWhereToGo` — `map_screen/widgets/search_where_to_go.dart`
- `DetailServiceDialog` — `map_screen/widgets/detail_service_dialog.dart` (modal bottom sheet: vehicle image, name, seats, min fee, price/km)
- `DriverInfoSheet` — `map_screen/widgets/driver_info_sheet.dart` (bottom sheet: photo, name, vehicle, phone call)

---

### Screen 8: Map Drag (Location Search)

| Property | Value |
|---|---|
| Purpose | Search for pickup/destination with map + text search |
| File | `lib/presentation/shared/map_drag/view.dart` |
| Feature | Location Selection |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(white)` → `AppBar("Search Location")` → `SafeArea` → `Stack`:
  - **Column:**
    - **Search area** (when text search visible):
      - `XTextField` (search icon, "Enter address")
      - `Expanded` → `_setOnMapRow` (marker icon + "Set location on the map")
    - **Divider**
    - **GoogleMap** (Expanded):
      - Traffic, my location, indoor, compass, zoom controls
      - Center pin (SVG marker, animated slide on drag)
      - Pickup callout (pickup flow only)
  - **Search results overlay** (AnimatedPositioned):
    - `DestinationSearchStatus` driven:
      - idle/belowThreshold: hint text
      - searching (previous results): dimmed list (opacity 0.4)
      - searching (no results): 3 shimmer skeleton rows
      - error: "Couldn't search" + Retry
      - empty: "No places match" + spelling hint
      - results: `_PlaceRow` list
  - **Confirm button** (positioned bottom):
    - Pickup flow: full width + "Add a note for driver" field (max 60 chars)
    - Destination flow: centered, half width
    - Disabled when: no pin, resolving, or outside service area

**UI States:**
- Search: idle, belowThreshold, searching (skeleton/dimmed), results, empty, error
- Map: camera moving (pin slides), camera idle (pin drops)
- Pickup: resolving (skeleton), ready, approximate
- Confirm: enabled/disabled

**Interactions:**
- Type in search → debounced Places API (300ms, min 3 chars)
- Tap prediction → place details → return LatLng
- Tap "Set location on map" → full map view
- Drag map → pin animates → reverse geocode on idle
- Tap confirm → `Get.back(result: state.latlng)`
- Type driver note → max 60 chars, word-boundary aware

---

### Screen 9: Booking Map (Active Ride)

| Property | Value |
|---|---|
| Purpose | Track active ride with driver location |
| File | `lib/presentation/screens/booking_map_screen/booking_map_screen.dart` |
| Feature | Active Ride |
| Activity Status | ACTIVE |

**Visual Structure:**
- `PopScope(canPop: false)` → `Scaffold` → `Column`:
  - **Expanded → GoogleMap** (markers, polylines from state)
  - **Bottom sheet (`_driverInfo`):**
    - Status text via `GetBuilder<AppLogic>` (e.g., "Waiting for driver", "Driver arrived", "Ride started")
    - Driver info row:
      - Overlapping circle images (vehicle type + driver vehicle)
      - Driver name + vehicle type name
      - Phone call button
    - Cancel booking button (hidden when driver arrived)

**UI States:**
- Cannot go back (PopScope)
- Dynamic status text
- Real-time marker updates (polled or via socket)
- Cancel button: visible/hidden based on status

**Interactions:**
- Tap phone → `launchUrl(scheme: 'tel')`
- Tap cancel → cancel booking (currently commented out)
- No map interaction (read-only tracking)

---

### Screen 10: Calculate Fee

| Property | Value |
|---|---|
| Purpose | Display fare breakdown after ride completion |
| File | `lib/presentation/screens/calculate_fee/calculate_fee_screen.dart` |
| Feature | Payment |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold(backgroundColor: light4)` → `SafeArea` → `Column`:
  - Header: "Calculate Fee" text
  - Divider
  - Loading: `CircularProgressIndicator` / Content:
    - `SingleChildScrollView` → `Column`:
      - **Driver info card** (bordered container):
        - CircleAvatar + driver name + payment method
        - "Payment Collection" label (red)
        - Row cards: Distance, Duration, DateTime
        - Location details: pickup → destination (SVG icons + dotted line)
      - **Total price section** (red background):
        - "Total Price" + amount + currency symbol
      - **Payment info:**
        - "Wait payment from driver" text

**UI States:**
- Loading: centered `CircularProgressIndicator`
- Success: full content
- No empty/error state

**Interactions:** None (read-only display)

---

### Screen 11: History

| Property | Value |
|---|---|
| Purpose | Booking history with completed/cancelled tabs |
| File | `lib/presentation/screens/history/view.dart` |
| Feature | History |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold`:
  - `AppBar`:
    - Title: "Riding History"
    - `TabBar`: [Completed, Cancelled]
  - `TabBarView`:
    - Tab 0: `CompletedTabWidget` (filter status 4)
    - Tab 1: `CancelledTabWidget` (filter status 5)

**History Card** (`history_card_widget.dart`):
- `Container` (white, rounded 12, shadow):
  - Top row: CircleAvatar + Column (Invoice #, driver name, payment, date) + Status badge (green/red)
  - Metrics row: Distance, Duration, Amount (with icons)
  - Divider
  - Vehicle type row
  - Divider
  - Map placeholder image
  - Address section: Start (current location icon) → DottedLine → End (book icon)

**UI States:**
- Pull to refresh
- Infinite scroll pagination
- Loading: `LinearProgressIndicator` at bottom
- No more data: text indicator

**Interactions:**
- Pull to refresh
- Tap card → `Get.toNamed(HISTORYDETAIL, arguments: data)`
- Scroll to load more

---

### Screen 12: History Detail

| Property | Value |
|---|---|
| Purpose | Single history item with route map |
| File | `lib/presentation/screens/history_detail/view.dart` |
| Feature | History |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold` → `AppBar("History Detail")` → `GetBuilder` → `Container` (white, rounded 12):
  - Top row: Profile image, Invoice #, driver name, payment method, status badge
  - Metrics row: Distance, Duration, Amount
  - Divider
  - Date/Time row
  - Divider
  - Address section: Start → DottedLine → End
  - Expanded → GoogleMap (polyline route with driver + passenger markers)

**UI States:** Always shows data (received via arguments)

**Interactions:** None (read-only, back via AppBar)

---

### Screen 13: Profile

| Property | Value |
|---|---|
| Purpose | User profile + settings |
| File | `lib/presentation/screens/profile/profile_screen.dart` |
| Feature | Profile |
| Activity Status | ACTIVE |

**Visual Structure:**
- `SafeArea` → `Column`:
  - Header: "Profile" text + language toggle (top-right icon)
  - Divider
  - Profile info (`Obx`):
    - Row: `TImageWidget` (80) + Name + "See Your Profile" text
  - Settings section:
    - `FTNWidget("Terms & Conditions")` → CupertinoIcons.doc_text
    - `FTNWidget("Contact Us")` → CupertinoIcons.person_crop_circle_fill
    - (Commented-out: logout button)

**UI States:** Profile data loaded reactively via `Obx`

**Interactions:**
- Language toggle
- Tap "Terms & Conditions" → `TERMCONDITION`
- Tap "Contact Us" → `CONTACTUS`

---

### Screen 14: Terms & Conditions

| Property | Value |
|---|---|
| Purpose | Display terms and conditions |
| File | `lib/presentation/screens/term_condition/view.dart` |
| Feature | Info |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold` → `AppBar("Terms and Conditions")` → `Padding(16)` → `Column`:
  - `Expanded` → `ListView.separated`: 5 hardcoded terms (numbered list)

**UI States:** Static content

**Interactions:** Scroll only

---

### Screen 15: Contact Us

| Property | Value |
|---|---|
| Purpose | Company contact information |
| File | `lib/presentation/screens/contact_us/view.dart` |
| Feature | Info |
| Activity Status | ACTIVE |

**Visual Structure:**
- `Scaffold` → `AppBar("Contact Us")` → `Padding(24)` → `Column`:
  - `CircleAvatar(80)` — company logo
  - Introductory text
  - `ListTile` (phone): Smart: +855 70 427 213
  - `ListTile` (phone): Cellcard: +855 12 285 048
  - `ListTile` (email): tarataxi24@gmail.com
  - `ListTile` (location): address (non-tappable)
  - `Spacer`
  - Copyright text

**UI States:** Static content

**Interactions:**
- Tap phone → `launchUrl(scheme: 'tel')`
- Tap email → `launchUrl(scheme: 'mailto')`

---

### Screen 16: Announcement

| Property | Value |
|---|---|
| Purpose | Paginated announcement list |
| File | `lib/presentation/screens/announcement/view.dart` |
| Feature | Announcements |
| Activity Status | POSSIBLY ACTIVE (entry point on Home is commented out) |

**Visual Structure:**
- `Scaffold` → `AppBar("Announcement")` → `PagedListView`:
  - Card: `Container` (white, rounded 12) → `InkWell`:
    - Title (`font14SemiBold`)
    - Description (`font12Regular`)
    - Date (`font12Regular`)

**UI States:** Pull to refresh, infinite scroll

**Interactions:** Tap card → `ANNOUNCEMENTDETAIL`

---

### Screen 17: Announcement Detail

| Property | Value |
|---|---|
| Purpose | Single announcement with images |
| File | `lib/presentation/screens/announcement_detail/view.dart` |
| Feature | Announcements |
| Activity Status | POSSIBLY ACTIVE (dependent on Announcement entry) |

**Visual Structure:**
- `Scaffold` → `AppBar("Announcement Detail")` → `Container` (grey@20, padded):
  - Title (`font16SemiBold`)
  - Release date row
  - Description (`font14Regular`)
  - Horizontal image list (`ListView.separated`, height: 120)

**UI States:** Always shows data (loaded by ID)

**Interactions:** Scroll images horizontally

---

### Screen 18: Rate Driver (Library Only)

| Property | Value |
|---|---|
| Purpose | Rating logic (no UI screen) |
| File | `lib/presentation/screens/rate_driver/rating.dart` |
| Feature | Rating |
| Activity Status | UNUSED (awaiting rating endpoint — ticket P-11) |

Pure Dart library with `RatingDraft`, `RatingTag`, `PendingRating` — no Flutter widgets, no datasource, no screen.

---

## 2. Component and Overlay Inventory

### Reusable UI Components (`lib/presentation/widgets/`)

| Component | File | Purpose | Visual | Key Props |
|---|---|---|---|---|
| `CardUploadAttachment` | `card_atta_widget.dart` | Profile image upload card | 140x140 circle, red delete icon | `onPressedIcon`, `icon`, `image`, `title` |
| `ShimmerCardBoardWidget` | `card_board_shimmer_widget.dart` | Shimmer loading for cards | 310px, grey shimmer | const |
| `CenterLoading` | `center_loading.dart` | Centered spinner | `CircularProgressIndicator` (AppColors.main) | const |
| `CustomAnimation` | `custom_animated_loading.dart` | EasyLoading animation | Rotation + opacity | — |
| `showCustomSnackBar` | `custom_snackbar_widget.dart` | Toast notification | White, 18px radius, auto-close 2s | `title`, `message`, `isError` |
| `DecoratedInputBorder` | `decorated_input_border.dart` | Shadow on text fields | Box shadow: rgba(96,96,96,0.17) | `.shadow()` extension |
| `EmptyData` | `empty_data.dart` | Empty state | "No result found" text | `message`, `isNeedShowFullScreen` |
| `showErrorCustomDialog` | `error_dialog_widget.dart` | Error dialog with retry | AlertDialog, red button | `title`, `message`, `onPress` |
| `FBTNWidget` | `fbtn_widget.dart` | Primary CTA button | Height 38, AppColors.main bg, white text | `label`, `color`, `onPressed`, `prefix` |
| `gShowModalBottomSheet` | `g_showmodal_bottom.dart` | Draggable bottom sheet | 18px top corners, drag handle | `child`, `initial`, `max`, `min` |
| `LoadingShimmer` | `loading_shimmer.dart` | Generic shimmer placeholder | List or grid layout | `isGridView`, `dataCount`, `height` |
| `LoadingWidget` | `loading_widget.dart` | Full-screen loading overlay | Grey@30% + centered spinner | const |
| `ShakeWidget` | `shake_widget.dart` | Horizontal shake animation | Sine wave, configurable offset | `child`, `shakeOffset`, `shakeDuration` |
| `TImageWidget` | `t_image_widget.dart` | Vehicle image display | Network/asset fallback, vehicle ID mapping | `src`, `height`, `width` |
| `getTextFieldDecoration` | `text_field_decoration.dart` | Standard input decoration | Filled white, 10px radius, shadow | focus=AppColors.main, error=red |
| `XButton` | `x_button.dart` | Transparent overlay button | InkWell over child | `onPress`, `child`, `borderRadius` |
| `XNetworkImage` | `x_network_image.dart` | Network image with states | Shimmer load, progress, error fallback | `src`, `fit`, `height`, `width` |
| `xShowModalBottomSheet` | `x_showmodal_bottom.dart` | Themed bottom sheet | 18px top corners, themed divider | `child`, `initial`, `max`, `min` |
| `XTextField` | `x_text_field.dart` | Standard text input | 8px radius, AppColors.main cursor | `hintText`, `maxLines`, `prefixIcon` |
| `showYesNoCustomDialog` | `yesno_dialog_widget.dart` | Confirmation dialog | Yes=red, No=standard, Okay=light | `title`, `message`, `onPressYes` |

### Map Drag Components (`lib/presentation/shared/map_drag/`)

| Component | File | Purpose |
|---|---|---|
| `MapDragArgs` / `MapDragPurpose` | `args.dart` | Route arguments (pickup vs destination) |
| `PickupLabel` / `PickupConfirmState` | `pickup_label.dart` | Pickup resolution state machine |
| `DestinationSearchStatus` | `search_state.dart` | Search UI state enum |

### Screen-Specific Widgets

| Widget | File | Used In |
|---|---|---|
| `MapAppbar` | `map_screen/widgets/map_appbar.dart` | Map Screen |
| `SearchWhereToGo` | `map_screen/widgets/search_where_to_go.dart` | Map Screen |
| `DetailServiceDialog` | `map_screen/widgets/detail_service_dialog.dart` | Map Screen (bottom sheet) |
| `DriverInfoSheet` | `map_screen/widgets/driver_info_sheet.dart` | Map Screen (bottom sheet) |
| `HistoryCardWidget` | `history/widgets/history_card_widget.dart` | History |
| `CompletedTabWidget` | `history/widgets/completed_tab.dart` | History |
| `CancelledTabWidget` | `history/widgets/cancelled_tab.dart` | History |

### Dialogs and Overlays

| Type | Function | Visual |
|---|---|---|
| Error dialog | `showErrorCustomDialog()` | AlertDialog + red retry button |
| Yes/No dialog | `showYesNoCustomDialog()` | AlertDialog + red Yes / light Okay |
| Loading overlay | `EasyLoading.show()` | Global spinner overlay |
| Full-screen loading | `LoadingWidget` | Grey@30% + centered spinner |
| Snackbar | `showCustomSnackBar()` | Toastification toast |
| Bottom sheet | `gShowModalBottomSheet()` | Drag-to-resize, 18px corners |
| Update dialog | `AppLogic.showBeautifulUpdateDialog()` | Version info + store link |

---

## 3. Asset Inventory

### Images

| Asset | Path | Usage |
|---|---|---|
| App logo | `assets/logo_app.png` | Splash screen |
| Company logo | `assets/image/company_logo.png` | Contact Us screen |
| Vehicle images (PNG) | `assets/image/png/Group 18279-18283.png` | Home grid, vehicle cards |
| Vehicle images (SVG) | `assets/image/svg/Group 18279-18283.svg` | Map vehicle display |
| Placeholder image | `assets/image/png/placeholder.jpg` | Fallback for network images |
| Map placeholder | `assets/image/png/map_placeholder.png` | History cards |
| No image SVG | `assets/image/svg/no_image.svg` | Error fallback |

### Icons

| Asset | Path | Usage |
|---|---|---|
| Nav icons (SVG) | `assets/nav_icon/*.svg` | Bottom nav (home, book, profile) |
| Map icons (SVG) | `assets/icon/svg/*.svg` | Map screen (current_location, marker, etc.) |
| Flag icons | `assets/icon/png/flag-en.png`, `assets/image/country/*.svg` | Language toggle, country selector |

### Map Markers

| Asset | Path | Usage |
|---|---|---|
| Passenger marker | `assets/marker/passenger_marker.png` | Map screens |
| Passenger icon marker | `assets/marker/passenger_icon_marker.png` | Map screens |
| Destination marker | `assets/marker/destination_icon.png` | Map screens |
| Vehicle markers | `assets/marker/rickshaw_marker.png`, `classic_marker.png`, etc. | Map screens |
| Current marker | `assets/marker/current_marker.svg` | Map drag |

### Audio

| Asset | Path | Usage |
|---|---|---|
| Booking sound | `assets/sounds/booking_sound.wav` | Local notification sound |

### Fonts

| Font Family | File | Usage |
|---|---|---|
| KantumruyPro (Regular) | `fonts/KantumruyPro-Regular.ttf` | Primary UI font |
| KantumruyPro (SemiBold) | `fonts/KantumruyPro-SemiBold.ttf` | Bold headings |
| KantumruyPro (Variable) | `fonts/KantumruyPro-VariableFont_wght.ttf` | Variable weight |
| KhmerMoul | `fonts/moul_regular.ttf` | "តារា" Khmer brand text |
| TimesNewRomance | `fonts/timesNewRomance.ttf` | Possibly for invoices |
