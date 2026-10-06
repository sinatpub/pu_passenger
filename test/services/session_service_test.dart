import 'dart:convert';

import 'package:com.tara.passenger/core/storage/token_store.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A sign-in response, as it is stored: the user and the token.
String _record(String? token, {int userId = 3}) => jsonEncode({
      'data': {
        'user': {'id': userId, 'name': 'Test Passenger'},
        'token': token,
      },
      'status': true,
      'message': 'success',
    });

void main() {
  /// The two stores as an install has them at launch. [record] is the sign-in
  /// record in `SharedPreferences`, [secureToken] the token in secure storage.
  void install({String? record, String? secureToken}) {
    SharedPreferences.setMockInitialValues({
      if (record != null) 'jsonToken': record,
    });
    FlutterSecureStorage.setMockInitialValues({
      if (secureToken != null) 'session_token': secureToken,
    });
  }

  /// A cold start: nothing in memory.
  SessionService launch() => SessionService.forTesting();

  Future<String?> secureToken() => TokenStore().read();

  Future<String?> recordedToken() async =>
      (await GetStoragePref().getJsonToken).data?.token;

  group('signing in', () {
    test('keeps the token and the record together', () async {
      install();
      final session = launch();

      await session.startSession(token: 'new', signInRecord: _record('new'));

      expect(await session.getToken(), 'new');
      expect(await secureToken(), 'new');
      expect(await recordedToken(), 'new');
      expect(await launch().getToken(), 'new', reason: 'after a restart');
    });

    test('replaces the token that was there', () async {
      // Signing in used to write the record only. The old token stayed in
      // secure storage, was read first, and went out on every request.
      install(record: _record('old'), secureToken: 'old');
      final session = launch();
      expect(await session.getToken(), 'old');

      await session.startSession(token: 'new', signInRecord: _record('new'));

      expect(await session.getToken(), 'new');
      expect(await launch().getToken(), 'new');
    });

    test('a sign-in without a token leaves none behind', () async {
      install(record: _record('old'), secureToken: 'old');
      final session = launch();

      await session.startSession(token: null, signInRecord: _record(null));

      expect(await session.getToken(), isNull);
      expect(await secureToken(), isNull);
    });
  });

  group('ending the session', () {
    test('removes the token and the record', () async {
      // Logging out used to remove the record only, so the next launch still
      // had a token and opened Home as the account that had just left.
      install(record: _record('mine'), secureToken: 'mine');
      final session = launch();
      await session.getToken();

      await session.clear();

      expect(await session.getToken(), isNull);
      expect(await secureToken(), isNull);
      expect(await recordedToken(), isNull);
      expect(await launch().getToken(), isNull, reason: 'after a restart');
    });

    test('a refused token does not come back', () async {
      // A 401 used to clear the token only. The next request read the same
      // dead token out of the record and stored it again, and every launch
      // ended on the login page. Seen 2026-10-06 with the mock build's token.
      install(
        record: _record('mock-token-qa-only'),
        secureToken: 'mock-token-qa-only',
      );
      final session = launch();
      expect(await session.getToken(), 'mock-token-qa-only');

      await session.clear(); // what `handleUnauthorized` does first
      expect(await session.getToken(), isNull);
      expect(await session.getToken(), isNull, reason: 'a later request');

      await session.startSession(token: 'real', signInRecord: _record('real'));
      expect(await session.getToken(), 'real');
      expect(await launch().getToken(), 'real');
    });

    test('tells whoever opened something for that user', () async {
      install(record: _record('mine'), secureToken: 'mine');
      final session = launch();
      var ended = 0;
      session.onSessionEnded = () => ended++;

      await session.clear();

      expect(ended, 1);
    });
  });

  group('an install whose two stores disagree', () {
    test('a newer record wins over the stored token', () async {
      // Left by a sign-in made before the stores were written together.
      install(record: _record('new'), secureToken: 'dead');

      expect(await launch().getToken(), 'new');
      expect(await secureToken(), 'new', reason: 'repaired, not just read');
    });

    test('a token with no record is a signed-out install', () async {
      // Left by a logout made before it removed the token as well.
      install(secureToken: 'left-behind');

      expect(await launch().getToken(), isNull);
      expect(await secureToken(), isNull);
    });

    test('a record with no stored token signs in from the record', () async {
      install(record: _record('mine'));

      expect(await launch().getToken(), 'mine');
      expect(await secureToken(), 'mine');
    });

    test('a record that cannot be read does not sign anyone out', () async {
      install(record: '{not json', secureToken: 'mine');

      expect(await launch().getToken(), 'mine');
      expect(await secureToken(), 'mine');
    });

    test('nothing stored is nobody signed in', () async {
      install();

      expect(await launch().getToken(), isNull);
    });
  });
}
