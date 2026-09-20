/// Every delay the mock backend uses, in one place. Edit these to change the
/// pace of the simulation; the dev panel's speed multiplier (1x/2x/5x/10x)
/// divides all of them except [requestTimeoutSeconds].
///
/// Trip time is compressed on purpose: a ~10 km ride plays out in under a
/// minute at 1x. The *receipt* still reports a realistic city duration
/// (see [assumedCitySpeedKmh]) so copy and layout are tested with real-world
/// values, not "0 m 45 s".
class MockTimings {
  MockTimings._();

  // ---- Network latency (so spinners, disabled buttons and skeletons show) --
  static const Duration latency = Duration(milliseconds: 700);
  static const Duration authLatency = Duration(milliseconds: 1200);
  static const Duration tripActionLatency = Duration(milliseconds: 1000);
  static const Duration paymentLatency = Duration(milliseconds: 1500);

  /// Latency never drops below this, even at 10x, so loading states are
  /// still visible for at least a frame or two.
  static const Duration minLatency = Duration(milliseconds: 150);

  // ---- Server-side simulation ---------------------------------------------
  /// Passenger books → the simulated driver accepts.
  static const Duration driverAcceptsAfterRequest = Duration(seconds: 6);

  /// Accepted → the simulated driver reaches the pickup (GPS travel time).
  static const Duration driveToPickup = Duration(seconds: 20);

  /// Arrived at the pickup → the simulated driver starts the trip.
  static const Duration waitAtPickup = Duration(seconds: 4);

  /// Trip started → the simulated driver reaches the destination.
  static const Duration tripInProgress = Duration(seconds: 45);

  /// `DRIVER_CANCELLED`: accepted → the simulated driver cancels.
  static const Duration driverCancelsAfterAccept = Duration(seconds: 8);

  /// Drop-off done → the simulated driver collects payment.
  static const Duration paymentDelay = Duration(seconds: 5);

  /// How long a request-booking response says the driver has to accept
  /// (`timeout_param`), in seconds. Not a delay in the sim.
  static const int requestTimeoutSeconds = 30;

  // ---- Not scaled by simulation speed -------------------------------------
  /// How often the simulated GPS ticks in `MockLocationSource`.
  static const Duration gpsTick = Duration(milliseconds: 300);

  /// How long a *paid* booking stays resolvable via
  /// `get-request-booking-info` after `driverAcceptPayment`. The app reads
  /// it once, ~2s after the socket event, so the rating screen can key on
  /// the booking id; after this window the ride is gone and the journey
  /// jumps straight home. Kept unscaled so 10x cannot starve that fetch.
  static const Duration paymentFinalizeDelay = Duration(seconds: 6);

  /// `get-request-booking-info` for a booking nobody has accepted yet. The
  /// request countdown the server honours.
  static const Duration unansweredRequestLifetime =
      Duration(seconds: requestTimeoutSeconds + 2);

  /// Used for the realistic trip duration on the receipt and in history.
  static const double assumedCitySpeedKmh = 22;
}