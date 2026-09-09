import 'package:com.tara.passenger/core/utils/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-16 (docs/12). Before this, `AppLogic` compared the server's version
/// against a hardcoded `"1.0.15"` that had drifted five releases behind
/// `pubspec.yaml` (1.1.8). These pin the decision itself, including the
/// pre-existing release-date quirk, which is preserved deliberately.
void main() {
  group('shouldPromptUpdate', () {
    test('no prompt when the installed version matches the server', () {
      expect(
        shouldPromptUpdate(
          currentVersion: '1.1.8',
          serverVersion: '1.1.8',
          releaseDate: '2026-04-25',
          updateDate: '2026-09-01',
        ),
        isFalse,
      );
    });

    test('prompts when the installed version is behind the server', () {
      expect(
        shouldPromptUpdate(
          currentVersion: '1.1.8',
          serverVersion: '1.2.0',
          releaseDate: '2026-04-25',
          updateDate: '2026-09-01',
        ),
        isTrue,
      );
    });

    test('a matching release date suppresses the prompt even when the '
        'versions differ (pre-existing quirk, preserved)', () {
      expect(
        shouldPromptUpdate(
          currentVersion: '1.1.8',
          serverVersion: '1.2.0',
          releaseDate: '2026-09-01',
          updateDate: '2026-09-01',
        ),
        isFalse,
      );
    });

    test('the stale hardcoded 1.0.15 would have prompted against the real '
        'shipped version — the bug this replaces', () {
      expect(
        shouldPromptUpdate(
          currentVersion: '1.0.15',
          serverVersion: '1.1.8',
          releaseDate: '2026-04-25',
          updateDate: '2026-09-01',
        ),
        isTrue,
      );
    });
  });
}
