import 'package:com.tara.passenger/data/datasources/device_info_repo.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingDeviceInfoRepo extends DeviceInfoRepo {
  int registrations = 0;
  bool fails = false;

  @override
  Future<bool> deviceCreateOrUpdate() async {
    registrations++;
    if (fails) throw Exception('offline');
    return true;
  }
}

class _TokenlessDeviceInfoRepo extends DeviceInfoRepo {
  _TokenlessDeviceInfoRepo(this.token);

  final String? token;

  @override
  getFCMToken() async => token;
}

void main() {
  late _CountingDeviceInfoRepo repo;
  late HomeLogic logic;

  setUp(() {
    repo = _CountingDeviceInfoRepo();
    logic = HomeLogic(deviceInfoRepo: repo);
  });

  group('HomeLogic.pushFcmToken', () {
    test('registers the device on a phone that has no token stored', () async {
      SharedPreferences.setMockInitialValues({});

      await logic.pushFcmToken();

      expect(repo.registrations, 1);
    });

    test('registers again when a token is already stored', () async {
      // The server keeps the token per account. A token stored by an earlier
      // sign-in on this phone says nothing about the account signed in now.
      SharedPreferences.setMockInitialValues({'fcmTokenData': 'stored-token'});

      await logic.pushFcmToken();

      expect(repo.registrations, 1);
    });

    test('a failed registration does not stop Home from starting', () async {
      SharedPreferences.setMockInitialValues({});
      repo.fails = true;

      await expectLater(logic.pushFcmToken(), completes);
    });
  });

  group('DeviceInfoRepo.deviceCreateOrUpdate', () {
    // iOS answers null until APNs has given the app a token, and a failed
    // read answers an empty one.
    for (final String? token in [null, '']) {
      test(
          'registers nothing when the token is ${token == null ? 'null' : 'empty'}',
          () async {
        SharedPreferences.setMockInitialValues({});

        final registered =
            await _TokenlessDeviceInfoRepo(token).deviceCreateOrUpdate();

        expect(registered, isFalse);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getString('fcmTokenData'), isNull);
      });
    }
  });
}
