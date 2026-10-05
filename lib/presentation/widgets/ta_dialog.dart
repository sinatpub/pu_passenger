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
    Widget? leading,
    bool barrierDismissible = false,
  }) {
    return showCustom<void>(
      context,
      label: title,
      barrierDismissible: barrierDismissible,
      builder: (context) => TaDialogCard(
        title: title,
        body: body,
        actions: actions,
        leading: leading,
      ),
    );
  }

  /// A dialog whose content is the caller's own — the rating prompt, with
  /// its stars and chips — on the same barrier and with the same entrance as
  /// [show]. Completes with whatever the content pops with.
  static Future<T?> showCustom<T>(
    BuildContext context, {
    required String label,
    required WidgetBuilder builder,
    bool barrierDismissible = false,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: label,
      barrierColor: TaColors.overlay,
      transitionDuration: motionDuration(context, Motion.base),
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
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
    this.leading,
  });

  final String title;
  final String body;
  final List<Widget> actions;

  /// Optional mark above the title — a [TaDialogIcon] — saying at a glance
  /// what kind of news this is.
  final Widget? leading;

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
              if (leading != null) ...[
                leading!,
                const SizedBox(height: 14),
              ],
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

/// How serious the news in a dialog is. It colours [TaDialogIcon].
enum TaDialogTone { warning, error }

/// The round tinted mark above a dialog's title.
class TaDialogIcon extends StatelessWidget {
  const TaDialogIcon({super.key, required this.icon, required this.tone});

  final IconData icon;
  final TaDialogTone tone;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      TaDialogTone.warning => (TaColors.warningBg, TaColors.warning),
      TaDialogTone.error => (TaColors.errorBg, TaColors.error),
    };
    return ExcludeSemantics(
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 28, color: foreground),
      ),
    );
  }
}
