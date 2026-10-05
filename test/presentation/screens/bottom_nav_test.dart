import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// C1 (docs/roadmap) — the tab bar (TaBottomNav) must render the three
/// host labels without overflow at 320 px width with text scale 1.3, and
/// switch the active tab via onChanged. Since D33 it is a docked bar rather
/// than a floating pill, and must keep its tabs clear of the system gesture
/// area. Host wiring (each tab showing its own
/// screen, unchanged back/tab-stack and language-toggle behaviour) is a
/// device check → carried to Q2; the host keeps exactly three tabs because
/// bottom_nav/logic.dart (the `pages` list) is not modified by C1.
void main() {
  group('TaBottomNav docked bar (C1, D33)', () {
    Widget hostBar({int index = 0}) => MaterialApp(
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
      await tester.pumpWidget(hostBar());
      expect(tester.takeException(), isNull);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('My Booking'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(TaBottomNav), findsOneWidget);
    });

    testWidgets('honours the selected index', (tester) async {
      await tester.pumpWidget(hostBar(index: 1));
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

    testWidgets('marks the active tab in the brand colour', (tester) async {
      await tester.pumpWidget(hostBar(index: 1));
      Color? labelColor(String label) =>
          tester.widget<Text>(find.text(label)).style?.color;
      expect(labelColor('My Booking'), TaColors.primary);
      expect(labelColor('Home'), TaColors.textSecondary);
      expect(labelColor('Profile'), TaColors.textSecondary);
    });

    testWidgets('runs to the screen edge but keeps the tabs above the '
        'system gesture area', (tester) async {
      const inset = 34.0;
      await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(800, 600),
            padding: EdgeInsets.only(bottom: inset),
          ),
          child: Scaffold(
            bottomNavigationBar: TaBottomNav(
              currentIndex: 0,
              onChanged: (_) {},
              items: const [
                TaNavItem(icon: Icons.home, label: 'Home'),
                TaNavItem(icon: Icons.event, label: 'My Booking'),
                TaNavItem(icon: Icons.person, label: 'Profile'),
              ],
            ),
          ),
        ),
      ));
      final bar = tester.getRect(find.byType(TaBottomNav));
      final label = tester.getRect(find.text('Home'));
      expect(bar.left, 0);
      expect(bar.right, 800);
      expect(bar.bottom, 600);
      expect(label.bottom, lessThanOrEqualTo(bar.bottom - inset));
    });
  });
}