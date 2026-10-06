import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_dialog.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_recorder.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/logic.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _homeMarker = Key('home-stub');
const _mapMarker = Key('map-stub');

Data _booking({
  int? id = 42,
  int? invoiceId = 2042,
  String? amount = '12000',
  String? method = 'Cash',
  String? startAddress = 'No. 128, St. 271',
  dynamic endAddress = 'Aeon Mall Phnom Penh',
  dynamic startTime = '2026-09-11 09:41:00',
}) =>
    Data(
      id: id,
      startAddress: startAddress,
      endAddress: endAddress,
      startTime: startTime,
      driver: Driver(name: 'Sok Dara'),
      payment: Payment(
        invoiceId: invoiceId,
        amount: amount,
        paymentMethod: method,
      ),
    );

late RatingPromptStore _store;

/// Pumps the Thank you page as its own route, with stubs for the two places
/// it leaves to.
///
/// The page ticks a one-second timer for as long as it is open, so every test
/// ends by leaving it or by calling [_close].
Future<ReceiptLogic> _pump(
  WidgetTester tester, {
  Data? booking,
  int? stars,
  bool promptRating = false,
  Size size = const Size(400, 900),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  SharedPreferences.setMockInitialValues({});
  _store = RatingPromptStore(
    preferences: await SharedPreferences.getInstance(),
  );
  final logic = ReceiptLogic(
    booking: booking ?? _booking(),
    stars: stars,
    promptRating: promptRating,
    recorder: RatingRecorder(promptStore: _store),
  );
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
  // The success check and, when prompted, the dialog's entrance.
  await tester.pumpAndSettle();
  return logic;
}

/// Stops the page's countdown so the test leaves no timer behind.
void _close(ReceiptLogic logic) => logic.onClose();

Future<void> _tapStar(WidgetTester tester, int n) async {
  await tester.tap(find.byIcon(Icons.star).at(n - 1));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

String _backLabel(int seconds) => '${AppLocale.backToHome} · $seconds s';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    RatingRecorder.pendingRatings = const [];
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

  group('receiptPaidLabel', () {
    test('names the method when the backend does', () {
      expect(receiptPaidLabel(Payment(paymentMethod: 'Wallet')),
          '${AppLocale.paid} · Wallet');
    });

    test('plain "Paid" when it does not — the method is not invented', () {
      expect(receiptPaidLabel(Payment()), AppLocale.paid);
      expect(receiptPaidLabel(null), AppLocale.paid);
    });
  });

  group('Thank you page (03 §Screen 12)', () {
    testWidgets('thanks the passenger without claiming a receipt was sent',
        (tester) async {
      final logic = await _pump(tester);

      expect(find.text(AppLocale.thankYou), findsOneWidget);
      expect(find.text(AppLocale.tripComplete), findsOneWidget);
      expect(find.textContaining('Receipt sent'), findsNothing);
      expect(find.byType(ReceiptSuccessCheck), findsOneWidget);
      _close(logic);
    });

    testWidgets('the amount paid leads, marked paid with its method',
        (tester) async {
      final logic = await _pump(tester);

      final amount = find.text('\$12,000.00');
      expect(amount, findsOneWidget);
      expect(find.text('${AppLocale.paid} · Cash'), findsOneWidget);
      expect(
        tester.getRect(amount).bottom,
        lessThan(tester.getRect(find.byType(TaTripCard)).top),
      );
      _close(logic);
    });

    testWidgets('the trip and the labelled invoice rows', (tester) async {
      final logic = await _pump(tester);

      final trip = tester.widget<TaTripCard>(find.byType(TaTripCard));
      expect(trip.pickup, 'No. 128, St. 271');
      expect(trip.dropOff, 'Aeon Mall Phnom Penh');

      expect(find.text(AppLocale.invoice), findsOneWidget);
      expect(find.text('INV-2042'), findsOneWidget);
      expect(find.text('11 Sep 2026, 9:41 AM'), findsOneWidget);
      _close(logic);
    });

    testWidgets('a trip booked without a drop-off says so', (tester) async {
      final logic = await _pump(tester, booking: _booking(endAddress: null));

      expect(find.text(AppLocale.noDropOffMeter), findsOneWidget);
      _close(logic);
    });

    // The page this replaced put the address in a row's label slot, which
    // pushed the amount off the card: "RIGHT OVERFLOWED BY 128 PIXELS".
    testWidgets('a long address fits a narrow phone without overflowing',
        (tester) async {
      final logic = await _pump(
        tester,
        size: const Size(320, 640),
        booking: _booking(
          endAddress:
              'Phnom Penh International Airport, Pou Senchey, Phnom Penh',
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('\$12,000.00'), findsOneWidget);
      _close(logic);
    });

    testWidgets('no rating yet shows no rating row, not an invented score',
        (tester) async {
      final logic = await _pump(tester);

      expect(find.text(AppLocale.yourRating), findsNothing);
      expect(find.textContaining('★'), findsNothing);
      _close(logic);
    });

    testWidgets('a missing invoice drops that row entirely', (tester) async {
      final logic = await _pump(tester, booking: _booking(invoiceId: null));

      expect(find.text(AppLocale.invoice), findsNothing);
      expect(find.textContaining('INV-'), findsNothing);
      _close(logic);
    });

    testWidgets('an unparseable fare says so, and nothing is called paid',
        (tester) async {
      final logic = await _pump(tester, booking: _booking(amount: 'abc'));

      expect(find.text(AppLocale.fareUnavailable), findsOneWidget);
      expect(find.byType(TaBadge), findsNothing);
      _close(logic);
    });
  });

  group('Thank you page — exits', () {
    testWidgets('"Back to Home" clears the post-trip stack', (tester) async {
      await _pump(tester);

      await tester.tap(find.byType(TaButton).first);
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

  group('Thank you page — returns home by itself', () {
    testWidgets('the button counts down from 60 seconds', (tester) async {
      final logic = await _pump(tester);
      expect(find.text(_backLabel(60)), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text(_backLabel(59)), findsOneWidget);

      await tester.pump(const Duration(seconds: 9));
      expect(find.text(_backLabel(50)), findsOneWidget);
      _close(logic);
    });

    testWidgets('after 60 seconds untouched it goes home', (tester) async {
      await _pump(tester);

      await tester.pump(const Duration(seconds: 59));
      expect(find.byType(ReceiptScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(find.byType(ReceiptScreen), findsNothing);
    });

    testWidgets('leaving by hand stops the countdown', (tester) async {
      await _pump(tester);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.bookAgain));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 90));
      await tester.pumpAndSettle();

      expect(find.byKey(_mapMarker), findsOneWidget,
          reason: 'not yanked from the map to home a minute later');
    });
  });

  group('Thank you page — rating dialog', () {
    testWidgets('opens by itself when the trip has not been rated',
        (tester) async {
      final logic = await _pump(tester, promptRating: true);

      expect(find.byType(RatingDialog), findsOneWidget);
      // The page is already there underneath it.
      expect(find.text(AppLocale.thankYou), findsOneWidget);
      _close(logic);
    });

    testWidgets('does not open for a trip already rated or skipped',
        (tester) async {
      final logic = await _pump(tester);

      expect(find.byType(RatingDialog), findsNothing);
      _close(logic);
    });

    testWidgets('Submit queues the rating and shows it on the page',
        (tester) async {
      final logic = await _pump(tester, promptRating: true);

      await _tapStar(tester, 4);
      await tester.tap(find.text(AppLocale.submit));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsNothing);
      expect(find.byType(ReceiptScreen), findsOneWidget);
      expect(find.text(AppLocale.yourRating), findsOneWidget);
      expect(find.text('★★★★☆ · 4/5'), findsOneWidget);

      final queued = RatingRecorder.pendingRatings.single;
      expect(queued.bookingId, 42);
      expect(queued.stars, 4);
      expect(await _store.isHandled(42), isTrue);
      _close(logic);
    });

    testWidgets('Skip queues nothing, shows no rating, and is not re-asked',
        (tester) async {
      final logic = await _pump(tester, promptRating: true);

      await tester.tap(find.text(AppLocale.skip));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsNothing);
      expect(find.text(AppLocale.yourRating), findsNothing);
      expect(RatingRecorder.pendingRatings, isEmpty);
      expect(await _store.isHandled(42), isTrue);
      _close(logic);
    });

    testWidgets('touching the rating restarts the minute', (tester) async {
      final logic = await _pump(tester, promptRating: true);

      await tester.pump(const Duration(seconds: 40));
      expect(logic.state.secondsLeft, 20);

      // Read straight after the tap: the clock keeps ticking while the
      // star's pop animation settles.
      await tester.tap(find.byIcon(Icons.star).at(4));
      await tester.pump();
      expect(logic.state.secondsLeft, 60,
          reason: 'nobody is cut off while they are still choosing');
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      await tester.pump(const Duration(seconds: 30));
      expect(logic.state.secondsLeft, lessThan(31));

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pump();
      expect(logic.state.secondsLeft, 60);
      _close(logic);
    });

    testWidgets('left untouched, the dialog closes as a skip and goes home',
        (tester) async {
      await _pump(tester, promptRating: true);

      await tester.pump(const Duration(seconds: 60));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsNothing);
      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(RatingRecorder.pendingRatings, isEmpty);
      expect(await _store.isHandled(42), isTrue,
          reason: 'an ignored prompt is a skip, and is never re-asked');
    });

    testWidgets('stars chosen but never submitted are not a rating',
        (tester) async {
      await _pump(tester, promptRating: true);

      await _tapStar(tester, 5);
      await tester.pump(const Duration(seconds: 60));
      await tester.pumpAndSettle();

      expect(find.byKey(_homeMarker), findsOneWidget);
      expect(RatingRecorder.pendingRatings, isEmpty);
    });
  });

  test('RatingDraft is what the dialog hands back', () {
    // Pins the type the page records, so a change to the dialog's result
    // cannot silently turn every rating into a skip.
    expect(const RatingDraft().withStars(3).canSubmit, isTrue);
    expect(const RatingDraft().canSubmit, isFalse);
  });
}
