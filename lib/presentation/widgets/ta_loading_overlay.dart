import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

import 'ta_button.dart';

/// Full-screen booking loading overlay (`.bookov`) — component spec §30.
///
/// Nearly-opaque white backdrop, brand spinner, bouncing car icon, status
/// text and an optional danger-ghost cancel button.
class TaLoadingOverlay extends StatefulWidget {
  const TaLoadingOverlay({
    super.key,
    this.title = 'Finding your driver…',
    this.subtitle = 'Please wait — usually takes less than a minute',
    this.showCancel = true,
    this.onCancel,
  });

  final String title;
  final String subtitle;
  final bool showCancel;
  final VoidCallback? onCancel;

  @override
  State<TaLoadingOverlay> createState() => _TaLoadingOverlayState();
}

class _TaLoadingOverlayState extends State<TaLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: Motion.ambient,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // P1 — the car stops bouncing under reduced motion; the overlay's text
    // and spinner still say the booking is in flight.
    if (prefersReducedMotion(context)) {
      if (_bounce.isAnimating) _bounce.stop();
      _bounce.value = 0;
    } else if (!_bounce.isAnimating) {
      _bounce.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      color: Colors.white.withValues(alpha: 0.94),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 64,
            height: 64,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              color: TaColors.primary,
              backgroundColor: TaColors.primaryBorder,
            ),
          ),
          const SizedBox(height: 14),
          AnimatedBuilder(
            animation: _bounce,
            builder: (_, child) => Transform.translate(
              offset: Offset(0, -_bounce.value * 6),
              child: child,
            ),
            child: const Icon(Icons.directions_car, color: TaColors.primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: TaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            widget.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: TaColors.textSecondary,
            ),
          ),
          const SizedBox(height: 22),
          if (widget.showCancel)
            SizedBox(
              width: 220,
              child: TaButton(
                label: AppLocale.cancel.tr,
                variant: TaButtonVariant.dangerGhost,
                size: TaButtonSize.small,
                onTap: widget.onCancel,
              ),
            ),
        ],
      ),
    );
  }
}