import 'package:flutter/widgets.dart';

/// Motion tokens and the reduced-motion rule (roadmap P1,
/// `02-design-system.md` §Animations).
///
/// Two rules the app holds to:
///
/// 1. **No one-shot transition runs longer than [kMotionBase].** The map
///    camera is the documented exception — it is the user's own gesture being
///    continued, not chrome.
/// 2. **A real timer is never an `AnimationController`.** Flutter scales a
///    controller's duration to 5% when the OS asks for animations off, so a
///    countdown built on one fires ~20× early. Every timed behaviour in this
///    app (the OTP countdown, the booking poll, the toast dismiss, the pickup
///    debounce) is a `Timer` or `Future.delayed` and is unaffected —
///    `motion_test.dart` and the P1 notes record that, so it stays true.
abstract final class Motion {
  /// Press feedback and colour/border changes.
  static const Duration fast = Duration(milliseconds: 120);

  /// Step changes, chips, small reveals.
  static const Duration medium = Duration(milliseconds: 200);

  /// The ceiling for anything one-shot: sheets, dialogs, pops.
  static const Duration base = Duration(milliseconds: 280);

  /// Ambient loops — shimmer, pulse, bounce. These repeat forever by design,
  /// so they are exempt from the [base] ceiling but **must** stop when the
  /// viewer has asked for reduced motion.
  static const Duration ambient = Duration(milliseconds: 1100);
}

/// Whether this viewer has asked the OS to remove animations.
///
/// `maybeDisableAnimationsOf` rather than `of` so a widget pumped without a
/// `MediaQuery` (several of our widget tests) reads as "animate normally"
/// instead of throwing.
bool prefersReducedMotion(BuildContext context) =>
    MediaQuery.maybeDisableAnimationsOf(context) ?? false;

/// A duration that collapses to zero when the viewer wants no motion.
///
/// Use for one-shot transitions: the widget still rebuilds into its final
/// state, it just gets there immediately.
Duration motionDuration(BuildContext context, Duration duration) =>
    prefersReducedMotion(context) ? Duration.zero : duration;

/// Drives an ambient, repeating [AnimationController] according to the
/// viewer's motion preference.
///
/// Repeating when motion is off is the thing that actually bothers people, so
/// the loop stops and the controller is parked at [restingValue] — the value
/// that renders the resting, fully-visible frame.
void applyAmbientMotion(
  BuildContext context,
  AnimationController controller, {
  double restingValue = 1,
}) {
  if (prefersReducedMotion(context)) {
    if (controller.isAnimating) controller.stop();
    controller.value = restingValue;
  } else if (!controller.isAnimating) {
    controller.repeat();
  }
}
