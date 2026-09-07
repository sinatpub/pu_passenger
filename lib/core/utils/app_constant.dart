enum ClientMethod { POST, GET, PATCH, DELETE }

class AppConstant {
  static const String khmerCode = "km";
  static const String englishCode = 'en';

  static const timeoutBooking = 60;
  static const double initZoomLevel = 17.0;

  static const String titleApp = 'TAARRAA';

  // Based Url — overridable via `--dart-define=API_BASE_URL=...`
  // (F-07, docs/12); default points at the current passenger backend.
  static const baseUrlApi = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://taxi-api.simpledevelopertools.com',
  );

  // Socket IO Client — overridable via `--dart-define=SOCKET_BASE_URL=...`.
  // Same host as the REST API on this backend: the Socket.IO server is
  // mounted at `/socket.io/` on `baseUrlApi` rather than on a separate
  // host as the old `socket.tara-taxi.com` deployment was (docs/04 §1.1).
  static const socketBasedUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'https://taxi-api.simpledevelopertools.com',
  );

  // Socket Event Client

  static const driverConnect = "driver_connect";

  // Custom Token
  static const String userToken = '';
  static String? driverToken;

  // Supplied via `--dart-define-from-file=dart_defines.json`
  static const googleKeyApi = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
  static const placeApiKey = String.fromEnvironment('GOOGLE_PLACES_API_KEY');

  // Marker
  static const passengerMarker = "PassengerMarker";
  static const driverMarker = "DriverMarker";

  // * Socket Event

  static const String rideBooking = "rideRequest";

  // Padding Constant
  static const double padding01 = 6.0;
  static const double padding02 = 8.0;
  static const double padding03 = 12.0;
  static const double padding04 = 16.0;
  static const double padding05 = 18.0;
  static const double padding06 = 20.0;

  // Margin Constant
  static const double margin01 = 6.0;
  static const double margin02 = 8.0;
  static const double margin03 = 12.0;
  static const double margin04 = 16.0;
  static const double margin05 = 18.0;
  static const double margin06 = 20.0;

  static const rideAccepted = 2;
  static const rideArrived = 8;
  // OnGoing Status
  static const rideStartRide = 3;
  static const ridePendingPayment = 6;
}
