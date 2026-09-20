import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/widgets/ta_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// Draggable bottom sheet (roadmap F3 re-skin).
///
/// Signature and drag/expand behavior unchanged — only the chrome is
/// token-driven: 22px top radius, 44×5 grab handle, dark backdrop fade.
Future<T?> gShowModalBottomSheet<T>({
  required BuildContext context,
  bool useRootNavigator = true,
  bool isScrollControlled = true,
  double initialChildSize = 0.6,
  double maxChildSize = 1.0,
  double minChildSize = 0.4,
  bool expand = false,
  required Widget Function(BuildContext, ScrollController) body,
}) async {
  return await showModalBottomSheet<T>(
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 14),
                  child: TaGrabHandle(),
                ),
                Expanded(child: body(context, scrollController)),
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