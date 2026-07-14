import 'package:cached_network_image/cached_network_image.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/core/utils/get_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ignore: must_be_immutable
class XNetworkImage extends StatelessWidget {
  String src;
  BoxFit? fit;
  double? height;
  double? width;
  String loadingDescription;
  String? errorDescription;
  double? errorIconSize;
  double? errorFontSize;
  bool isNeedErrorDesc;
  Widget? errorWidget;

  XNetworkImage({
    super.key,
    required this.src,
    this.fit,
    this.errorWidget,
    this.height,
    this.width,
    this.loadingDescription = "",
    this.errorDescription,
    this.errorIconSize,
    this.errorFontSize,
    this.isNeedErrorDesc = true,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: src,
      fit: fit ?? BoxFit.fitWidth,
      height: height,
      width: width,
      memCacheHeight: height?.toInt(),
      memCacheWidth: width?.toInt(),
      errorWidget: (_, __, ___) =>
          errorWidget ??
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SvgPicture.asset(
              "assets/image/svg/no_image.svg",
              height: errorIconSize,
            ),
          ),
      progressIndicatorBuilder: (context, url, progress) {
        double? progressValue = progress.progress;
        return Stack(
          children: [
            // Static shimmer effect
            Container(
              height: height,
              width: width,
              decoration: getBoxDecoration(background: Colors.red),
            ).toShimmer,
            if (progressValue != null)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: LinearProgressIndicator(
                      value: progressValue,
                      color: AppColors.main,
                      borderRadius: BorderRadius.circular(10),
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      minHeight: 4,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
