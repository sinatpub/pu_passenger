import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:flutter/material.dart';

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
    sheetAnimationStyle: AnimationStyle(
      duration: Duration(milliseconds: 300),
      reverseDuration: Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
      reverseCurve: Curves.easeOut,
    ),
    isScrollControlled: isScrollControlled,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0),
    ),
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 4,
                    width: 32,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.dark1,
                    ),
                  ),
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
