import 'package:com.tara.passenger/presentation/screens/register/photo_source_sheet.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// D43 — the sheet that asks where the profile photo comes from. Texts are
/// the English keys: without loaded translations `.tr` gives the key back.
void main() {
  /// A page with one button that opens the sheet and keeps the answer.
  Future<PhotoSourceChoice? Function()> open(
    WidgetTester t, {
    required bool hasPhoto,
  }) async {
    PhotoSourceChoice? answer;
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => answer =
                await PhotoSourceSheet.show(context, hasPhoto: hasPhoto),
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    return () => answer;
  }

  testWidgets('no photo yet: a title, the camera and the gallery', (t) async {
    await open(t, hasPhoto: false);

    expect(find.text(AppLocale.profilePhoto), findsOneWidget);
    expect(find.text(AppLocale.takePhoto), findsOneWidget);
    expect(find.text(AppLocale.chooseFromGallery), findsOneWidget);
    expect(find.text(AppLocale.removePhoto), findsNothing);
  });

  testWidgets('with a photo: it can also be removed', (t) async {
    await open(t, hasPhoto: true);

    expect(find.text(AppLocale.removePhoto), findsOneWidget);
  });

  testWidgets('the sheet is only as tall as its rows', (t) async {
    await open(t, hasPhoto: false);

    // It used to be 40% of the screen with two tiles in the middle of it.
    final double height = t.getSize(find.byType(PhotoSourceSheet)).height;
    expect(height, lessThan(180));
  });

  for (final (String label, PhotoSourceChoice choice) in [
    (AppLocale.takePhoto, PhotoSourceChoice.camera),
    (AppLocale.chooseFromGallery, PhotoSourceChoice.gallery),
    (AppLocale.removePhoto, PhotoSourceChoice.remove),
  ]) {
    testWidgets('"$label" closes the sheet with ${choice.name}', (t) async {
      final answer = await open(t, hasPhoto: true);

      await t.tap(find.text(label));
      await t.pumpAndSettle();

      expect(find.byType(PhotoSourceSheet), findsNothing);
      expect(answer(), choice);
    });
  }

  testWidgets('closed without a choice: nothing is picked', (t) async {
    final answer = await open(t, hasPhoto: false);

    await t.tapAt(const Offset(10, 10));
    await t.pumpAndSettle();

    expect(find.byType(PhotoSourceSheet), findsNothing);
    expect(answer(), isNull);
  });
}
