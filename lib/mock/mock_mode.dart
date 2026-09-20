/// QA Mock/Demo Mode — the switch, and the runtime settings QA can change.
///
/// Mock mode replaces the backend, not the app: every screen, controller,
/// repository, datasource and model runs exactly as it does against the real
/// API. The fake backend sits underneath them at the transport boundaries —
/// the shared Dio client (REST), the passenger socket (push events), the GPS
/// and the Google Directions calls — so nothing above those boundaries knows
/// which one it is talking to. See `docs/qa/MOCK_MODE.md`.
///
/// ## Why it cannot reach a production build
///
/// [MockMode.enabled] is a compile-time constant that needs **both**
/// `--dart-define=USE_MOCK_DATA=true` **and** a non-release build
/// (`kReleaseMode == false`). In a release build it folds to `false`, every
/// `if (MockMode.enabled)` branch is dead code, and the mock layer is
/// tree-shaken out of the binary. A developer who leaves the define in a
/// release command still gets the real backend.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_backend.dart';
import 'mock_location_source.dart';
import '../services/location_service.dart';

/// Which backend behaviour to simulate. Passenger-flow equivalents of the
/// scenarios QA drives in pu_driver — see `docs/qa/MOCK_MODE.md`.
enum MockScenario {
  /// Every call succeeds; a driver accepts, arrives, drives and pays.
  normalFlow('NORMAL_FLOW', 'Normal flow'),

  /// Booking succeeds, but no driver ever accepts it. The passenger can
  /// cancel out of the waiting overlay.
  noDriverAvailable('NO_DRIVER_AVAILABLE', 'No driver available'),

  /// `request-booking` returns a 2xx with no booking — the "can't confirm"
  /// error. `MapLogic` shows its retry toast and drops the overlay.
  bookingFailed('BOOKING_FAILED', 'Booking failed'),

  /// A driver accepts, then cancels over the socket while en route to the
  /// pickup.
  driverCancelled('DRIVER_CANCELLED', 'Driver cancels'),

  /// Every request fails as if the phone had no connection.
  networkError('NETWORK_ERROR', 'Network error'),

  /// Every authenticated request returns 401, which signs the passenger out.
  sessionExpired('SESSION_EXPIRED', 'Session expired'),

  /// GPS never produces a fix and geocoding finds nothing.
  locationError('LOCATION_ERROR', 'Location error');

  const MockScenario(this.wireName, this.label);

  /// The `MOCK_SCENARIO` dart-define spelling.
  final String wireName;
  final String label;

  static MockScenario? parse(String? value) {
    for (final s in values) {
      if (s.wireName == value || s.name == value) return s;
    }
    // Pre-doc spelling of `NO_DRIVER_AVAILABLE`, kept so QA scripts written
    // against the first build of the mock layer keep working.
    if (value == 'NO_DRIVER') return MockScenario.noDriverAvailable;
    return null;
  }
}

/// Whether the simulated driver accepts on its own or only when the dev panel
/// says so.
enum MockDispatch { auto, manual }

/// The payment method the simulated driver collects with. The passenger app
/// only displays it on the receipt and in history.
enum MockPaymentMethod {
  cash('Cash'),
  wallet('Wallet'),
  card('Card');

  const MockPaymentMethod(this.label);
  final String label;
}

const List<double> mockSpeeds = [1, 2, 5, 10];

@immutable
class MockSettings {
  const MockSettings({
    this.useMock = true,
    this.scenario = MockScenario.normalFlow,
    this.speed = 1,
    this.dispatch = MockDispatch.auto,
    this.paymentMethod = MockPaymentMethod.cash,
  });

  /// Runtime kill switch inside a mock-capable build. Read once at launch —
  /// changing it takes effect after the app restarts.
  final bool useMock;
  final MockScenario scenario;

  /// Simulation speed multiplier: every delay in `MockTimings` is divided by
  /// this.
  final double speed;
  final MockDispatch dispatch;
  final MockPaymentMethod paymentMethod;

  MockSettings copyWith({
    bool? useMock,
    MockScenario? scenario,
    double? speed,
    MockDispatch? dispatch,
    MockPaymentMethod? paymentMethod,
  }) =>
      MockSettings(
        useMock: useMock ?? this.useMock,
        scenario: scenario ?? this.scenario,
        speed: speed ?? this.speed,
        dispatch: dispatch ?? this.dispatch,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
}

class MockMode {
  MockMode._();

  static const bool _requested = bool.fromEnvironment('USE_MOCK_DATA');
  static const String _scenarioDefine = String.fromEnvironment('MOCK_SCENARIO');
  static const String _speedDefine = String.fromEnvironment('MOCK_SPEED');

  /// Compile-time: can this build use the mock backend at all? Must stay a
  /// `const` expression over `kReleaseMode` so release builds shake it out.
  static const bool enabled = _requested && !kReleaseMode;

  static const _prefix = 'qa_mock.';

  static MockSettings _settings = const MockSettings();
  static bool _activeThisLaunch = false;

  /// Is the mock backend serving this run of the app?
  static bool get isActive => enabled && _activeThisLaunch;

  static MockSettings get settings => _settings;

  /// Fires whenever the dev panel changes a setting.
  static final ValueNotifier<MockSettings> changes =
      ValueNotifier<MockSettings>(_settings);

  /// Loads persisted settings, applies `MOCK_SCENARIO` / `MOCK_SPEED` if the
  /// build passed them, and restores the mock backend's saved trip. A no-op
  /// outside a mock-capable build.
  static Future<void> init() async {
    if (!enabled) return;
    final prefs = await SharedPreferences.getInstance();
    var loaded = MockSettings(
      useMock: prefs.getBool('${_prefix}useMock') ?? true,
      scenario: MockScenario.parse(prefs.getString('${_prefix}scenario')) ??
          MockScenario.normalFlow,
      speed: prefs.getDouble('${_prefix}speed') ?? 1,
      dispatch:
          _byName(MockDispatch.values, prefs.getString('${_prefix}dispatch')) ??
              MockDispatch.auto,
      paymentMethod: _byName(MockPaymentMethod.values,
              prefs.getString('${_prefix}paymentMethod')) ??
          MockPaymentMethod.cash,
    );
    // A define passed on the command line wins over what the panel saved, so
    // `flutter run --dart-define=MOCK_SCENARIO=BOOKING_FAILED` does what it
    // says.
    final defineScenario = MockScenario.parse(_scenarioDefine);
    if (defineScenario != null) {
      loaded = loaded.copyWith(scenario: defineScenario);
    }
    final defineSpeed = double.tryParse(_speedDefine);
    if (defineSpeed != null && defineSpeed > 0) {
      loaded = loaded.copyWith(speed: defineSpeed);
    }

    _settings = loaded;
    changes.value = loaded;
    _activeThisLaunch = loaded.useMock;
    if (isActive) {
      debugPrint('[MockMode] ACTIVE — scenario=${loaded.scenario.wireName} '
          'speed=${loaded.speed}x. No request reaches the real backend.');
      LocationService.instance.source = MockLocationSource.instance;
      await MockBackend.instance.restore();
    }
  }

  static Future<void> update(MockSettings next) async {
    if (!enabled) return;
    _settings = next;
    changes.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}useMock', next.useMock);
    await prefs.setString('${_prefix}scenario', next.scenario.wireName);
    await prefs.setDouble('${_prefix}speed', next.speed);
    await prefs.setString('${_prefix}dispatch', next.dispatch.name);
    await prefs.setString('${_prefix}paymentMethod', next.paymentMethod.name);
    if (isActive) MockBackend.instance.onSettingsChanged();
  }

  /// [duration] at the current simulation speed.
  static Duration scaled(Duration duration) => Duration(
      microseconds: (duration.inMicroseconds / _settings.speed).round());

  static T? _byName<T extends Enum>(List<T> values, String? name) {
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}