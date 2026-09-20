import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards roadmap S5's Done When: "`AppColors`/`ThemeConstands` are **deleted**
/// rather than left commented out" and "no screen references a legacy colour or
/// text style".
///
/// A grep in a runbook only holds while someone remembers to run it. This makes
/// the deletion enforceable — reintroducing either table, or importing one of
/// the widgets that carried them, fails the suite.
void main() {
  final lib = Directory('lib');

  List<File> dartFiles() => lib
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  group('S5 — the legacy style tables are gone', () {
    test('their defining files no longer exist', () {
      for (final path in [
        'lib/core/theme/colors.dart',
        'lib/core/theme/text_styles.dart',
        'lib/core/theme/app_theme.dart',
      ]) {
        expect(
          File(path).existsSync(),
          isFalse,
          reason: '$path was deleted at S5 and must not come back',
        );
      }
    });

    test('the superseded legacy widgets no longer exist', () {
      for (final path in [
        'lib/presentation/widgets/x_text_field.dart',
        'lib/presentation/widgets/text_field_decoration.dart',
        'lib/presentation/widgets/decorated_input_border.dart',
        'lib/presentation/widgets/fbtn_widget.dart',
        'lib/presentation/widgets/x_button.dart',
        'lib/presentation/widgets/card_atta_widget.dart',
        'lib/presentation/widgets/t_image_widget.dart',
      ]) {
        expect(
          File(path).existsSync(),
          isFalse,
          reason: '$path was deleted at S5; use the Ta* component instead',
        );
      }
    });

    test('no source file references the deleted identifiers', () {
      final offenders = <String>[];

      for (final file in dartFiles()) {
        for (final line in file.readAsLinesSync()) {
          final code = line.trim();
          // Doc comments are allowed to name them — the token files record
          // that the tables were removed, which is worth keeping written down.
          if (code.startsWith('//') || code.startsWith('///')) continue;
          for (final token in const [
            'AppColors',
            'ThemeConstands',
            'AppTextStyles',
            'AppTheme',
          ]) {
            if (code.contains(token)) {
              offenders.add('${file.path}: $code');
            }
          }
        }
      }

      expect(
        offenders,
        isEmpty,
        reason: 'use TaColors / TaTextStyles / TaTheme instead:\n'
            '${offenders.join('\n')}',
      );
    });
  });
}
