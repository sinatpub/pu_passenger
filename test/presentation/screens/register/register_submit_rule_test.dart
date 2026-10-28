import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/presentation/screens/register/state.dart';
import 'package:com.tara.passenger/presentation/screens/register/view.dart';

/// The register submit rule: a name is enough, the photo is optional (D42).
///
/// Until 2026-10-13 the code also wanted a photo, and these tests pinned that
/// against `03 §Screen 4`, which called the photo optional. The product owner
/// then decided for the spec on that point. The other two differences from
/// the spec are still pinned here: one character is a name, and there is no
/// Skip button.
void main() {
  RegisterState stateWith({String name = '', File? image}) =>
      RegisterState()
        ..passengerName = name
        ..profileImage = image;

  // A path is enough: the rule never reads the file.
  final photo = File('/tmp/does-not-need-to-exist.png');

  group('canSubmitRegistration', () {
    test('a name with no photo enables submit', () {
      expect(canSubmitRegistration(stateWith(name: 'Mey Lin')), isTrue);
    });

    test('a name and a photo enables submit', () {
      expect(canSubmitRegistration(stateWith(name: 'Mey Lin', image: photo)),
          isTrue);
    });

    test('a photo with no name does not enable submit', () {
      expect(canSubmitRegistration(stateWith(image: photo)), isFalse);
    });

    test('neither enables submit', () {
      expect(canSubmitRegistration(stateWith()), isFalse);
    });

    test('a single character is enough — the rule is non-empty, not >= 2', () {
      // The spec says "enable button if >= 2 chars"; the code says `!= ''`.
      expect(canSubmitRegistration(stateWith(name: 'A')), isTrue);
    });

    test('whitespace counts as a name, because the check is != empty', () {
      // Pinned as-is. Trimming here would change who can submit.
      expect(canSubmitRegistration(stateWith(name: ' ')), isTrue);
    });
  });
}
