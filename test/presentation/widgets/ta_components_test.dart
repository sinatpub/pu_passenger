import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/presentation/widgets/widgets.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  Widget wrapFull(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('TaButton', () {
    testWidgets('default: renders label, fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaButton(label: 'Book Now', onTap: () => tapped = true)));
      expect(find.text('Book Now'), findsOneWidget);
      await tester.tap(find.text('Book Now'));
      expect(tapped, isTrue);
    });

    testWidgets('pressed: applies scale feedback', (tester) async {
      await tester.pumpWidget(wrap(TaButton(label: 'Book Now', onTap: () {})));
      final gesture = await tester.startGesture(tester.getCenter(find.text('Book Now')));
      await tester.pump(const Duration(milliseconds: 50));
      final scale = tester.widget<AnimatedScale>(find.byType(AnimatedScale).first);
      expect(scale.scale, lessThan(1.0));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 150));
    });

    testWidgets('disabled: tap is ignored, disabled colors applied', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(TaButton(label: 'Go', isEnabled: false, onTap: () => tapped = true)),
      );
      await tester.tap(find.text('Go'));
      expect(tapped, isFalse);
    });

    testWidgets('loading: shows spinner and ignores taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(TaButton(label: 'Go', isLoading: true, onTap: () => tapped = true)),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.byType(TaButton));
      expect(tapped, isFalse);
    });

    testWidgets('variants render', (tester) async {
      for (final variant in TaButtonVariant.values) {
        await tester.pumpWidget(wrap(TaButton(label: 'Go', variant: variant)));
        expect(find.text('Go'), findsOneWidget);
      }
    });
  });

  group('TaIconButton', () {
    testWidgets('tappable with optional dot', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(TaIconButton(
          icon: const Icon(Icons.notifications),
          showDot: true,
          onTap: () => tapped = true,
        )),
      );
      expect(find.byIcon(Icons.notifications), findsOneWidget);
      await tester.tap(find.byType(TaIconButton));
      expect(tapped, isTrue);
    });
  });

  group('TaTextField', () {
    testWidgets('types text and reports change', (tester) async {
      String? changed;
      await tester.pumpWidget(wrap(
        SizedBox(
          width: 300,
          child: TaTextField(prefix: const Text('+855'), onChanged: (v) => changed = v),
        ),
      ));
      await tester.enterText(find.byType(TextField), '012345678');
      expect(changed, '012345678');
      expect(find.text('+855'), findsOneWidget);
    });

    testWidgets('error: renders error caption', (tester) async {
      await tester.pumpWidget(wrap(const SizedBox(
        width: 300,
        child: TaTextField(errorText: 'Invalid number'),
      )));
      expect(find.text('Invalid number'), findsOneWidget);
    });
  });

  group('TaOtpField', () {
    testWidgets('advances focus and completes', (tester) async {
      String? code;
      await tester.pumpWidget(wrap(
        SizedBox(width: 300, child: TaOtpField(onComplete: (v) => code = v)),
      ));
      final fields = find.byType(TextField);
      expect(fields, findsNWidgets(4));
      for (var i = 0; i < 4; i++) {
        await tester.enterText(fields.at(i), '${i + 1}');
        await tester.pump();
      }
      expect(code, '1234');
    });

    testWidgets('empty input does not submit', (tester) async {
      String? code;
      await tester.pumpWidget(wrap(
        SizedBox(width: 300, child: TaOtpField(onComplete: (v) => code = v)),
      ));
      await tester.pump();
      expect(code, isNull);
    });
  });

  group('TaAvatar', () {
    testWidgets('renders initials for each variant', (tester) async {
      for (final variant in TaAvatarVariant.values) {
        await tester.pumpWidget(wrap(TaAvatar(variant: variant, initials: 'SL')));
        if (variant == TaAvatarVariant.register) {
          expect(find.byIcon(Icons.person), findsWidgets);
        } else {
          expect(find.text('SL'), findsOneWidget);
        }
      }
    });

    testWidgets('register variant exposes camera button', (tester) async {
      var cameraTapped = false;
      await tester.pumpWidget(wrap(
        TaAvatar(variant: TaAvatarVariant.register, onCameraTap: () => cameraTapped = true),
      ));
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      await tester.tap(find.byIcon(Icons.camera_alt));
      expect(cameraTapped, isTrue);
    });
  });

  group('TaBadge', () {
    testWidgets('renders each variant label', (tester) async {
      for (final variant in TaBadgeVariant.values) {
        await tester.pumpWidget(wrap(TaBadge(label: 'OK', variant: variant)));
        expect(find.text('OK'), findsOneWidget);
      }
    });
  });

  group('TaCard', () {
    testWidgets('wraps child and handles tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaCard(onTap: () => tapped = true, child: const Text('hi'))));
      expect(find.text('hi'), findsOneWidget);
      await tester.tap(find.byType(TaCard));
      expect(tapped, isTrue);
    });
  });

  group('TaSegment', () {
    testWidgets('shows active selection', (tester) async {
      var changedTo = -1;
      await tester.pumpWidget(wrap(TaSegment(
        options: const ['EN', 'KH'],
        selectedIndex: 1,
        onChanged: (i) => changedTo = i,
      )));
      await tester.tap(find.text('EN'));
      expect(changedTo, 0);
      expect(find.text('EN'), findsOneWidget);
      expect(find.text('KH'), findsOneWidget);
    });
  });

  group('TaStepIndicator', () {
    testWidgets('renders all steps with current elevated', (tester) async {
      await tester.pumpWidget(wrap(const TaStepIndicator(steps: 3, current: 1)));
      expect(find.byType(TaStepIndicator), findsOneWidget);
    });
  });

  group('TaKVRow', () {
    testWidgets('shows label and value', (tester) async {
      await tester.pumpWidget(wrap(const TaKVRow(label: 'Distance', value: '6.1 km')));
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('6.1 km'), findsOneWidget);
    });
  });

  group('TaSearchCard', () {
    testWidgets('label and tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaSearchCard(onTap: () => tapped = true)));
      expect(find.text('Where to?'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      await tester.tap(find.byType(TaSearchCard));
      expect(tapped, isTrue);
    });
  });

  group('TaSearchResult', () {
    testWidgets('renders name, keyword, distance', (tester) async {
      await tester.pumpWidget(wrap(const TaSearchResult(
        name: 'Wat Phnom',
        keyword: 'Phnom Penh',
        distance: '2.4 km',
      )));
      expect(find.text('Wat Phnom'), findsOneWidget);
      expect(find.text('Phnom Penh'), findsOneWidget);
      expect(find.text('2.4 km'), findsOneWidget);
    });
  });

  group('TaNoteField', () {
    testWidgets('accepts input', (tester) async {
      String? note;
      await tester.pumpWidget(wrap(
        SizedBox(width: 300, child: TaNoteField(onChanged: (v) => note = v)),
      ));
      await tester.enterText(find.byType(TextField), 'Ring twice');
      expect(note, 'Ring twice');
    });
  });

  group('TaChip', () {
    testWidgets('reports tap and selected state', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaChip(label: 'Polite', onTap: () => tapped = true)));
      expect(find.text('Polite'), findsOneWidget);
      await tester.tap(find.byType(TaChip));
      expect(tapped, isTrue);
      await tester.pumpWidget(wrap(const TaChip(label: 'Polite', isSelected: true)));
      expect(find.text('Polite'), findsOneWidget);
    });
  });

  group('TaStarRating', () {
    testWidgets('reports tapped star 1-based', (tester) async {
      int? selected;
      await tester.pumpWidget(wrap(TaStarRating(rating: 0, onChanged: (i) => selected = i)));
      final stars = find.byType(Icon);
      await tester.tap(stars.at(2));
      await tester.pump(const Duration(milliseconds: 400));
      expect(selected, 3);
    });
  });

  group('TaSkeleton', () {
    testWidgets('renders shimmer block and card (pump, no settle: repeating animation)', (tester) async {
      await tester.pumpWidget(wrapFull(const TaSkeletonCard(children: [
        Row(children: [
          TaSkeleton(width: 84, height: 52),
          SizedBox(width: 12),
          TaSkeleton(width: 120, height: 16),
        ]),
      ])));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TaSkeleton), findsNWidgets(2));
    });

    testWidgets('circle skeleton renders', (tester) async {
      await tester.pumpWidget(wrap(const TaSkeleton(width: 44, height: 44, circle: true)));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(TaSkeleton), findsOneWidget);
    });
  });

  group('TaToast', () {
    testWidgets('shows then auto-dismisses (no settle: timer-based)', (tester) async {
      await tester.pumpWidget(wrapFull(const SizedBox()));
      TaToast.show(tester.element(find.byType(SizedBox)), 'Saved');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 2600));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Saved'), findsNothing);
    });
  });

  group('TaDialog', () {
    testWidgets('shows title, body and actions', (tester) async {
      await tester.pumpWidget(wrapFull(const SizedBox()));
      TaDialog.show(
        tester.element(find.byType(SizedBox)),
        title: 'Cancel booking?',
        body: 'Your driver is on the way.',
        actions: [const TaButton(label: 'Keep booking', onTap: null)],
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Cancel booking?'), findsOneWidget);
      expect(find.text('Your driver is on the way.'), findsOneWidget);
      expect(find.text('Keep booking'), findsOneWidget);
    });
  });

  group('TaBottomSheet', () {
    testWidgets('presents grab handle and content', (tester) async {
      await tester.pumpWidget(wrapFull(const SizedBox()));
      TaBottomSheet.show(tester.element(find.byType(SizedBox)), const Text('sheet content'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('sheet content'), findsOneWidget);
    });
  });

  group('TaLoadingOverlay', () {
    testWidgets('renders spinner, title and cancel (pump, not settle)', (tester) async {
      var cancelled = false;
      await tester.pumpWidget(wrapFull(TaLoadingOverlay(onCancel: () => cancelled = true)));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Finding your driver…'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });
  });

  group('TaBottomNav', () {
    testWidgets('switches active tab', (tester) async {
      var index = 0;
      await tester.pumpWidget(wrapFull(TaBottomNav(
        items: const [
          TaNavItem(icon: Icons.home, label: 'Home'),
          TaNavItem(icon: Icons.event, label: 'My Booking'),
          TaNavItem(icon: Icons.person, label: 'Profile'),
        ],
        currentIndex: 0,
        onChanged: (i) => index = i,
      )));
      await tester.tap(find.text('My Booking'));
      expect(index, 1);
    });
  });

  group('TaAddressRow', () {
    testWidgets('renders pickup and destination rows', (tester) async {
      await tester.pumpWidget(wrap(const Column(
        children: [
          TaAddressRow(type: TaAddressType.pickup, label: 'From', name: 'Home'),
          TaAddressRow(type: TaAddressType.destination, label: 'To', name: 'Airport'),
        ],
      )));
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Airport'), findsOneWidget);
    });
  });

  group('TaStatRow', () {
    testWidgets('renders values and labels', (tester) async {
      await tester.pumpWidget(wrap(const TaStatRow(items: [
        StatItem(value: '6.1 km', label: 'Distance'),
        StatItem(value: '18 min', label: 'Duration'),
        StatItem(value: '\$4.85', label: 'Fare'),
      ])));
      expect(find.text('6.1 km'), findsOneWidget);
      expect(find.text('Distance'), findsOneWidget);
      expect(find.text('\$4.85'), findsOneWidget);
    });
  });

  group('TaVehicleRow', () {
    testWidgets('full row: selectable, fires tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaVehicleRow(
        vehicle: const VehicleData(
          name: 'Standard',
          seats: '3',
          pricePerKm: '\$0.45/km',
          priceFrom: '\$1.00',
          eta: '3 min',
        ),
        onTap: () => tapped = true,
      )));
      expect(find.text('Standard'), findsOneWidget);
      await tester.tap(find.text('Standard'));
      expect(tapped, isTrue);
      await tester.pumpWidget(wrap(const TaVehicleRow(
        vehicle: VehicleData(
          name: 'Standard',
          seats: '3',
          pricePerKm: '\$0.45/km',
          priceFrom: '\$1.00',
          eta: '3 min',
        ),
        isSelected: true,
      )));
      expect(find.text('Standard'), findsOneWidget);
    });

    testWidgets('compact row: tariff pill', (tester) async {
      var tariffTapped = false;
      await tester.pumpWidget(wrap(TaVehicleRow(
        compact: true,
        vehicle: const VehicleData(
          name: 'Vip',
          seats: '4',
          pricePerKm: '\$0.70/km',
          priceFrom: '\$3.00',
          eta: '5 min',
        ),
        onTariffTap: () => tariffTapped = true,
      )));
      expect(find.text('Tariff'), findsOneWidget);
      await tester.tap(find.text('Tariff'));
      expect(tariffTapped, isTrue);
    });
  });

  group('TaDriverCard', () {
    testWidgets('renders name, vehicle and plate', (tester) async {
      await tester.pumpWidget(wrap(const TaDriverCard(
        name: 'Sokha',
        rating: '4.9',
        vehicleInfo: 'Toyota Camry · White',
        plateNumber: 'PP-1234',
        initials: 'S',
      )));
      expect(find.text('Sokha'), findsOneWidget);
      expect(find.text('PP-1234'), findsOneWidget);
    });
  });

  group('TaTotalBox', () {
    testWidgets('renders label and amount', (tester) async {
      await tester.pumpWidget(wrap(const TaTotalBox(amount: '\$4.85')));
      expect(find.text('\$4.85'), findsOneWidget);
      expect(find.text('Total · Cash'), findsOneWidget);
    });
  });

  group('TaPromoBanner', () {
    testWidgets('renders tag, title, subtitle', (tester) async {
      await tester.pumpWidget(wrap(const TaPromoBanner(
        title: '10% off your next ride',
        subtitle: 'Use code TAARRAA10',
      )));
      expect(find.text('PROMO'), findsOneWidget);
      expect(find.text('10% off your next ride'), findsOneWidget);
    });
  });

  group('TaTimeline', () {
    testWidgets('renders steps for current position (no settling: static)', (tester) async {
      await tester.pumpWidget(wrapFull(const TaTimeline(currentStep: 1)));
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Arriving'), findsOneWidget);
      expect(find.text('On trip'), findsOneWidget);
    });
  });

  group('TaStatusPill', () {
    testWidgets('renders text (pump not settle: pulsing)', (tester) async {
      await tester.pumpWidget(wrap(const TaStatusPill(text: 'Payment received')));
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Payment received'), findsOneWidget);
    });
  });

  group('TaHistoryCard', () {
    testWidgets('renders invoice, driver, amount, route, badge', (tester) async {
      await tester.pumpWidget(wrap(const TaHistoryCard(
        item: HistoryItem(
          invoice: 'INV-000123',
          driver: 'Sokha',
          date: '12 Sep',
          amount: '\$4.50',
          from: 'Home',
          to: 'Airport',
          distance: '6.1 km',
          duration: '18 min',
          initials: 'S',
        ),
      )));
      expect(find.text('INV-000123'), findsOneWidget);
      expect(find.text('\$4.50'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });

    testWidgets('cancelled variant shows error badge', (tester) async {
      await tester.pumpWidget(wrap(const TaHistoryCard(
        item: HistoryItem(
          invoice: 'INV-000124',
          driver: 'Sokha',
          date: '11 Sep',
          amount: '\$0.00',
          from: 'Home',
          to: 'Airport',
          distance: '0 km',
          duration: '0 min',
          initials: 'S',
        ),
        isCompleted: false,
      )));
      expect(find.text('Cancelled'), findsOneWidget);
    });
  });

  group('TaProfileRow', () {
    testWidgets('renders label, chevron, tap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(TaProfileRow(
        icon: const Icon(Icons.description),
        label: 'Terms',
        onTap: () => tapped = true,
      )));
      expect(find.text('Terms'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      await tester.tap(find.text('Terms'));
      expect(tapped, isTrue);
    });

    testWidgets('danger variant hides chevron', (tester) async {
      await tester.pumpWidget(wrap(const TaProfileRow(
        icon: Icon(Icons.logout),
        label: 'Logout',
        isDanger: true,
      )));
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('TaMinMaxSheet', () {
    testWidgets('tariff pill opens sheet with KV rows', (tester) async {
      await tester.pumpWidget(wrapFull(const Center(
        child: TaMinMaxSheet(
          vehicleName: 'Standard',
          minFee: '\$1.00',
          pricePerKm: '\$0.45',
          seats: '3',
        ),
      )));
      expect(find.text('Tariff'), findsOneWidget);
      await tester.tap(find.text('Tariff'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Standard · Tariff'), findsOneWidget);
      expect(find.text('Min fee'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
    });
  });
}