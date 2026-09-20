import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

/// Temporary feedback toast (`#toast`) — component spec §28.
///
/// Navy pill with mint check icon, auto-dismisses after 2400ms. No swipe to
/// dismiss and no type variants.
class TaToast {
  TaToast._();

  static void show(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _TaToastHost(
        message: message,
        onDone: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class _TaToastHost extends StatefulWidget {
  const _TaToastHost({required this.message, required this.onDone});

  final String message;
  final VoidCallback onDone;

  @override
  State<_TaToastHost> createState() => _TaToastHostState();
}

class _TaToastHostState extends State<_TaToastHost> {
  bool _visible = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _visible = true);
        Future.delayed(const Duration(milliseconds: 2400), () {
          if (mounted) {
            setState(() {
              _visible = false;
              _leaving = true;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 20,
            right: 20,
            bottom: 100,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 250),
              onEnd: _leaving ? widget.onDone : null,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 250),
                offset: _visible ? Offset.zero : const Offset(0, 0.15),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: TaColors.toastBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: TaShadows.shadowLg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check, color: TaColors.toastIcon, size: 18),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}