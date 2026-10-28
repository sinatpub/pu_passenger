import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/screens/booking_map_screen/widgets/ride_load_error_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Audit S-7 — the ride screen's sheet when the ride could not be loaded.
void main() {
  testWidgets('says so, and Retry asks again', (tester) async {
    var retries = 0;
    await tester.pumpWidget(GetMaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: RideLoadErrorSheet(onRetry: () => retries++),
        ),
      ),
    ));

    expect(find.text(AppLocale.somethingWentWrong), findsOneWidget);
    expect(find.text(AppLocale.bookingFailedBody), findsOneWidget);

    await tester.tap(find.widgetWithText(TaButton, AppLocale.retry));
    await tester.pump();

    expect(retries, 1);
  });
}
