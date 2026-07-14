import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TImageWidget extends StatelessWidget {
  final ImageProvider? image;
  final BoxFit fit; // Optional fit for the image
  final double? width; // Optional width
  final double? height; // Optional height
  final int? vehicleId;

  const TImageWidget(
      {super.key,
      this.image,
      this.fit = BoxFit.cover, // Default BoxFit
      this.width,
      this.height,
      this.vehicleId});

  @override
  Widget build(BuildContext context) {
    return image != null
        ? FadeInImage(
            placeholder: const AssetImage("assets/image/png/placeholder.jpg"),
            image: image!,
            fit: fit,
            width: width ?? 30,
            height: height ?? 30,
            imageErrorBuilder: (context, error, stackTrace) {
              return SvgPicture.asset(
                "assets/image/svg/no_image.svg",
                width: width,
                height: height,
                fit: BoxFit.contain,
              );
            },
          )
        : Image.asset(
            getVehicleImagePath(vehicleId ?? 6),
            width: width ?? 120,
            height: height ?? 120,
          );
  }
}

String getVehicleImagePath(int vehicleId) {
  switch (vehicleId) {
    case 1:
      return ImageAssets.tokt_tok;
    case 2:
      return ImageAssets.classic_car;
    case 3:
      return ImageAssets.min_van_car;
    case 4:
      return ImageAssets.suv_car;
    case 5:
      return ImageAssets.vip_car;
    default:
      return ImageAssets.placeholder_png;
  }
}
