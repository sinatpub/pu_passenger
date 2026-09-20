import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';

/// Modal dialog (`.dialog`) — component spec §26.
///
/// Centered white card, `pop` scale-in animation, barrier
/// `rgba(15,17,25,.5)`. Callers pass actions rendered full-width side by side.
class TaDialog {
  TaDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String body,
    required List<Widget> actions,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: title,
      barrierColor: TaColors.overlay,
      transitionDuration: motionDuration(context, Motion.base),
      pageBuilder: (context, animation, secondaryAnimation) =>
          TaDialogCard(title: title, body: body, actions: actions),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        // P1 §Verification — "sheets/dialogs fade only" once the viewer has
        // asked for reduced motion. A pop-in scale is the part that reads as
        // motion; the fade keeps the dialog from appearing out of nowhere.
        if (prefersReducedMotion(context)) {
          return FadeTransition(opacity: animation, child: child);
        }
        final curved = CurvedAnimation(
          parent: animation,
          curve: const Cubic(0.2, 0.9, 0.3, 1.2),
        );
        return ScaleTransition(scale: curved, child: child);
      },
    );
  }
}

class TaDialogCard extends StatelessWidget {
  const TaDialogCard({
    super.key,
    required this.title,
    required this.body,
    required this.actions,
  });

  final String title;
  final String body;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: TaColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: TaColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}