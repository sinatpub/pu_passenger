import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';

class CardUploadAttachment extends StatelessWidget {
  VoidCallback? onPressed;
  VoidCallback? onPressedIcon;
  String? icon;
  String? title;
  double? radius;
  File? image;
  Widget? child;
  CardUploadAttachment(
      {super.key,
      required this.onPressedIcon,
      this.icon,
      required this.image,
      required this.onPressed,
      this.radius,
      this.child,
      this.title});

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      elevation: 0,
      onPressed: onPressed,
      color: AppColors.light3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius ?? 10)),
      padding: const EdgeInsets.all(0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.symmetric(
            vertical: 0,
          ),
          alignment: Alignment.center,
          child: image != null
              ? Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(90),
                    child: Image.file(
                      image!,
                      fit: BoxFit.cover,
                      height: 140,
                      width: 140,
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.light4,
                      ),
                      child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: onPressedIcon,
                          icon: const Icon(
                            Icons.delete_forever_outlined,
                            size: 18,
                            color: AppColors.red,
                          )),
                    ),
                  )
                ],
              )
              : child ??
                  Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...[
                          if (icon != null)
                            SvgPicture.asset(
                              icon.toString(),
                              width: 35,
                            ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                        ...[
                          if (title != null)
                            Text(
                              "$title",
                              style: ThemeConstands.font14SemiBold,
                              textAlign: TextAlign.center,
                            ),
                        ]
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
