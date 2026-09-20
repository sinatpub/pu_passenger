# Phase 1 — Technology Stack and Architecture

## 1. Technology Stack

### Framework & Platform

| Property | Value | Source |
|---|---|---|
| Framework | Flutter (stable channel) | `.metadata` |
| Dart SDK | `>=3.4.3 <4.0.0` | `pubspec.yaml:17` |
| Flutter version (FVM) | 3.38.9 | `.fvmrc` |
| iOS minimum | 15.6 (Podfile), post-install forces 14.0 | `ios/Podfile` |
| Android compileSdk | 36, targetSdk 35 | `android/app/build.gradle.kts` |
| Android minSdk | flutter.minSdkVersion (dynamic) | `android/app/build.gradle.kts` |
| App ID | `com.tara.passenger` | `pubspec.yaml:1` |
| Display name | "Taarraa Taxi" | `AndroidManifest.xml`, `Info.plist` |
| Version (iOS) | 1.1.8+1181 | `pubspec.yaml:13` |
| Version (Android) | 1.2.1+1211 (commented) | `pubspec.yaml:12` |

### Primary Language

**Dart** (100% of application logic). **Kotlin** for Android native (`MainActivity.kt` — notification channel setup). No Swift logic beyond iOS runner boilerplate.

### Key Third-Party Packages

| Package | Version | Role |
|---|---|---|
| `get` | ^4.6.6 (resolved 4.7.2) | State management, DI, routing, translations — **core architecture** |
| `dio` | ^5.7.0 | HTTP client |
| `pretty_dio_logger` | ^1.4.0 | API request/response logging |
| `socket_io_client` | ^3.0.0 | Real-time ride events (Socket.IO) |
| `google_maps_flutter` | ^2.6.1 | Maps display, markers, polylines |
| `geolocator` | ^10.1.0 | GPS permission and position stream |
| `geocoding` | ^3.0.0 | Reverse geocode lat/lng to address |
| `flutter_polyline_points` | ^2.1.0 | Route polyline decoding |
| `flutter_compass` | ^0.8.1 | Compass heading for map orientation |
| `firebase_core` | ^4.4.0 | Firebase bootstrap |
| `firebase_messaging` | ^16.1.1 | Push notifications (booking flow driver) |
| `firebase_crashlytics` | ^5.0.7 | Crash reporting |
| `flutter_local_notifications` | ^18.0.0 | Local notifications with custom booking sound |
| `flutter_secure_storage` | ^10.3.1 | Secure auth token storage |
| `shared_preferences` | ^2.3.2 | Legacy token/preferences (migration bridge) |
| `flutter_easyloading` | ^3.0.5 | Global loading overlay |
| `toastification` | ^2.3.0 | Toast notifications |
| `pinput` | ^5.0.0 | OTP input field |
| `smart_auth` | ^3.2.0 | Auto-read SMS OTP |
| `infinite_scroll_pagination` | ^4.0.0 | Paginated lists (history, announcements) |
| `cached_network_image` | ^3.4.1 | Cached remote images |
| `flutter_svg` | ^2.0.10+1 | SVG icon rendering |
| `image_picker` | ^1.1.1 | Profile photo upload |
| `permission_handler` | ^11.3.1 | Runtime permission management |
| `device_info_plus` | ^11.0.0 | Device ID for registration |
| `shimmer` | ^3.0.0 | Shimmer loading placeholders |
| `dropdown_button2` | ^2.3.9 | Custom dropdown selectors |
| `vibration` | ^2.0.1 | Haptic feedback on booking events |
| `url_launcher` | ^6.3.1 | Open external apps (phone, email, stores) |
| `package_info_plus` | ^8.1.2 | Installed app version for update checks |
| `intl` | ^0.20.2 | Date formatting |
| `keyboard_dismisser` | ^3.0.0 | Dismiss keyboard on tap outside |
| `localization` | ^2.1.1 | GetX locale support |
| `slide_countdown` | ^2.0.0 | OTP resend countdown timer |
| `dotted_line` | ^3.2.2 | Dotted separator (payment breakdown) |
| `flutter_switch` | ^0.3.2 | Toggle switches |
| `arc_text` / `flutter_arc_text` | ^0.0.3 / ^0.6.0 | Curved text (logo arc) |
| `logger` | ^2.4.0 | Debug logging |

---

## 2. Project Architecture

### Source Structure

```
lib/
├── app/                        # App-level singletons and global state
│   ├── logic.dart              # AppLogic — language, socket init, logout, version check
│   ├── state.dart              # GoogleMapState — shared map markers/polylines/bitmaps
│   ├── google_map_logic.dart   # GoogleMapLogic — core map controller (camera, markers, polylines, GPS)
│   ├── root_main.dart          # Root widget — GetMaterialApp configuration
│   └── service.dart            # initialService() — registers permanent GetX services
│
├── core/                       # Infrastructure layer
│   ├── api_service/            # Legacy HTTP stack (being replaced)
│   │   ├── base_api_service.dart
│   │   └── client/
│   │       ├── dio_http_client.dart
│   │       └── http_exception.dart
│   ├── config/
│   │   └── app_config.dart     # Centralized environment values
│   ├── helper/                 # Notification and phone validation helpers
│   ├── network/                # New HTTP stack (active migration)
│   │   ├── api_client.dart
│   │   ├── api_exception.dart
│   │   └── result.dart
│   ├── network_config/         # Telegram error reporting, paging config
│   ├── resources/
│   │   └── asset_resource.dart # Asset path constants
│   ├── storage/
│   │   └── token_store.dart    # FlutterSecureStorage wrapper
│   ├── theme/                  # Design tokens (colors, typography, theme)
│   └── utils/                  # Extensions, constants, helpers
│
├── data/                       # Data layer
│   ├── datasources/            # API endpoint wrappers (mix of old and new client)
│   └── models/                 # JSON-deserializable data models
│
├── features/                   # Feature-first migration (partial)
│   ├── auth/data/              # Auth datasource + repository
│   └── profile/data/           # Profile datasource + repository + model
│
├── presentation/               # UI layer
│   ├── screens/                # Screen modules (binding + logic + state + view + widgets/)
│   ├── shared/                 # Shared navigation destinations (map_drag)
│   └── widgets/                # 20 reusable UI components
│
├── routes/
│   └── app_pages.dart          # Centralized route definitions (15 routes)
│
├── services/                   # App-level services
│   ├── booking_session.dart    # Booking state machine (GetxService, permanent)
│   ├── location_service.dart   # Singleton GPS stream owner
│   ├── session_service.dart    # Token lifecycle (cache + secure + legacy migration)
│   └── socket_service.dart     # Socket.IO client + event handlers
│
├── service/                    # Legacy service path
│   ├── location_imp.dart       # LocationRepo — permissions, GPS, geocoding, directions
│   └── notification_logic.dart # Firebase messaging setup
│
├── storages/                   # Legacy SharedPreferences helpers
│
├── taxi_single_ton/            # TaxiNotification singleton (local notifications)
│
├── translations/               # i18n (English + Khmer)
│
└── firebase_options.dart       # FlutterFire-generated config
```

### Architectural Approach

**Pattern:** GetX MVC-ish with screen-per-folder convention.

Each screen module follows:
```
screen_name/
├── binding.dart    # Route-scoped DI (Bindings → Get.lazyPut/Get.put)
├── logic.dart      # GetxController — business logic
├── state.dart      # Rx<T> reactive state fields
├── view.dart       # StatelessWidget — UI composition
└── widgets/        # Screen-specific child widgets (optional)
```

**Active Migration In Progress:**
- Feature-first structure (`features/auth/`, `features/profile/`) is being introduced
- `core/network/` (ApiClient + Result<T>) is replacing `core/api_service/` (BaseApiService + throws)
- Code references tickets `P-xx`/`F-xx`/`Q-xx` throughout, indicating tracked modernization work

---

## 3. State Management and Dependency Injection

### State Management

**GetX** is the sole state management framework.

- **Reactive state:** `Rx<T>` fields in `*State` classes, observed via `Obx` widgets
- **Controller updates:** `update()` with IDs for targeted rebuilds (`GetBuilder(id: ...)`)
- **Global state:** `AppLogic` (permanent) holds language, socket, version
- **Booking state:** `BookingSession` (permanent `GetxService`) preserves booking intent across route changes

### Dependency Injection

**GetX DI container** exclusively. No GetIt, Injectable, or third-party DI.

#### Global Registration (App Startup)

File: `lib/app/service.dart`
```dart
Get.put(AppLogic(), permanent: true);
Get.put(BookingSession(), permanent: true);
Get.put(NotificationLogic(), permanent: true);
```

#### Route-Scoped Registration (Bindings)

Each route has a `binding.dart` that registers screen-specific dependencies via `Get.lazyPut`. Registered when the route is navigated to, disposed when navigated away.

#### Constructor Injection Pattern

Every major `Logic` class accepts optional constructor parameters and falls back to `Get.find<T>()`:

```dart
MapLogic({HomeLogic? homeLogic, LocationRepo? locationRepo, ...})
    : _homeLogic = homeLogic,
      _injectedLocationRepo = locationRepo;

late final HomeLogic homeLogic = _homeLogic ?? Get.find<HomeLogic>();
```

This pattern is used across: `MapLogic`, `HomeLogic`, `BookingMapLogic`, `LoginLogic`, `RegisterLogic`, `OtpLogic`, `ProfileLogic`, `AnnouncementLogic`, `HistoryLogic`, and all datasources.

#### Manual Singletons (Non-GetX)

| Service | Pattern | File |
|---|---|---|
| `PassengerSocketService` | `static final _instance` + factory | `services/socket_service.dart` |
| `SessionService` | `static _instance` + lazy getter | `services/session_service.dart` |
| `LocationService` | `static final instance` | `services/location_service.dart` |
| `BookingSession` | `GetxService` registered permanent | `services/booking_session.dart` |

---

## 4. Networking

### API Client Architecture

**Two parallel HTTP stacks** coexist (mid-migration):

#### New Stack (Active Migration)
- `ApiClient` (thin Dio wrapper) → `Result<T>` (sealed OK/Err) → `ApiException` (typed errors)
- Used by: auth, profile, request-booking, cancel-booking, update-location, driver-around, announcements, history

#### Legacy Stack (Being Replaced)
- `BaseApiService` (Dio wrapper with `onRequest<T>()`) → throws exceptions
- Used by: check-booking-info, vehicle-types, app-version, device-info
- `BaseHttpClient.init()` initializes the shared Dio instance

### Base URL Configuration

Central config: `lib/core/config/app_config.dart`
- `AppConfig.apiBaseUrl` — defaults to `https://taxi-api.simpledevelopertools.com`
- `AppConfig.socketBaseUrl` — same host, Socket.IO mounted at `/socket.io/`
- Values injected at build time via `--dart-define-from-file=dart_defines.json`
- Delegated through `AppConstant.baseUrlApi` / `AppConstant.socketBasedUrl` for legacy call sites

### Environment Handling

- **No Gradle product flavors.** Single bundle, env via `--dart-define-from-file` + iOS `Secrets.xcconfig`
- Required keys: `GOOGLE_MAPS_API_KEY`, `GOOGLE_PLACES_API_KEY` (startup validation in `AppConfig`)
- Optional: `TELEGRAM_BOT_TOKEN` (degrades quietly)
- Debug-only: `DEBUG_OTP_BYPASS`, `DEBUG_LOGIN_PHONE`, `DEBUG_LOGIN_PASSWORD` (triple-gated: `kDebugMode` + dart-define + fixed code)

### Interceptors

Only one: `PrettyDioLogger` — request/response body logging. No auth interceptor; Bearer token is attached per-request in both `ApiClient.request()` and `BaseApiService.onRequest()`.

### Authentication / Token Handling

- **Storage:** `FlutterSecureStorage` wrapped by `TokenStore` (key: `session_token`)
- **Resolution:** `SessionService.getToken()` → in-memory cache → secure storage → legacy SharedPreferences (auto-migrates)
- **Header:** `Authorization: Bearer <token>` attached per-request when `requiresToken: true`
- **Pre-auth endpoints:** login, verify-otp, register use `requiresToken: false`
- **401 handling:** Both clients call `SessionService.handleUnauthorized()` → clears token → `Get.offAllNamed(AppRoutes.LOGIN)`
- **403 handling:** Deliberately does NOT clear token (permission error, not session error)

### API Endpoints

All endpoints use base path `/taxi-passenger/` (new) or `/taxi/` (legacy):

| Endpoint | Method | Client | Purpose |
|---|---|---|---|
| `/taxi-passenger/login-phone` | POST | New | Send OTP to phone |
| `/taxi-passenger/verify-phone-otp` | POST | New | Verify OTP code |
| `/taxi-passenger/register` | POST | New | Complete registration |
| `/taxi-passenger/get-profile` | GET | New | Fetch user profile |
| `/taxi-passenger/request-booking` | POST | New | Request a ride |
| `/taxi-passenger/cancel-request-booking-info` | POST | New | Cancel a booking |
| `/taxi-passenger/update-passenger-location` | POST | New | Update GPS position |
| `/taxi-passenger/get-driver-location-around` | POST | New | Nearby drivers |
| `/taxi-passenger/history-booking-info` | GET | New | Paginated history |
| `/taxi-passenger/announcements` | GET | New | Paginated announcements |
| `/taxi-passenger/announcement/{id}` | GET | New | Announcement detail |
| `/taxi-passenger/get-request-booking-info` | GET | Legacy | Check active booking |
| `/taxi/get-type-vehicle` | GET | Legacy | Vehicle types |
| `/taxi/get-current-app-version/2` | GET | Legacy | App version check |
| `/taxi-passenger/push-device-token` | POST | Legacy | Register FCM token |

### Third-Party APIs

| API | Package | Purpose |
|---|---|---|
| Google Places Autocomplete | `http` (raw) | Destination search (Cambodia-restricted) |
| Google Places Details | `http` (raw) | Place details (lat/lng) |
| Google Directions | `http` / `Dio` (ad-hoc) | Distance, duration, polyline |
| Telegram Bot | `http` (raw) | Error reporting + device token notifications |

### Socket.IO (Realtime)

File: `lib/services/socket_service.dart`

- **Connection:** `PassengerSocketService` (singleton) connects to `socketBaseUrl` on app init
- **Transport:** WebSocket only, auto-connect, infinite reconnection (2s→30s backoff, no attempt cap)
- **Events received:** `rideAccepted`, `driverArrival`, `driverStartDrive`, `driverDropDrive`, `driverAcceptPayment`, `onDriverCancel`
- **Events emitted:** `registerPassenger`, `rideRequest`, `rideRequestSpecificDriver`, `passengerCancelDrive`
- **Buffering:** Events emitted while disconnected are buffered and sent on reconnect (no dropped packets)
- **Navigation:** Socket events trigger route changes (e.g., `driverDropDrive` → CALCULATEFEE)

### Error Handling

| Layer | Approach | File |
|---|---|---|
| New client | `Result<T>` + `ApiException` (typed) | `core/network/` |
| Legacy client | Throws `DioErrorException` / `ServerResponseException` | `core/api_service/` |
| Global | FirebaseCrashlytics (disabled in debug) | `main.dart:33-39` |
| Error reporting | Telegram bot (optional) | `core/network_config/telegram.dart` |

---

## 5. Local Persistence

### Secure Storage

`FlutterSecureStorage` via `TokenStore` — stores auth token (key: `session_token`).

### SharedPreferences (Legacy)

Used for: auth JSON blob (legacy), language preference, registration status, phone number, FCM token, device info. Managed via helpers in `storages/` directory.

`SessionService` bridges both: reads from secure storage, falls back to SharedPreferences for one-time migration.

### No SQLite, Hive, or File Cache

The app does not use a local database or file-based cache. All data is fetched from the API.

---

## 6. Navigation

### Routing Architecture

**GetX named routes** via `GetMaterialApp` + `GetPage` definitions.

- **Single route file:** `lib/routes/app_pages.dart`
- **15 named routes** defined in `AppRoutes` (abstract class constants)
- **Route transitions:** `Transition.cupertino`, 500ms duration
- **Initial route:** `/splash`

### Route Parameters

Arguments are passed via `Get.arguments` (dynamic map/object). No type-safe route parameters.

### Authentication Guard

No formal middleware. Auth check is embedded in `SplashLogic._checkAuthorization()`:
- Reads token from `SessionService`
- Null → `Get.offAllNamed(AppRoutes.LOGIN)` (clears stack)
- Present → `Get.offAllNamed(AppRoutes.BOTTOMNAV)` (clears stack)

### 401 Redirect

Both API clients detect 401 responses and call `SessionService.handleUnauthorized()` → clears token → `Get.offAllNamed(AppRoutes.LOGIN)`.

### Bottom Navigation

`BottomNav` hosts 3 tabs (Home, History, Profile) via `BottomNavigationBar` + `Obx` page switching.

### Deep Links

**None.** No `uni_links`, `app_links`, or `firebase_dynamic_links`. Background/terminated entry is exclusively via FCM notification taps in `NotificationLogic.handleOnNotificationPress()`.

### Socket-Driven Navigation

`PassengerSocketService` navigates based on real-time events:
- `rideAccepted` / `driverArrival` / `driverStartDrive` → `AppRoutes.BOOKING`
- `driverDropDrive` → `AppRoutes.CALCULATEFEE`
- `onDriverCancel` → `AppRoutes.BOTTOMNAV`

### State-Based Redirect

`bookingRedirectRoute()` in `home/booking_redirect.dart` maps active booking status to the correct screen on app resume (called in `HomeLogic.onReady()`).
