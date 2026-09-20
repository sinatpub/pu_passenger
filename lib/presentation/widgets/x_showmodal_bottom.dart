import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Draggable bottom sheet (roadmap F3 re-skin, configurable background).
///
/// Signature and drag/expand behavior unchanged — only the chrome is
/// token-driven: 22px top radius, 44×5 grab handle, dark backdrop fade.
Future xShowModalBottomSheet({
  required BuildContext context,
  bool useRootNavigator = true,
  bool isScrollControlled = true,
  double initialChildSize = 0.7,
  double maxChildSize = 1.0,
  double minChildSize = 0.4,
  Color? backgroundColor,
  bool expand = false,
  required Widget Function(BuildContext, ScrollController) body,
}) async {
  return await showModalBottomSheet(
    context: context,
    useRootNavigator: useRootNavigator,
    useSafeArea: true,
    // P1 — the slide-up collapses to nothing once the viewer has asked for
    // reduced motion; the barrier still fades, so the sheet does not appear
    // out of nowhere.
    sheetAnimationStyle: AnimationStyle(
      duration: motionDuration(context, Motion.base),
      reverseDuration: motionDuration(context, Motion.base),
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOut,
    ),
    isScrollControlled: isScrollControlled,
    barrierColor: TaColors.overlay,
    shape: _sheetShape,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: initialChildSize,
        maxChildSize: maxChildSize,
        minChildSize: minChildSize,
        expand: expand,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? TaColors.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 14),
                  child: TaGrabHandle(),
                ),
                Expanded(
                  child: body(context, scrollController),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

const _sheetShape = RoundedRectangleBorder(
  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
);