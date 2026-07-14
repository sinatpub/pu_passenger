import 'package:flutter/material.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';

class RTextFieldWidget extends StatelessWidget {
  final String? hTitle;
  final Color backgroundColor;
  final Widget? prefixIcon;
  final Color textColor;
  final String hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  RTextFieldWidget({
    super.key,
    this.backgroundColor = AppColors.light3,
    this.textColor = Colors.black,
    this.hintText = '',
    this.prefixIcon,
    this.controller,
    this.onChanged,
    this.hTitle,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hTitle != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 1.0),
            child: Text(hTitle!, style: AppTextStyles.body),
          ),
        SizedBox(
          height: 42,
          child: TextFormField(
            focusNode: focusNode,
            controller: controller,
            onChanged: onChanged,
            style: TextStyle(color: textColor),
            textAlignVertical: TextAlignVertical.center,
            enableSuggestions: false,
            decoration: InputDecoration(
              filled: true,
              prefixIcon: prefixIcon,
              fillColor: backgroundColor,
              hintText: hintText,
              hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
