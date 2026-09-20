import 'package:flutter/material.dart';

/// Shared press-scale wrapper implementing the component-spec press
/// animation rule: `scale(0.97) — 100ms`.
///
/// Internal helper used by the Ta- components; presentational only.
class TaPressable extends StatefulWidget {
  const TaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.duration = const Duration(milliseconds: 100),
    this.behavior = HitTestBehavior.opaque,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final Duration duration;
  final HitTestBehavior behavior;

  @override
  State<TaPressable> createState() => _TaPressableState();
}

class _TaPressableState extends State<TaPressable> {
  bool _pressed = false;

  void _set(bool value) {
    if (widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTap: widget.onTap,
      onTapDown: (_) => _set(true),
      onTapCancel: () => _set(false),
      onTapUp: (_) => _set(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}