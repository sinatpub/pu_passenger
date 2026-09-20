import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/logic.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 1 — Splash.
///
/// `SplashLogic._checkAuthorization` owns the gate (P-01: `SessionService`,
/// falling back to login on any failure) and is untouched. The prototype's
/// "Skip →" link is **not** built — `D14` lists it as demo-only, and
/// production auto-navigates once the token check lands.
class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashLogic splashLogic = Get.put(SplashLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SplashLogoBadge(),
              const SizedBox(height: 16),
              Text(
                'TAARRAA',
                style: TaTextStyles.displayLarge.copyWith(
                  fontSize: 30,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppLocale.taarraaTaxiSubtitle.tr,
                style: TaTextStyles.titleMedium
                    .copyWith(color: TaColors.primary),
              ),
              const SizedBox(height: 34),
              const SplashLoadingBar(),
            ],
          ),
        ),
      ),
    );
  }
}

/// The 96px gradient badge, popping in on open (`03 §Screen 1`).
class SplashLogoBadge extends StatefulWidget {
  const SplashLogoBadge({super.key});

  @override
  State<SplashLogoBadge> createState() => _SplashLogoBadgeState();
}

class _SplashLogoBadgeState extends State<SplashLogoBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: Motion.base,
  )..forward();

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _pop,
        curve: const Cubic(0.2, 0.9, 0.3, 1.2),
      ),
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF6A00), TaColors.primary, Color(0xFFE63E00)],
            stops: [0, 0.6, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: TaColors.primary.withValues(alpha: 0.4),
              blurRadius: 40,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: const Icon(Icons.star, size: 52, color: Colors.white),
      ),
    );
  }
}

/// The indeterminate 120×5 bar. It reports that work is happening; it is not
/// tied to the token check's progress, which has none to report.
class SplashLoadingBar extends StatefulWidget {
  const SplashLoadingBar({super.key});

  @override
  State<SplashLoadingBar> createState() => _SplashLoadingBarState();
}

class _SplashLoadingBarState extends State<SplashLoadingBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _slide = AnimationController(
    vsync: this,
    duration: Motion.ambient,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // P1 — the bar holds still under reduced motion. The splash still hands
    // off on `SplashLogic._checkAuthorization`, which is a real `Future`, not
    // this controller, so the gate is unaffected either way.
    applyAmbientMotion(context, _slide, restingValue: 0);
  }

  @override
  void dispose() {
    _slide.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 120,
        height: 5,
        color: const Color(0xFFE4E5EB),
        child: AnimatedBuilder(
          animation: _slide,
          builder: (context, _) => Align(
            // Travels from fully left to fully right across the track.
            alignment: Alignment(-1 + 2 * _slide.value, 0),
            child: Container(
              width: 48,
              decoration: BoxDecoration(
                color: TaColors.primary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
