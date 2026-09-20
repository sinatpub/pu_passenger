import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';

/// P1 — motion tokens, the reduced-motion rule, and the guard that keeps a
/// real timer from ever being an `AnimationController`.
void main() {
  group('Motion tokens honour the ~300ms ceiling', () {
    test('every one-shot token is at or under 300ms', () {
      // Roadmap P1 Done When: "Nothing animates longer than ~300 ms except
      // the map camera."
      for (final d in [Motion.fast, Motion.medium, Motion.base]) {
        expect(d.inMilliseconds, lessThanOrEqualTo(300));
      }
    });

    test('the ambient token is exempt, because it loops by design', () {
      expect(Motion.ambient.inMilliseconds, greaterThan(300));
    });
  });

  group('prefersReducedMotion', () {
    testWidgets('false by default', (tester) async {
      late bool reduced;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              reduced = prefersReducedMotion(context);
              return const SizedBox();
            },
          ),
        ),
      );
      expect(reduced, isFalse);
    });

    testWidgets('true when the OS asks for animations off', (tester) async {
      late bool reduced;
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                reduced = prefersReducedMotion(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );
      expect(reduced, isTrue);
    });
  });

  group('motionDuration', () {
    testWidgets('collapses to zero under reduced motion', (tester) async {
      late Duration normal;
      late Duration reduced;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              normal = motionDuration(context, Motion.base);
              return MediaQuery(
                data: const MediaQueryData(disableAnimations: true),
                child: Builder(
                  builder: (context) {
                    reduced = motionDuration(context, Motion.base);
                    return const SizedBox();
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(normal, Motion.base);
      expect(reduced, Duration.zero);
    });
  });

  group('ambient animations stop under reduced motion', () {
    testWidgets('TaStatusPill pulses normally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TaStatusPill(text: 'On trip'))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // A repeating controller never settles.
      expect(tester.hasRunningAnimations, isTrue);
      // Leave it settled so the test can tear down cleanly.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });

    testWidgets('TaStatusPill holds still under reduced motion',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(
            home: Scaffold(body: TaStatusPill(text: 'On trip')),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        tester.hasRunningAnimations,
        isFalse,
        reason: 'a dot pulsing forever is what that OS setting exists to stop',
      );
    });

    testWidgets('TaSkeleton shimmers normally', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TaSkeleton(height: 20))),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });

    testWidgets('TaSkeleton holds still under reduced motion, but still renders',
        (tester) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: MaterialApp(home: Scaffold(body: TaSkeleton(height: 20))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.hasRunningAnimations, isFalse);
      // A still placeholder still reads as "loading" — it must not vanish.
      expect(find.byType(TaSkeleton), findsOneWidget);
    });
  });

  group('no real timer is an AnimationController (P1 Done When)', () {
    test('the timed behaviours are Timer / Future.delayed, not controllers',
        () {
      // Flutter scales an AnimationController to 5% of its duration when the
      // OS disables animations, so a countdown built on one fires ~20x early —
      // the driver-app bug P1 calls out. This asserts the shape rather than
      // trusting a comment.
      final cases = {
        // path -> the timed behaviour it owns
        'lib/presentation/screens/otp/logic.dart': 'the OTP resend countdown',
        'lib/presentation/screens/booking_map_screen/logic.dart':
            'the 10s booking poll',
        'lib/presentation/widgets/ta_toast.dart': 'the toast auto-dismiss',
        'lib/presentation/shared/map_drag/logic.dart':
            'the pickup-address debounce',
      };

      for (final entry in cases.entries) {
        final source = File(entry.key).readAsStringSync();
        expect(
          source.contains('AnimationController'),
          isFalse,
          reason: '${entry.value} lives in ${entry.key} and must stay a '
              'Timer/Future.delayed — an AnimationController there would fire '
              '~20x early with "remove animations" on',
        );
        expect(
          source.contains('Timer') || source.contains('Future.delayed'),
          isTrue,
          reason: '${entry.value} should be driven by a real timer',
        );
      }
    });
  });
}
