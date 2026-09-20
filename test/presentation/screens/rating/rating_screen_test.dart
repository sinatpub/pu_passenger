import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/logic.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _receiptMarker = Key('receipt-stub');

Future<RatingLogic> _pump(
  WidgetTester tester, {
  String? driverName = 'Sok Dara',
  int? bookingId = 42,
}) async {
  SharedPreferences.setMockInitialValues({});
  final logic = RatingLogic(
    booking: Data(id: bookingId, driver: Driver(name: driverName)),
    promptStore: RatingPromptStore(
      preferences: await SharedPreferences.getInstance(),
    ),
  );
  Get.put<RatingLogic>(logic);

  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: AppRoutes.RATING,
      getPages: [
        GetPage(name: AppRoutes.RATING, page: () => const RatingScreen()),
        GetPage(
          name: AppRoutes.RECEIPT,
          page: () => const Scaffold(body: SizedBox(key: _receiptMarker)),
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
    RatingLogic.pendingRatings = const [];
  });

  tearDown(() => Get.reset());

  group('Rating screen — N-10 tone rules (roadmap C7 Done When)', () {
    testWidgets('offers no tags before a star is chosen', (tester) async {
      await _pump(tester);
      expect(find.byType(TaChip), findsNothing);
    });

    testWidgets('5 stars offers the four positive tags', (tester) async {
      final logic = await _pump(tester);
      logic.setStars(5);
      await tester.pumpAndSettle();

      expect(find.byType(TaChip), findsNWidgets(4));
      expect(find.text(AppLocale.tagClean), findsOneWidget);
      expect(find.text(AppLocale.tagOnTime), findsOneWidget);
      expect(find.text(AppLocale.tagFriendly), findsOneWidget);
      expect(find.text(AppLocale.tagGoodRoute), findsOneWidget);
    });

    testWidgets('1-3 stars offers no tags, because none are written',
        (tester) async {
      final logic = await _pump(tester);
      logic.setStars(2);
      await tester.pumpAndSettle();

      expect(
        find.byType(TaChip),
        findsNothing,
        reason: 'N-10 names no negative tags; a low rating is a shorter screen',
      );
    });

    testWidgets('dropping from 5 to 2 stars clears tags chosen for the 5',
        (tester) async {
      final logic = await _pump(tester);
      logic.setStars(5);
      logic.toggleTag(RatingTag.clean);
      await tester.pumpAndSettle();
      expect(logic.state.draft.tags, contains(RatingTag.clean));

      logic.setStars(2);
      await tester.pumpAndSettle();
      expect(
        logic.state.draft.tags,
        isEmpty,
        reason: 'a 2-star rating must not carry praise chosen for 5 stars',
      );
    });

    testWidgets('tapping a chip toggles it', (tester) async {
      final logic = await _pump(tester);
      logic.setStars(5);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      expect(logic.state.draft.tags, contains(RatingTag.clean));

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      expect(logic.state.draft.tags, isNot(contains(RatingTag.clean)));
    });
  });

  group('Rating screen — submit gating', () {
    testWidgets('Submit is disabled until a star is chosen', (tester) async {
      final logic = await _pump(tester);

      final before = tester.widget<TaButton>(
        find.widgetWithText(TaButton, AppLocale.submit),
      );
      expect(before.isEnabled, isFalse);

      logic.setStars(4);
      await tester.pumpAndSettle();

      final after = tester.widget<TaButton>(
        find.widgetWithText(TaButton, AppLocale.submit),
      );
      expect(after.isEnabled, isTrue);
    });

    testWidgets('submitting queues the rating and lands on the receipt',
        (tester) async {
      final logic = await _pump(tester);
      logic.setStars(4);
      logic.toggleTag(RatingTag.friendly);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TaButton, AppLocale.submit));
      await tester.pumpAndSettle();

      // PDD-02: no endpoint exists, so the rating is queued, never sent.
      expect(RatingLogic.pendingRatings, hasLength(1));
      expect(RatingLogic.pendingRatings.single.bookingId, 42);
      expect(RatingLogic.pendingRatings.single.stars, 4);
      expect(
        RatingLogic.pendingRatings.single.tags,
        contains(RatingTag.friendly),
      );
      expect(find.byKey(_receiptMarker), findsOneWidget);
    });

    testWidgets('re-rating one trip replaces its queued entry', (tester) async {
      final logic = await _pump(tester);
      logic.setStars(5);
      await logic.submit();
      logic.setStars(3);
      await logic.submit();

      expect(
        RatingLogic.pendingRatings,
        hasLength(1),
        reason: 'one rating per booking, latest wins',
      );
      expect(RatingLogic.pendingRatings.single.stars, 3);
    });
  });

  group('Rating screen — Skip is available and unpunished', () {
    testWidgets('Skip is offered and queues nothing', (tester) async {
      final logic = await _pump(tester);
      expect(find.widgetWithText(TaButton, AppLocale.skip), findsOneWidget);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.skip));
      await tester.pumpAndSettle();

      expect(RatingLogic.pendingRatings, isEmpty);
      expect(find.byKey(_receiptMarker), findsOneWidget);
      expect(logic.state.draft.stars, isNull);
    });

    testWidgets('a skipped trip is marked handled, so it is never re-asked',
        (tester) async {
      // `_pump` resets the mock store, so this reads the same empty backing
      // data the screen's own store was built over.
      await _pump(tester, bookingId: 7);
      final store = RatingPromptStore(
        preferences: await SharedPreferences.getInstance(),
      );
      expect(await store.isHandled(7), isFalse);

      await tester.tap(find.widgetWithText(TaButton, AppLocale.skip));
      await tester.pumpAndSettle();

      expect(
        await store.isHandled(7),
        isTrue,
        reason: 're-asking after a skip is the punishment N-10 forbids',
      );
    });
  });

  group('Rating screen — display degrades', () {
    testWidgets('names the driver when there is a name', (tester) async {
      await _pump(tester);
      expect(
        find.text('${AppLocale.howWasYourTripWith} Sok Dara?'),
        findsOneWidget,
      );
    });

    testWidgets('drops the name rather than rendering "with ?"',
        (tester) async {
      await _pump(tester, driverName: null);
      expect(find.text(AppLocale.howWasYourTrip), findsOneWidget);
    });

    testWidgets('says plainly that ratings are not sent yet (PDD-02)',
        (tester) async {
      await _pump(tester);
      expect(find.text(AppLocale.ratingPendingBackend), findsOneWidget);
    });
  });
}
