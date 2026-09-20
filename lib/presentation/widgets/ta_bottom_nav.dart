import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

/// Floating pill bottom navigation (`.tabbar`) — component spec §31.
///
/// Inset 12px from the edges, radius 22, shadowLg. Active tab gets the
/// brand-50 pill.
class TaBottomNav extends StatelessWidget {
  const TaBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    this.onChanged,
  });

  final List<TaNavItem> items;
  final int currentIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 12, end: 12, bottom: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: TaShadows.shadowLg,
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: _TaNavButton(
                item: items[i],
                isActive: i == currentIndex,
                onTap: onChanged == null ? null : () => onChanged!(i),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TaNavButton extends StatefulWidget {
  const _TaNavButton({
    required this.item,
    required this.isActive,
    this.onTap,
  });

  final TaNavItem item;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<_TaNavButton> createState() => _TaNavButtonState();
}

class _TaNavButtonState extends State<_TaNavButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive ? TaColors.primaryBg : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(widget.isActive),
              const SizedBox(height: 3),
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isActive ? TaColors.primary : TaColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool isActive) {
    final item = widget.item;
    if (item.activeIcon != null || item.inactiveIcon != null) {
      return (isActive ? item.activeIcon : item.inactiveIcon) ?? const SizedBox.shrink();
    }
    return Icon(
      item.icon,
      size: 22,
      color: isActive ? TaColors.primary : TaColors.textMuted,
    );
  }
}

class TaNavItem {
  const TaNavItem({required this.label, this.icon, this.activeIcon, this.inactiveIcon});

  final String label;

  /// Material icon fallback used when [activeIcon]/[inactiveIcon] are null.
  final IconData? icon;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
}