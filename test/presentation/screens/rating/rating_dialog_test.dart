import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:com.tara.passenger/presentation/screens/rate_driver/rating.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_dialog.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_recorder.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// What the dialog was closed with: a draft on Submit, null on Skip. Wrapped
/// so "not closed yet" and "closed with null" can be told apart.
class _Outcome {
  bool closed = false;
  RatingDraft? draft;
}

/// Opens the dialog from a host page, the way the Thank you page does.
Future<_Outcome> _open(
  WidgetTester tester, {
  String? driverName = 'Sok Dara',
  VoidCallback? onInteraction,
  Size size = const Size(400, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final outcome = _Outcome();
  await tester.pumpWidget(
    GetMaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async {
              outcome.draft = await showRatingDialog(
                context,
                driverName: driverName,
                onInteraction: onInteraction,
              );
              outcome.closed = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return outcome;
}

/// Taps the [n]th star and lets its pop animation finish.
Future<void> _tapStar(WidgetTester tester, int n) async {
  await tester.tap(find.byIcon(Icons.star).at(n - 1));
  await tester.pumpAndSettle(const Duration(milliseconds: 100));
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    RatingRecorder.pendingRatings = const [];
  });

  tearDown(() => Get.reset());

  group('Rating dialog — N-10 tone rules (roadmap C7 Done When)', () {
    testWidgets('offers no tags before a star is chosen', (tester) async {
      await _open(tester);
      expect(find.byType(TaChip), findsNothing);
    });

    testWidgets('5 stars offers the four positive tags', (tester) async {
      await _open(tester);
      await _tapStar(tester, 5);

      expect(find.byType(TaChip), findsNWidgets(4));
      expect(find.text(AppLocale.tagClean), findsOneWidget);
      expect(find.text(AppLocale.tagOnTime), findsOneWidget);
      expect(find.text(AppLocale.tagFriendly), findsOneWidget);
      expect(find.text(AppLocale.tagGoodRoute), findsOneWidget);
    });

    testWidgets('1-3 stars offers no tags, because none are written',
        (tester) async {
      await _open(tester);
      await _tapStar(tester, 2);

      expect(find.byType(TaChip), findsNothing);
    });

    testWidgets('dropping from 5 to 2 stars clears tags chosen for the 5',
        (tester) async {
      final outcome = await _open(tester);
      await _tapStar(tester, 5);
      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      await _tapStar(tester, 2);

      await tester.tap(find.text(AppLocale.submit));
      await tester.pumpAndSettle();

      expect(outcome.draft?.stars, 2);
      expect(outcome.draft?.tags, isEmpty,
          reason: 'praise chosen for a different answer is not submitted');
    });

    testWidgets('tapping a chip toggles it', (tester) async {
      await _open(tester);
      await _tapStar(tester, 5);

      TaChip clean() => tester.widget<TaChip>(
          find.widgetWithText(TaChip, AppLocale.tagClean));

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      expect(clean().isSelected, isTrue);

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      expect(clean().isSelected, isFalse);
    });
  });

  group('Rating dialog — submit and skip', () {
    testWidgets('Submit is disabled until a star is chosen', (tester) async {
      await _open(tester);

      TaButton submit() => tester.widget<TaButton>(
          find.widgetWithText(TaButton, AppLocale.submit));
      expect(submit().isEnabled, isFalse);

      await _tapStar(tester, 4);
      expect(submit().isEnabled, isTrue);
    });

    testWidgets('Submit closes the dialog with the stars and tags chosen',
        (tester) async {
      final outcome = await _open(tester);
      await _tapStar(tester, 5);
      await tester.tap(find.text(AppLocale.tagOnTime));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppLocale.submit));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsNothing);
      expect(outcome.closed, isTrue);
      expect(outcome.draft?.stars, 5);
      expect(outcome.draft?.tags, {RatingTag.onTime});
    });

    testWidgets('Skip is always offered and closes with nothing',
        (tester) async {
      final outcome = await _open(tester);
      await _tapStar(tester, 3);

      await tester.tap(find.text(AppLocale.skip));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsNothing);
      expect(outcome.closed, isTrue);
      expect(outcome.draft, isNull,
          reason: 'stars touched and then skipped are not a rating');
    });

    testWidgets('a tap outside does not dismiss it by accident',
        (tester) async {
      final outcome = await _open(tester);

      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(RatingDialog), findsOneWidget);
      expect(outcome.closed, isFalse);
    });

    testWidgets('every touch of the rating is reported to the page',
        (tester) async {
      var touches = 0;
      await _open(tester, onInteraction: () => touches++);

      await _tapStar(tester, 5);
      expect(touches, 1);

      await tester.tap(find.text(AppLocale.tagClean));
      await tester.pumpAndSettle();
      expect(touches, 2);
    });
  });

  group('Rating dialog — display', () {
    testWidgets('names the driver when there is a name', (tester) async {
      await _open(tester);

      expect(find.text(AppLocale.rateYourDriver), findsOneWidget);
      expect(find.text('${AppLocale.howWasYourTripWith} Sok Dara?'),
          findsOneWidget);
    });

    testWidgets('drops the name rather than rendering "with ?"',
        (tester) async {
      await _open(tester, driverName: null);
      expect(find.text(AppLocale.howWasYourTrip), findsOneWidget);
    });

    testWidgets('says plainly that ratings are not sent yet (PDD-02)',
        (tester) async {
      await _open(tester);
      expect(find.text(AppLocale.ratingPendingBackend), findsOneWidget);
    });

    testWidgets('no note field: nothing the dialog collects is thrown away',
        (tester) async {
      await _open(tester);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('fits a narrow, short phone with every tag showing',
        (tester) async {
      await _open(tester, size: const Size(320, 480));
      await _tapStar(tester, 5);

      expect(tester.takeException(), isNull);
      expect(find.byType(TaChip), findsNWidgets(4));
    });
  });

  group('RatingRecorder (PDD-02 — queued, nothing sent)', () {
    late RatingPromptStore store;
    late RatingRecorder recorder;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = RatingPromptStore(
        preferences: await SharedPreferences.getInstance(),
      );
      recorder = RatingRecorder(promptStore: store);
    });

    test('a submitted rating is queued and the trip marked handled', () async {
      await recorder.submit(
        const RatingDraft().withStars(5).toggle(RatingTag.clean),
        bookingId: 42,
      );

      final queued = RatingRecorder.pendingRatings.single;
      expect(queued.bookingId, 42);
      expect(queued.stars, 5);
      expect(queued.tags, {RatingTag.clean});
      expect(await store.isHandled(42), isTrue);
    });

    test('re-rating one trip replaces its queued entry', () async {
      await recorder.submit(const RatingDraft().withStars(5), bookingId: 42);
      await recorder.submit(const RatingDraft().withStars(2), bookingId: 42);

      expect(RatingRecorder.pendingRatings.single.stars, 2);
    });

    test('a skip queues nothing and is never re-asked', () async {
      await recorder.skip(bookingId: 42);

      expect(RatingRecorder.pendingRatings, isEmpty);
      expect(await store.isHandled(42), isTrue);
    });

    test('a booking with no id has nothing to key a rating on', () async {
      await recorder.submit(const RatingDraft().withStars(5), bookingId: null);
      await recorder.skip(bookingId: null);

      expect(RatingRecorder.pendingRatings, isEmpty);
    });
  });
}
