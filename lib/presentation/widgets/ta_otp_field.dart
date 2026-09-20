import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Single-digit OTP box row (`.otp`) — component spec §4.
///
/// Auto-advances on input, auto-backs on empty backspace, fires
/// [onComplete] when the last box is filled.
class TaOtpField extends StatefulWidget {
  const TaOtpField({
    super.key,
    this.count = 4,
    this.onComplete,
  });

  final int count;
  final ValueChanged<String>? onComplete;

  @override
  State<TaOtpField> createState() => _TaOtpFieldState();
}

class _TaOtpFieldState extends State<TaOtpField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.count,
      (_) => TextEditingController(),
      growable: false,
    );
    _focusNodes = List.generate(widget.count, (_) => FocusNode(), growable: false);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < widget.count - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        widget.onComplete?.call(_controllers.map((c) => c.text).join());
      }
    } else if (index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < widget.count; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 64,
              child: AnimatedBuilder(
                animation: _focusNodes[i],
                builder: (_, __) {
                  final focused = _focusNodes[i].hasFocus;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    decoration: BoxDecoration(
                      color: TaColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: focused ? TaColors.primary : TaColors.border,
                        width: 1.5,
                      ),
                      boxShadow: focused
                          ? [
                              const BoxShadow(
                                color: TaColors.primaryBorder,
                                blurRadius: 0,
                                spreadRadius: 3,
                              ),
                            ]
                          : null,
                    ),
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(1),
                      ],
                      onChanged: (value) => _onChanged(value, i),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: TaColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}