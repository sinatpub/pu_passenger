import 'package:com.tara.passenger/mock/mock_geo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Static mock data: places in Phnom Penh, the passenger account, the
/// driver, vehicle types, and the shape of every JSON payload the mock
/// backend returns. Payload shapes mirror what the app's models parse —
/// string vs number matters, because several call sites
/// `double.parse(x.toString())`.
class MockPlace {
  const MockPlace(this.name, this.latitude, this.longitude);
  final String name;
  final double latitude;
  final double longitude;
  LatLng get latLng => LatLng(latitude, longitude);
}

class MockPlaces {
  MockPlaces._();

  static const watPhnom =
      MockPlace('Wat Phnom, Daun Penh, Phnom Penh', 11.5763, 104.9231);
  static const centralMarket = MockPlace(
      'Central Market (Phsar Thmei), Daun Penh, Phnom Penh', 11.5696, 104.9210);
  static const airport = MockPlace(
      'Phnom Penh International Airport, Pou Senchey, Phnom Penh',
      11.5466,
      104.8441);
  static const independenceMonument = MockPlace(
      'Independence Monument, Chamkar Mon, Phnom Penh', 11.5564, 104.9282);
  static const russianMarket = MockPlace(
      'Russian Market (Phsar Toul Tom Poung), Chamkar Mon, Phnom Penh',
      11.5439,
      104.9181);
  static const aeonMall = MockPlace(
      'AEON Mall Phnom Penh, Tonle Bassac, Phnom Penh', 11.5486, 104.9332);
  static const royalPalace =
      MockPlace('Royal Palace, Sothearos Blvd, Phnom Penh', 11.5637, 104.9311);

  /// Where the mock passenger's GPS starts — and the pickup it books from.
  /// Mirrors pu_driver's central-market pickup so a passenger↔driver mock
  /// run on two emulators lines up without any coordinate juggling.
  static const MockPlace passengerStart = centralMarket;
  static const MockPlace destination = airport;

  static const all = [
    watPhnom,
    centralMarket,
    airport,
    independenceMonument,
    russianMarket,
    aeonMall,
    royalPalace,
  ];

  /// The name of a known place within [radiusMeters] of [point], if any.
  static String? nameNear(LatLng point, {double radiusMeters = 250}) {
    for (final place in all) {
      if (distanceMeters(point, place.latLng) <= radiusMeters) {
        return place.name;
      }
    }
    return null;
  }

  /// Central Market → airport along Russian Federation Boulevard — the same
  /// corridor pu_driver's mock car drives.
  static const List<LatLng> airportCorridor = [
    LatLng(11.5699, 104.9168),
    LatLng(11.5690, 104.9125),
    LatLng(11.5672, 104.9005),
    LatLng(11.5641, 104.8890),
    LatLng(11.5598, 104.8745),
    LatLng(11.5553, 104.8620),
    LatLng(11.5510, 104.8512),
    LatLng(11.5480, 104.8462),
  ];
}

/// The route the mock "Directions API" returns and the simulated GPS follows.
/// Deterministic, so the polyline on the map and the car on it always agree.
List<LatLng> mockRoute(LatLng from, LatLng to) {
  bool near(LatLng a, LatLng b) => distanceMeters(a, b) < 400;
  final List<LatLng> waypoints;
  if (near(from, MockPlaces.passengerStart.latLng) &&
      near(to, MockPlaces.destination.latLng)) {
    waypoints = [from, ...MockPlaces.airportCorridor, to];
  } else if (near(from, MockPlaces.destination.latLng) &&
      near(to, MockPlaces.passengerStart.latLng)) {
    waypoints = [from, ...MockPlaces.airportCorridor.reversed, to];
  } else {
    // An L-shaped, grid-like path: along one axis, then the other.
    waypoints = [from, LatLng(to.latitude, from.longitude), to];
  }
  return densify(waypoints);
}

class MockData {
  MockData._();

  static const String token = 'mock-token-qa-only';
  static const int passengerId = 5001;
  static const int driverId = 1024;

  static const String passengerName = 'Sreymom Chan';
  static const String passengerPhone = '098765432';
  static const String driverName = 'Dara Sok';

  /// Mock booking ids start here. The app parses ids and booking codes as
  /// integers, so a `MOCK-` prefix is impossible — a 99xxxx id is the tell.
  static const int firstBookingId = 990001;

  static const int vehicleTypeId = 2; // Classic car — see `typeVehicle()`.
  static const int pricePerKm = 1500; // riel
  static const int minimumFare = 6000; // riel

  /// The role_id the backend grants a passenger. `AppLogic.initSocket()`
  /// derives the socket identity from the legacy auth blob, not this, but
  /// the profile screen and the register payload carry it.
  static const int passengerRoleId = 3;

  static String timestamp(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${t.year}-${two(t.month)}-${two(t.day)} '
        '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }

  /// One shape for the logged-in user wherever the models read one: `/taxi/login`
  /// and `verify-phone-otp` (`UserResponseModel.User`), the booking payload's
  /// `passenger`, `get-profile`, and the legacy auth blob `initSocket()` reads.
  static Map<String, dynamic> user() => {
        'id': passengerId,
        'name': passengerName,
        'first_name': 'Sreymom',
        'last_name': 'Chan',
        'email': 'sreymom.chan@example.com',
        'gender': 2,
        'dob': '1996-08-03',
        'country_code': '+855',
        'phone': passengerPhone,
        'card_type': null,
        'card_number': null,
        'card_image': null,
        'status': 1,
        'status_date': '2025-11-02 14:10:00',
        'role_id': passengerRoleId,
        'profile_image': '',
        'last_location': null,
      };

  /// The legacy auth blob, stored verbatim under `jsonToken` — this is what
  /// `AppLogic.initSocket()` and the token bridge in `SessionService` read.
  static Map<String, dynamic> authPayload() => {
        'status': true,
        'message': 'Login successful',
        'data': {'token': token, 'user': user()},
      };

  static Map<String, dynamic> registerUser() => {
        'id': passengerId,
        'name': passengerName,
        'first_name': 'Sreymom',
        'last_name': 'Chan',
        'email': null,
        'dob': '1996-08-03',
        'country_code': '+855',
        'phone': passengerPhone,
        'card_type': null,
        'card_number': null,
        'card_image': null,
        'status': 1,
        'status_date': null,
        'role_id': passengerRoleId,
        'profile_image': null,
        'last_location': null,
      };

  static Map<String, dynamic> registerPayload() => {
        'status': true,
        'message': 'Register successful',
        'data': {'token': token, 'user': registerUser()},
      };

  static Map<String, dynamic> location(LatLng p) => {
        'latitude': p.latitude.toStringAsFixed(6),
        'longitude': p.longitude.toStringAsFixed(6),
      };

  static Map<String, dynamic> vehicle({int? typeVehicleId}) => {
        'id': 88,
        'type_vehicle_id': typeVehicleId ?? vehicleTypeId,
        'vehicle_price': pricePerKm,
        'model': 'Prius',
        'manufacturer': 'Toyota',
        'year_of_manufacture': 2016,
        'color': 'White',
        'plate_number': '2AB-1234',
        'engine_power': '1.8L Hybrid',
        'max_passenger': 4,
        'status': 1,
        'vehicle_image': <dynamic>[],
      };

  static Map<String, dynamic> driver({
    required LatLng position,
    int? id,
    int? typeVehicleId,
    double heading = 0,
  }) =>
      {
        'id': id ?? driverId,
        'name': driverName,
        'first_name': 'Dara',
        'last_name': 'Sok',
        'email': 'dara.sok@example.com',
        'gender': 1,
        'dob': '1990-05-12',
        'country_code': '+855',
        'phone': '012345678',
        'card_type': 1,
        'card_number': '010203040',
        'card_image': '',
        'driver_license_number': 'PP-123456',
        'driver_license_expired': '2029-12-31',
        'driver_license_image': '',
        'status': 1,
        'status_date': '2026-01-15 09:30:00',
        'profile_image': '',
        'role_id': 2,
        'vehicle': vehicle(typeVehicleId: typeVehicleId),
        'last_location':
            withHeading(location(position), heading: heading),
      };

  /// `lastLocation` in booking payloads carries a `heading` the booking map
  /// renders (`rotation:`), while the `get-profile` / history shapes do not.
  static Map<String, dynamic> withHeading(Map<String, dynamic> loc,
          {double heading = 0}) =>
      {...loc, 'heading': heading};

  static List<Map<String, dynamic>> vehicleTypes() {
    const created = '2025-01-01T00:00:00.000000Z';
    Map<String, dynamic> type(int id, String name, int price, int minimum) =>
        {
          'id': id,
          'name': name,
          'price': price,
          'minimum_fare': minimum,
          'image': null,
          'order_key': id,
          'created_at': created,
          'updated_at': created,
        };
    return [
      type(1, 'Rickshaw', 1000, 4000),
      type(2, 'Classic Car', pricePerKm, minimumFare),
      type(3, 'Mini Van', 2000, 8000),
      type(4, 'SUV', 2500, 10000),
      type(5, 'Alphard VIP', 5000, 20000),
    ];
  }

  /// Same three items pu_driver's mock serves, reworded for the passenger.
  /// `release_date`/`created_at` are parseable ISO-ish dates the announcement
  /// model's `DateTime.parse` accepts.
  static List<Map<String, dynamic>> announcements() {
    Map<String, dynamic> item(
            int id, String title, String description, String date) =>
        {
          'id': id,
          'title': title,
          'description': description,
          'release_date': date,
          'expired_date': '2026-12-31',
          'target': 3,
          'status': 1,
          'created_by': 1,
          'created_at': '$date 08:00:00',
          'updated_at': '$date 08:00:00',
          'files': <dynamic>[],
        };
    return [
      item(
          3,
          'Pchum Ben holiday bonus',
          'Complete 20 trips between 20 and 24 September and earn a 30,000 riel travel credit.',
          '2026-09-15'),
      item(
          2,
          'Airport pickup zone has moved',
          'Pickups at Phnom Penh International Airport now use the new ride-hailing bay at Gate B.',
          '2026-09-02'),
      item(
          1,
          'App update 1.1.9',
          'This version improves GPS accuracy during trips and fixes a crash when collecting payment.',
          '2026-04-25'),
    ];
  }

  /// Matches the app's pinned `release_date` (see `AppLogic`), so
  /// `shouldPromptUpdate` stays quiet: only the version has to match for
  /// that, but keeping the dates pinned too survives the version check
  /// changing shape later.
  static Map<String, dynamic> version() => {
        'message': 'Success',
        'status': true,
        'data': {
          'id': 1,
          'app_type': 1,
          'release_date': '2026-04-25',
          'release_date_ios': '2026-04-25',
          'version_android': '1.1.9',
          'version_ios': '1.1.9',
          'play_store_link': '',
          'app_store_link': '',
          'features_release': '',
          'is_active': 1,
        },
      };
}