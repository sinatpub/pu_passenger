import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/logic.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _homeMarker = Key('home-stub');
const _mapMarker = Key('map-stub');

Data _booking({
  int? invoiceId = 2042,
  String? amount = '12000',
  String? method = 'Cash',
  dynamic endAddress = 'Aeon Mall Phnom Penh',
}) =>
    Data(
      endAddress: endAddress,
      payment: Payment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMethod: method,
      ),
    );

Future<ReceiptLogic> _pump(
  WidgetTester tester, {
  Data? booking,
  int? stars = 4,
}) async {
  final logic = ReceiptLogic(booking: booking ?? _booking(), stars: stars);
  Get.put<ReceiptLogic>(logic);

  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: AppRoutes.RECEIPT,
      getPages: [
        GetPage(name: AppRoutes.RECEIPT, page: () => const ReceiptScreen()),
        GetPage(
          name: AppRoutes.BOTTOMNAV,
          page: () => const Scaffold(body: SizedBox(key: _homeMarker)),
        ),
        GetPage(
          name: AppRoutes.MAP,
          page: () => const Scaffold(body: SizedBox(key: _mapMarker)),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return logic;
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('receiptRating', () {
    test('renders filled and empty stars with the score', () {
      expect(receiptRating(4), '★★★★☆ · 4/5');
      expect(receiptRating(5), '★★★★★ · 5/5');
      expect(receiptRating(1), '★☆☆☆☆ · 1/5');
    });

    test('a skipped rating has none', () {
      expect(receiptRating(null), isNull);
    });

    test('an out-of-range score is not rendered', () {
      expect(receiptRating(0), isNull);
      expect(receiptRating(6), isNull);
    });
  });

  group('receiptInvoice', () {
    test('prefixes the invoice id', () {
      expect(receiptInvoice(Payment(invoiceId: 2042)), 'INV-2042');
    });

    test('a missing invoice id yields null, never "INV-null"', () {
      expect(receiptInvoice(Payment()), isNull);
      expect(receiptInvoice(null), isNull);
    });
  });

  group('Receipt screen (03 §Screen 12)', () {
    testWidgets('renders the thank-you copy and the success check',
        (tester) async {
      await _pump(tester);

      expect(find.text(AppLocale.thankYou), findsOneWidget);
      expect(find.text(AppLocale.tripCompleteReceiptSent), findsOneWidget);
      expect(find.byType(ReceiptSuccessCheck), findsOneWidget);
    });

    testWidgets('renders invoice, rating, destination, amount and paid row',
        (tester) async {
      await _pump(tester);

      expect(find.text('INV-2042'), findsOneWidget);
      expect(find.text('★★★★☆ · 4/5'), findsOneWidget);
      expect(find.text('Aeon Mall Phnom Penh'), findsOneWidget);
      expect(find.text('12,000 ${AppLocale.khmerCurrency}'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text(AppLocale.paid), findsOneWidget);
    });

    testWidgets('a skipped rating shows an em dash, not an invented score',
        (tester) async {
      await _pump(tester, stars: null);

      expect(find.text('INV-2042'), findsOneWidget);
      expect(find.textContaining('★'), findsNothing);
    });

    testWidgets('a missing invoice drops that row entirely', (tester) async {
      await _pump(tester, booking: _booking(invoiceId: null));

      expect(find.textContaining('INV-'), findsNothing);
      // The trip rows still render.
      expect(find.text('Aeon Mall Phnom Penh'), findsOneWidget);
    });

    testWidgets('an unparseable fare says so rather than showing a number',
        (tester) async {
      await _pump(tester, booking: _booking(amount: 'abc'));

      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
    });

    testWidgets('no payment method drops the paid row', (tester) async {
      await _pump(tester, booking: _booking(method: null));

      expect(find.text(AppLocale.paid), findsNothing);
    });
  });

  group('Receipt screen — exits', () {
    testWidgets('"Back to Home" clears the post-trip stack', (tester) async {
      await _pump(tester);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.backToHome));
      await tester.pumpAndSettle();

      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(find.byType(ReceiptScreen), findsNothing);
    });

    testWidgets('"Book again" goes to the map', (tester) async {
      await _pump(tester);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.bookAgain));
      await tester.pumpAndSettle();

      expect(find.byKey(_mapMarker), findsOneWidget);
    });
  });
}
