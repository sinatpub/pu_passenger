import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/core/utils/initials.dart';

void main() {
  group('initialsFromName (C5 driver card / component spec §12)', () {
    test('takes the first letter of the first two words', () {
      expect(initialsFromName('Sok Dara'), 'SD');
    });

    test('ignores words past the second', () {
      expect(initialsFromName('Chan Sok Dara'), 'CS');
    });

    test('uppercases a lowercase name', () {
      expect(initialsFromName('sok dara'), 'SD');
    });

    test('a single word gives a single initial', () {
      expect(initialsFromName('Dara'), 'D');
    });

    test('collapses runs of whitespace rather than emitting blanks', () {
      expect(initialsFromName('  Sok   Dara  '), 'SD');
    });

    test('splits on grapheme clusters, so a Khmer name keeps its marks', () {
      // Each initial is a whole cluster — 'ស' + the vowel sign 'ុ', and 'ដ' +
      // 'ា'. A naive `word[0]` would slice inside the cluster and drop the
      // mark, rendering a different letter.
      expect(initialsFromName('សុខ ដារា'), 'សុដា');
    });

    test('a null name gives an empty string, never "null"', () {
      expect(initialsFromName(null), '');
    });

    test('a blank name gives an empty string', () {
      expect(initialsFromName('   '), '');
    });
  });
}
