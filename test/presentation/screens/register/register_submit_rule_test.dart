import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/presentation/screens/register/state.dart';
import 'package:com.tara.passenger/presentation/screens/register/view.dart';

/// Pins the register submit rule (roadmap S4 Scope / Risk).
///
/// `03 §Screen 4` says the photo is optional, enables Create at ≥2 characters
/// and adds a Skip button. The code requires a non-empty name **and** a photo,
/// and has no Skip. The roadmap is explicit that the code wins, so these tests
/// lock the code's rule in — a later "fix" toward the spec has to break them
/// deliberately.
void main() {
  RegisterState stateWith({String name = '', File? image}) =>
      RegisterState()
        ..passengerName = name
        ..profileImage = image;

  // A path is enough: the rule only checks for null, it never reads the file.
  final photo = File('/tmp/does-not-need-to-exist.png');

  group('canSubmitRegistration', () {
    test('a name and a photo enables submit', () {
      expect(canSubmitRegistration(stateWith(name: 'Mey Lin', image: photo)),
          isTrue);
    });

    test('a name with no photo does NOT enable submit', () {
      // The spec calls the photo optional. The code does not.
      expect(canSubmitRegistration(stateWith(name: 'Mey Lin')), isFalse);
    });

    test('a photo with no name does not enable submit', () {
      expect(canSubmitRegistration(stateWith(image: photo)), isFalse);
    });

    test('neither enables submit', () {
      expect(canSubmitRegistration(stateWith()), isFalse);
    });

    test('a single character is enough — the rule is non-empty, not >= 2', () {
      // The spec says "enable button if >= 2 chars"; the code says `!= ''`.
      expect(canSubmitRegistration(stateWith(name: 'A', image: photo)), isTrue);
    });

    test('whitespace counts as a name, because the check is != empty', () {
      // Pinned as-is. Trimming here would change who can submit.
      expect(canSubmitRegistration(stateWith(name: ' ', image: photo)), isTrue);
    });
  });
}
