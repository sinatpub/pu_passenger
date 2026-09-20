import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Taarraa primary CTA button (`.btn`) — component spec §1.
///
/// Presentational: takes pre-formatted `label`; validation/loading state is
/// driven by the caller through `isLoading`/`isEnabled`.
class TaButton extends StatelessWidget {
  const TaButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.isEnabled = true,
    this.variant = TaButtonVariant.primary,
    this.size = TaButtonSize.large,
    this.width,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool isEnabled;
  final TaButtonVariant variant;
  final TaButtonSize size;
  final double? width;

  bool get _interactive => isEnabled && !isLoading && onTap != null;

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled;
    final height = size == TaButtonSize.large ? 52.0 : 44.0;
    final radius = size == TaButtonSize.large ? TaRadius.radiusLg : TaRadius.radiusMd;
    final fontSize = size == TaButtonSize.large ? 16.0 : 14.0;

    return TaPressable(
      onTap: _interactive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: height,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: _background(enabled),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: _borderColor(enabled)),
          boxShadow: _boxShadow(enabled),
        ),
        child: isLoading
            ? SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _foreground(enabled),
                ),
              )
            : Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  color: _foreground(enabled),
                ),
              ),
      ),
    );
  }

  Color _background(bool enabled) {
    if (!enabled) return TaColors.disabledBg;
    switch (variant) {
      case TaButtonVariant.primary:
        return TaColors.primary;
      case TaButtonVariant.dark:
        return TaColors.dark;
      case TaButtonVariant.ghost:
        return TaColors.surface;
      case TaButtonVariant.dangerGhost:
        return TaColors.errorBg;
    }
  }

  Color _borderColor(bool enabled) {
    if (variant == TaButtonVariant.ghost) {
      return TaColors.border;
    }
    return Colors.transparent;
  }

  List<BoxShadow>? _boxShadow(bool enabled) {
    if (!enabled) return null;
    switch (variant) {
      case TaButtonVariant.primary:
        return [
          BoxShadow(
            color: TaColors.primary.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
      case TaButtonVariant.dark:
        return [
          BoxShadow(
            color: TaColors.dark.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ];
      case TaButtonVariant.ghost:
        return TaShadows.shadowSm;
      case TaButtonVariant.dangerGhost:
        return null;
    }
  }

  Color _foreground(bool enabled) {
    if (!enabled) return TaColors.disabledText;
    switch (variant) {
      case TaButtonVariant.primary:
      case TaButtonVariant.dark:
        return Colors.white;
      case TaButtonVariant.ghost:
        return TaColors.textPrimary;
      case TaButtonVariant.dangerGhost:
        return TaColors.error;
    }
  }
}

enum TaButtonVariant { primary, dark, ghost, dangerGhost }

enum TaButtonSize { large, small }