import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/translations/english_key.dart';
import 'package:com.tara.passenger/translations/khmer_key.dart';

/// P2 — the EN and KM maps must stay keyed identically.
///
/// These are Dart maps, not JSON, so nothing structural stops a key being
/// added to one and forgotten in the other. GetX then falls back to returning
/// the key itself — and because this codebase uses the **English string as the
/// key**, a missing Khmer entry renders as English rather than failing, which
/// is exactly the silent bug the roadmap's P2 Risk describes.
void main() {
  final en = englishKey as Map;
  final km = khmerKey as Map;

  group('EN/KM key parity (P2 Done When)', () {
    test('both maps have the same key set', () {
      final enKeys = en.keys.map((k) => k.toString()).toSet();
      final kmKeys = km.keys.map((k) => k.toString()).toSet();

      final missingFromKm = enKeys.difference(kmKeys).toList()..sort();
      final missingFromEn = kmKeys.difference(enKeys).toList()..sort();

      expect(
        missingFromKm,
        isEmpty,
        reason: 'these keys exist in englishKey but not khmerKey, so they '
            'render as English in the Khmer locale:\n'
            '${missingFromKm.join('\n')}',
      );
      expect(
        missingFromEn,
        isEmpty,
        reason: 'these keys exist in khmerKey but not englishKey:\n'
            '${missingFromEn.join('\n')}',
      );
    });

    test('neither map has duplicate keys', () {
      // A duplicate literal in a Dart map silently keeps the last entry.
      for (final entry in {'englishKey': en, 'khmerKey': km}.entries) {
        final source = File(
          'lib/translations/${entry.key == 'englishKey' ? 'english' : 'khmer'}_key.dart',
        ).readAsStringSync();
        final names = RegExp(r'AppLocale\.(\w+):')
            .allMatches(source)
            .map((m) => m.group(1)!)
            .toList();
        final seen = <String>{};
        final dupes = <String>[];
        for (final n in names) {
          if (!seen.add(n)) dupes.add(n);
        }
        expect(
          dupes,
          isEmpty,
          reason: '${entry.key} names these keys more than once, and the last '
              'wins silently: ${dupes.join(', ')}',
        );
      }
    });

    test('no Khmer value is left as its English key', () {
      // The key IS the English string here, so `AppLocale.x: AppLocale.x` in
      // the Khmer map is an untranslated string hiding in plain sight.
      final untranslated = <String>[];
      final source =
          File('lib/translations/khmer_key.dart').readAsStringSync();
      for (final m
          in RegExp(r'AppLocale\.(\w+):\s*AppLocale\.(\w+)').allMatches(source)) {
        if (m.group(1) == m.group(2)) untranslated.add(m.group(1)!);
      }

      expect(
        untranslated,
        isEmpty,
        reason: 'these Khmer entries point at the English key, so they render '
            'in English:\n${untranslated.join('\n')}',
      );
    });
  });

  group('every declared AppLocale key is wired into both maps', () {
    test('no key is declared and then never translated', () {
      final declared = RegExp(r'static var (\w+)\s*=')
          .allMatches(File('lib/translations/app_locale.dart').readAsStringSync())
          .map((m) => m.group(1)!)
          .toSet();

      final enNames = RegExp(r'AppLocale\.(\w+):')
          .allMatches(File('lib/translations/english_key.dart').readAsStringSync())
          .map((m) => m.group(1)!)
          .toSet();
      final kmNames = RegExp(r'AppLocale\.(\w+):')
          .allMatches(File('lib/translations/khmer_key.dart').readAsStringSync())
          .map((m) => m.group(1)!)
          .toSet();

      final missingEn = declared.difference(enNames).toList()..sort();
      final missingKm = declared.difference(kmNames).toList()..sort();

      expect(
        missingEn,
        isEmpty,
        reason: 'declared on AppLocale but absent from englishKey:\n'
            '${missingEn.join('\n')}',
      );
      expect(
        missingKm,
        isEmpty,
        reason: 'declared on AppLocale but absent from khmerKey:\n'
            '${missingKm.join('\n')}',
      );
    });
  });
}
