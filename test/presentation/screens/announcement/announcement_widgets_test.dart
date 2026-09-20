import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/announcement_cell_data.dart';
import 'package:com.tara.passenger/data/models/announcement_model.dart';
import 'package:com.tara.passenger/presentation/screens/announcement/view.dart';
import 'package:com.tara.passenger/presentation/screens/announcement_detail/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

const _detailMarker = Key('announcement-detail-stub');

AnnouncementDetailModel _item({
  int? id = 7,
  String? title = 'Fare update',
  String? description = 'Fares change from Monday.',
  DateTime? createdAt,
  List<dynamic>? files,
}) =>
    AnnouncementDetailModel(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt ?? DateTime.parse('2026-09-11T09:41:00'),
      files: files,
    );

Future<void> _pump(WidgetTester tester, Widget child) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/under-test',
      getPages: [
        GetPage(
          name: '/under-test',
          page: () => Scaffold(body: SingleChildScrollView(child: child)),
        ),
        GetPage(
          name: AppRoutes.ANNOUNCEMENTDETAIL,
          page: () => const Scaffold(body: SizedBox(key: _detailMarker)),
        ),
      ],
    ),
  );
  await tester.pump();
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('AnnouncementCard (03 §Screen 18)', () {
    testWidgets('renders title, excerpt and date', (tester) async {
      await _pump(tester, AnnouncementCard(item: _item()));

      expect(find.text('Fare update'), findsOneWidget);
      expect(find.text('Fares change from Monday.'), findsOneWidget);
      expect(
        find.text(announcementDate(DateTime.parse('2026-09-11T09:41:00'))),
        findsOneWidget,
      );
    });

    testWidgets('an announcement with no body drops the excerpt line',
        (tester) async {
      await _pump(tester, AnnouncementCard(item: _item(description: null)));

      expect(find.text('Fare update'), findsOneWidget);
      expect(
        find.text(AppLocale.unKnown),
        findsNothing,
        reason: 'the line is dropped, not filled with "Unknown"',
      );
    });

    testWidgets('an untitled announcement still gets a heading',
        (tester) async {
      await _pump(tester, AnnouncementCard(item: _item(title: null)));

      expect(find.text(AppLocale.untitledAnnouncement), findsOneWidget);
    });

    testWidgets('a missing date degrades to an em dash instead of crashing',
        (tester) async {
      // The card this replaced called `DateTime.parse("${item.createdAt}")`,
      // which parses the literal string "null" and throws.
      final item = _item();
      item.createdAt = null;
      await _pump(tester, AnnouncementCard(item: item));

      expect(tester.takeException(), isNull);
      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('tapping the card opens the detail route', (tester) async {
      await _pump(tester, AnnouncementCard(item: _item()));

      await tester.tap(find.byType(AnnouncementCard));
      await tester.pumpAndSettle();

      expect(find.byKey(_detailMarker), findsOneWidget);
    });

    testWidgets('the detail route receives the same {"id": ...} argument',
        (tester) async {
      // The FCM deep link and the detail controller both read this shape.
      await _pump(tester, AnnouncementCard(item: _item(id: 42)));

      await tester.tap(find.byType(AnnouncementCard));
      await tester.pumpAndSettle();

      expect(Get.arguments, {'id': 42});
    });
  });

  group('Announcement list states (S3 Done When)', () {
    testWidgets('the empty state says there are none', (tester) async {
      await _pump(tester, const AnnouncementEmptyState());
      expect(find.text(AppLocale.noAnnouncements), findsOneWidget);
    });

    testWidgets('the error state explains and offers retry', (tester) async {
      var retried = 0;
      await _pump(tester, AnnouncementErrorState(onRetry: () => retried++));

      expect(find.text(AppLocale.couldNotLoadAnnouncements), findsOneWidget);
      await tester.tap(find.widgetWithText(TaButton, AppLocale.retry));
      await tester.pump();
      expect(retried, 1);
    });

    testWidgets('empty and error are distinguishable', (tester) async {
      // They previously both fell through to the delegate's default.
      await _pump(tester, const AnnouncementEmptyState());
      expect(find.text(AppLocale.couldNotLoadAnnouncements), findsNothing);
    });
  });

  group('AnnouncementDetailCard (03 §Screen 19)', () {
    testWidgets('renders title, date and body', (tester) async {
      await _pump(tester, AnnouncementDetailCard(data: _item()));

      expect(find.text('Fare update'), findsOneWidget);
      expect(find.text('Fares change from Monday.'), findsOneWidget);
      expect(
        find.text(announcementDate(DateTime.parse('2026-09-11T09:41:00'))),
        findsOneWidget,
      );
    });

    testWidgets('no body drops the paragraph rather than printing "Unknown"',
        (tester) async {
      await _pump(
        tester,
        AnnouncementDetailCard(data: _item(description: null)),
      );

      expect(find.text(AppLocale.unKnown), findsNothing);
      expect(find.text('Fare update'), findsOneWidget);
    });

    testWidgets('no attachments renders no image strip', (tester) async {
      await _pump(tester, AnnouncementDetailCard(data: _item(files: null)));

      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('a malformed files payload does not take the screen down',
        (tester) async {
      await _pump(
        tester,
        AnnouncementDetailCard(
          data: _item(files: ['not a map', 42, null]),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Fare update'), findsOneWidget);
    });
  });

  group('AnnouncementDetailSkeleton', () {
    testWidgets('stands in until the fetch lands', (tester) async {
      await _pump(tester, const AnnouncementDetailSkeleton());
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(TaSkeleton), findsWidgets);
    });
  });
}
