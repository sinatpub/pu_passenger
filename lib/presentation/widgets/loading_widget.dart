import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:flutter/material.dart';

/// Full-screen loading overlay (roadmap F3 re-skin). Brand spinner on a
/// near-opaque white backdrop per `.bookov` spec (no text/cancel — generic
/// use at call sites).
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.94),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: const Center(
        child: SizedBox(
          width: 64,
          height: 64,
          child: CircularProgressIndicator(
            strokeWidth: 5,
            color: TaColors.primary,
            backgroundColor: TaColors.primaryBorder,
          ),
        ),
      ),
    );
  }
}