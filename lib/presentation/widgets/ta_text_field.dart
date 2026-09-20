import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Styled text input (`.field`) — component spec §3.
///
/// Supports a [prefix] (rendered bold with a right rule), optional [suffix],
/// focus highlight and an error caption with reserved min-height.
class TaTextField extends StatefulWidget {
  const TaTextField({
    super.key,
    this.hint,
    this.controller,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.onChanged,
    this.errorText,
    this.textInputAction,
    this.autofocus = false,
    this.onSubmitted,
    this.enabled = true,
  });

  final String? hint;
  final TextEditingController? controller;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final TextInputAction? textInputAction;
  final bool autofocus;

  /// Submit-on-done. Login's phone field has always kicked off the request
  /// from the keyboard's action key, so the field has to carry it (S4).
  final ValueChanged<String>? onSubmitted;

  /// False greys the field out while a request is in flight.
  final bool enabled;

  @override
  State<TaTextField> createState() => _TaTextFieldState();
}

class _TaTextFieldState extends State<TaTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedBuilder(
          animation: _focusNode,
          builder: (_, __) {
            final focused = _focusNode.hasFocus;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: TaColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: focused ? TaColors.primary : TaColors.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  if (widget.prefix != null) ...[
                    DefaultTextStyle(
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TaColors.textPrimary,
                      ),
                      child: widget.prefix!,
                    ),
                    Container(
                      width: 1,
                      height: 22,
                      margin: const EdgeInsets.only(right: 10, left: 2),
                      color: TaColors.border,
                    ),
                  ],
                  Expanded(
                    child: TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      obscureText: widget.obscureText,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      onChanged: widget.onChanged,
                      textInputAction: widget.textInputAction,
                      autofocus: widget.autofocus,
                      onSubmitted: widget.onSubmitted,
                      enabled: widget.enabled,
                      style: const TextStyle(
                        fontSize: 15,
                        color: TaColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: widget.hint,
                        hintStyle: const TextStyle(
                          fontSize: 15,
                          color: TaColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                  if (widget.suffix != null) widget.suffix!,
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        widget.errorText == null
            ? const SizedBox(height: 18)
            : SizedBox(
                height: 18,
                child: Text(
                  widget.errorText!,
                  style: const TextStyle(fontSize: 13, color: TaColors.error),
                ),
              ),
      ],
    );
  }
}