import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

/// Active ride status indicator (`.status-pill`) — component spec §14.
class TaStatusPill extends StatefulWidget {
  const TaStatusPill({
    super.key,
    required this.text,
    this.isPulsing = true,
  });

  final String text;
  final bool isPulsing;

  @override
  State<TaStatusPill> createState() => _TaStatusPillState();
}

class _TaStatusPillState extends State<TaStatusPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: Motion.ambient,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _applyMotion();
  }

  @override
  void didUpdateWidget(covariant TaStatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _applyMotion();
  }

  /// P1 — the pulse stops both when the caller turns it off and when the
  /// viewer has asked the OS to remove animations. A dot pulsing forever is
  /// exactly the kind of motion that setting exists to silence.
  void _applyMotion() {
    if (!widget.isPulsing) {
      _pulse.stop();
      _pulse.value = 1;
      return;
    }
    applyAmbientMotion(context, _pulse);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: TaColors.dark,
        borderRadius: BorderRadius.circular(99),
        boxShadow: TaShadows.shadowLg,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 1, end: 0.35).animate(
              CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
            ),
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFF4ADE80),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}