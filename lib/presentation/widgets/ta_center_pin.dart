import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:com.tara.passenger/core/resources/asset_resource.dart';

/// The fixed pin drawn over the centre of a map whose camera target is the
/// point being chosen (Screen 3 pickup, Screen 7 map, Screen 8 drag map).
///
/// Place it under a `Center` over the map. It shifts itself up so the pin's
/// *tip* — not the centre of its box — sits on the map centre, which is the
/// point the screen commits. `current_marker.svg` is 39×52 with the tip at
/// y≈46; drawn `contain` in a square box it fills the height, so the tip is
/// at 46/52 of [size].
class TaCenterPin extends StatelessWidget {
  const TaCenterPin({
    super.key,
    required this.size,
    this.lifted = false,
    this.callout,
    this.calloutGap = 12,
  });

  /// Edge of the square box the pin is drawn in.
  final double size;

  /// Raises the pin while the camera is moving. The tip returns to the
  /// centre when it settles.
  final bool lifted;

  /// Optional label floating above the pin, centred on it.
  final Widget? callout;

  /// Space between the top of the pin's box and the bottom of [callout].
  final double calloutGap;

  static const double _tipY = 46 / 52;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -size * (_tipY - 0.5)),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (callout != null)
            Positioned(bottom: size + calloutGap, child: callout!),
          AnimatedSlide(
            offset: lifted ? const Offset(0, -0.4) : Offset.zero,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: SvgPicture.asset(
              ImageAssets.currentMarker,
              width: size,
              height: size,
            ),
          ),
        ],
      ),
    );
  }
}
