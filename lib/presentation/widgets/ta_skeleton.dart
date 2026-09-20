import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

/// Shimmer loading block (`.skel` inner skeleton) — component spec §29.
///
/// Renders a rounded rectangle/circle with a 1.1s travelling sheen. Compose
/// several inside a white [TaSkeletonCard] to mirror a screen layout.
class TaSkeleton extends StatefulWidget {
  const TaSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.radius = 8,
    this.circle = false,
  });

  final double width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<TaSkeleton> createState() => _TaSkeletonState();
}

class _TaSkeletonState extends State<TaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.ambient,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // P1 — a shimmering placeholder still reads as "loading" when it holds
    // still, so the loop stops rather than the skeleton disappearing.
    applyAmbientMotion(context, _controller, restingValue: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: widget.circle ? Border.all(color: TaColors.surface, width: 0) : null,
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return ShaderMask(
              blendMode: BlendMode.srcATop,
              shaderCallback: (bounds) {
                final dx = _controller.value * 2 - 1;
                return LinearGradient(
                  begin: Alignment(-1.0 * dx, 0),
                  end: Alignment(dx, 0),
                  colors: const [
                    Color(0xFFEDEEF2),
                    Color(0xFFF7F7FA),
                    Color(0xFFEDEEF2),
                  ],
                  stops: const [0.35, 0.5, 0.65],
                ).createShader(bounds);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEEF2),
                  borderRadius: widget.circle
                      ? null
                      : BorderRadius.circular(widget.radius),
                  shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// White card containing skeleton blocks (`.skel` container) —
/// component spec §29.
class TaSkeletonCard extends StatelessWidget {
  const TaSkeletonCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 10),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TaShadows.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}