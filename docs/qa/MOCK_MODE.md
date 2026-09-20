# QA Mock / Demo Mode (passenger app)

A fake backend that lets the **whole passenger flow** run with no API, no
socket server and no GPS, so the existing UI can be tested and polished while
the backend is unavailable. No screen was changed to support it, and the real
API code is untouched and still the default.

## Turn it on / off

```sh
# on — debug (or profile) build only
fvm flutter run --dart-define-from-file=dart_defines.json --dart-define=USE_MOCK_DATA=true

# optional: start in a scenario and/or at a speed
fvm flutter run --dart-define-from-file=dart_defines.json \
  --dart-define=USE_MOCK_DATA=true \
  --dart-define=MOCK_SCENARIO=DRIVER_CANCELLED \
  --dart-define=MOCK_SPEED=5

# off — just leave USE_MOCK_DATA out (the normal command)
fvm flutter run --dart-define-from-file=dart_defines.json
```

A red **MOCK** tab on the left edge of every screen shows mock mode is on.
Tap it to open the developer controls.

**It can't reach production.** `MockMode.enabled` is the compile-time constant
`USE_MOCK_DATA && !kReleaseMode`. In a `--release` build it is `false` even if
the define is passed, every mock branch is dead code, and the mock layer is
tree-shaken out. `USE_MOCK_DATA` is deliberately not in
`dart_defines.example.json`, for the same reason `DEBUG_OTP_BYPASS` isn't.

Inside a mock build, **Use mock backend** in the panel turns mock mode off at
runtime (after restarting the app), so one install can talk to either backend.

## Developer controls (MOCK tab)

| Control | Values | Effect |
|---|---|---|
| Book a ride | buttons on the map screen | The real request button; in mock mode the sim answers it |
| Driver accepts | button | Accepts the current request right now (auto sends it ~1 s later anyway) |
| Driver cancels | button | Pushes `onDriverCancelDrive` for the current ride |
| Reset trip | button | Drops the current ride; keeps history |
| Reset all mock data | button | No ride, re-seeded history; passenger back at the pickup spot |
| Scenario | see below | Backend behaviour |
| Simulation speed | 1x · 2x · 5x · 10x | Divides every delay in `MockTimings` |
| Ride requests | Auto · Manual | Auto: a request is accepted a few seconds after booking |
| Passenger pays with | Cash · Wallet · Card | `payment_method` on the receipt and in history |
| Use mock backend | on/off | Runtime kill switch, applies after restart |

Settings persist across restarts. A `MOCK_SCENARIO` / `MOCK_SPEED` define
wins over the saved value at launch.

## Scenarios

| `MOCK_SCENARIO` | What happens | Driver-app equivalent |
|---|---|---|
| `NORMAL_FLOW` | Everything succeeds | NORMAL_FLOW |
| `BOOKING_FAILED` | Request → 2xx "can't confirm"; the map shows its retry toast | BOOKING_FAILED |
| `NO_DRIVER_AVAILABLE` | Request creates a booking, but no driver ever accepts; the overlay's countdown runs out | (driver-side: the request never arrives) |
| `DRIVER_CANCELLED` | Accept → `onDriverCancelDrive` a few seconds later; the passenger's cancel dialog and return home | PASSENGER_CANCELLED |
| `NETWORK_ERROR` | Every request fails as a dropped connection | NETWORK_ERROR |
| `SESSION_EXPIRED` | Every authenticated request → 401 → signed out | (extra) |
| `LOCATION_ERROR` | GPS never returns a fix → the app's location error state | LOCATION_ERROR |

Also available regardless of scenario:
- OTP **`9999`** is rejected (wrong-code dialog). Any other code signs in as
  **Sreymom Chan**.
- The seeded history always contains a couple of completed and cancelled
  rides (ids `980001+`), so the History tab reads as "lived-in".

## The flow and its timings

All delays live in **`lib/mock/mock_timings.dart`**, and the speed setting
divides them.

```
Splash → Login (any phone) → OTP (any code but 9999)        auth latency 1.2 s
Map — pick pickup, tap "Book", choose a vehicle type
  → Request confirmed (30 s driver-overlay countdown)
     ↓ driverAcceptsAfterRequest      1 s
  → driverAccepted → Booking screen (car drives Wat Phnom → pickup)
     ↓ driveToPickup                 20 s
  → driverArrival
  → driverStartDrive → trip screen (car drives pickup → Airport, ≈10 km)
     ↓ tripInProgress                45 s
  → driverDropDrive → Fee screen (receipt: distance, duration, fare, method)
     50 s later the booking resolves and lands in History as completed
  → driverAcceptPayment → Rating → Receipt → Home
```

The passenger picks up, taps Pay, rates and reads the receipt — those taps
*are* the UI under test. What runs on its own is everything the server, the
driver and GPS would do.

Trip time is compressed. The receipt reports the realistic duration for the
distance at 22 km/h, not the ~45 s it took in the simulator. The route
follows Russian Federation Blvd from the pickup to the airport.

**Mock data is easy to spot:** ride ids start at `990001` (the app parses
them as integers, so a `MOCK-` prefix isn't possible). The seeded history
uses `980001+`, and the token is `mock-token-qa-only`.

## Persistence (kill and relaunch)

The mock backend saves its state to SharedPreferences after every change
(ride, its phase timestamps, payment method and history). Relaunching the app
goes through the app's **real** resume path: `get-request-booking-info`
returns the ride, and the app redirects into the booking/trip screen at the
right stage. The simulated car position is recomputed from the phase
timestamps, so it has moved on while the app was closed. A request that was
never accepted is dropped on relaunch, as the server would have expired it.
The unresolved request keeps the driver overlay's expiry timer (the app's own
`timeout_param`).

## Architecture

```
Screens / controllers / repositories / datasources / models   ← unchanged
        │                    │                 │              │
   BaseHttpClient.dio   SocketService   LocationService   GoogleMapLogic
        │                    │                 │              │
  MockHttpInterceptor   mock event stream  MockLocationSource mockRoute
        └────────────── MockBackend (lib/mock/mock_backend.dart) ─┘
```

- **REST**: `MockHttpInterceptor` on the shared Dio client answers from
  `MockBackend`. Both HTTP stacks (`ApiClient`, legacy `BaseApiService`) use
  that client, so every model parses mock JSON exactly as it parses the real
  API. Errors are real `DioException`s (connection / bad response), so the
  app's own error mapping runs.
- **Socket**: in mock mode `SocketService` subscribes to
  `MockBackend.socketEvents` instead of opening Socket.IO, dispatching into
  the same handlers: `rideAccepted`/`driverArrival`/`driverStartDrive` →
  booking screen / refresh, `driverDropDrive` → Fee screen, `driverAcceptPayment`
  → Fee → Rating → Receipt → Home, `onDriverCancelDrive` → cancel dialog and
  home. Outgoing emits are logged, not sent.
- **GPS**: `LocationService.source` is a `PositionSource`. Normally it's
  `GeolocatorPositionSource`; the mock source reports the passenger's own
  parked position, or no fix when the `LOCATION_ERROR` scenario is on.
- **Directions / polylines**: `GoogleMapLogic.drawPolyline` (and the map
  screen's) return the same route the simulated car drives.
- **Addresses / places**: known mock landmarks resolve to fixed names and
  place searches; anything else falls through to the platform geocoder.
- **Map**: still the real Google Map (needs `GOOGLE_MAPS_API_KEY` for tiles).
  Only its data is mocked.

To remove mock mode entirely: delete `lib/mock/`, `test/mock/` and this file.
Then drop the `MockMode` lines from `main.dart`, `app/root_main.dart`,
`core/api_service/client/dio_http_client.dart`,
`services/socket_service.dart`, `services/location_service.dart`,
`service/location_imp.dart`, `data/datasources/places_api.dart`,
`app/google_map_logic.dart` and
`presentation/screens/map_screen/logic.dart`.
The `PositionSource` seam is ordinary code and can stay.

## Known limits

- **Not simulated because the passenger app has no such screen or data:**
  driver-side steps (accepting, navigating to pickup, starting the trip),
  tips, driver rating from the driver side, and a remaining-distance or ETA
  readout during the trip.
- **Registration** (`/register`) returns a signed-in passenger. Because mock
  OTP never reports a new user, the register screen is only reachable by
  navigating to it directly.
- **Push notifications (FCM)** are not mocked. Ride events come through the
  socket path, which is what the app uses while in the foreground.
- **App update prompt** is not simulated (the version endpoint matches the
  build).
- **Telegram error reporting** still calls Telegram if its token is set.
- **Map tiles** need a valid Google Maps key and a network connection.