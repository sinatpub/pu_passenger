import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Docked bottom navigation (`.tabbar`) — component spec §31, D33.
///
/// Flush to the screen edges under a top hairline. The white runs down
/// behind the system gesture area while the tabs stay above it, so the
/// gesture handle never sits on a tab. The active tab is the brand colour
/// under a short indicator bar.
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
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: TaColors.surface,
        border: Border(top: BorderSide(color: TaColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _TaNavButton(
                    item: items[i],
                    isActive: i == currentIndex,
                    onTap: onChanged == null ? null : () => onChanged!(i),
                  ),
                ),
            ],
          ),
        ),
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
    final color = widget.isActive ? TaColors.primary : TaColors.textSecondary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hangs from the hairline, so it stays put while the tab below
          // it scales on press.
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: widget.isActive ? TaColors.primary : Colors.transparent,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(3)),
            ),
          ),
          AnimatedScale(
            scale: _pressed ? 0.97 : 1.0,
            duration: const Duration(milliseconds: 100),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 7, 4, 7),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildIcon(color),
                  const SizedBox(height: 3),
                  Text(
                    widget.item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(Color color) {
    final item = widget.item;
    if (item.activeIcon != null || item.inactiveIcon != null) {
      return (widget.isActive ? item.activeIcon : item.inactiveIcon) ??
          const SizedBox.shrink();
    }
    return Icon(item.icon, size: 22, color: color);
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
