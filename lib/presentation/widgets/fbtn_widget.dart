import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';

class FBTNWidget extends StatelessWidget {
  final String label;
  final Color? color;
  final Color textColor;
  final TextStyle? textStyle;
  final VoidCallback? onPressed;
  final bool centerTitle;
  final double? width;
  final Widget? prefix;

  const FBTNWidget({
    super.key,
    required this.label,
    this.color,
    this.prefix,
    this.centerTitle = true,
    this.textStyle,
    this.textColor = Colors.white,
    required this.onPressed,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: 38.0,
      child: MaterialButton(
        elevation: .5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstant.padding02),
        ),
        onPressed: onPressed,
        disabledColor: AppColors.light1,
        color: color ?? AppColors.main,
        textColor: textColor,
        child: Row(
          mainAxisAlignment:
              centerTitle ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            prefix ?? const SizedBox(),
            prefix != null
                ? const SizedBox(
                    width: 8,
                  )
                : const SizedBox(),
            Text(
              label,
              style: textStyle ??
                  AppTextStyles.body
                      .copyWith(fontSize: 16.0, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
