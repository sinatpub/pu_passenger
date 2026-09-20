import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Bottom sheet (`.sheet`) — component spec §27.
///
/// Rounded-top white sheet (22px), grab handle, backdrop
/// `rgba(15,17,25,.5)`, up to 82% height, scrollable content.
class TaBottomSheet {
  TaBottomSheet._();

  static Future<T?> show<T>(BuildContext context, Widget child) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      barrierColor: TaColors.overlay,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.82,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 12, bottom: 14),
              child: TaGrabHandle(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shared grab handle used by [TaBottomSheet] and the re-skinned legacy
/// sheet helpers (`gShowModalBottomSheet` / `xShowModalBottomSheet`).
class TaGrabHandle extends StatelessWidget {
  const TaGrabHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: TaColors.disabledBg,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}