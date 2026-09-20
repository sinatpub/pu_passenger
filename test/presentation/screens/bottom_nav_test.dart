import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// C1 (docs/roadmap) — the floating pill (TaBottomNav) must render the three
/// host labels without overflow at 320 px width with text scale 1.3, and
/// switch the active tab via onChanged. Host wiring (each tab showing its own
/// screen, unchanged back/tab-stack and language-toggle behaviour) is a
/// device check → carried to Q2; the host keeps exactly three tabs because
/// bottom_nav/logic.dart (the `pages` list) is not modified by C1.
void main() {
  group('TaBottomNav floating pill (C1)', () {
    Widget hostPill({int index = 0}) => MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 640),
              textScaler: TextScaler.linear(1.3),
            ),
            child: Scaffold(
              body: SizedBox(
                width: 320,
                height: 640,
                child: Column(
                  children: [
                    const Spacer(),
                    TaBottomNav(
                      currentIndex: index,
                      onChanged: (_) {},
                      items: const [
                        TaNavItem(icon: Icons.home, label: 'Home'),
                        TaNavItem(icon: Icons.event, label: 'My Booking'),
                        TaNavItem(icon: Icons.person, label: 'Profile'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );

    testWidgets('renders all three tab labels at 320px, text scale 1.3 '
        'without overflow', (tester) async {
      await tester.pumpWidget(hostPill());
      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('My Booking'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(TaBottomNav), findsOneWidget);
    });

    testWidgets('honours the selected index', (tester) async {
      await tester.pumpWidget(hostPill(index: 1));
      expect(tester.takeException(), isNull);
      final nav = tester.widget<TaBottomNav>(find.byType(TaBottomNav));
      expect(nav.currentIndex, 1);
    });

    testWidgets('tapping a tab reports its index through onChanged',
        (tester) async {
      var selected = -1;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: TaBottomNav(
            currentIndex: 0,
            onChanged: (i) => selected = i,
            items: const [
              TaNavItem(icon: Icons.home, label: 'Home'),
              TaNavItem(icon: Icons.event, label: 'My Booking'),
              TaNavItem(icon: Icons.person, label: 'Profile'),
            ],
          ),
        ),
      ));
      await tester.tap(find.text('My Booking'));
      expect(selected, 1);
      await tester.tap(find.text('Profile'));
      expect(selected, 2);
    });
  });
}