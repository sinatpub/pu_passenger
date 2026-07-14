import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final logic = Get.find<HomeLogic>();

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: AppColors.main,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () async {
            await logic.getVehicleType();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      width: Get.width,
                      height: 100..d,
                      child: Column(
                        children: [
                          Text(
                            "TAARRAA",
                            style: ThemeConstands.font28SemiBold.copyWith(
                                color: AppColors.light4,
                                fontWeight: FontWeight.w800),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "តារា",
                            style: TextStyle(
                                    fontFamily: "KhmerMoul", fontSize: 28.d)
                                .copyWith(color: AppColors.light4),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Get.height * .8,
                      child: GetBuilder<HomeLogic>(
                        builder: (homeLogic) {
                          /// Loading
                          if (homeLogic.state.isLoading.isLoading) {
                            return const SizedBox.shrink();
                          }

                          /// Error
                          if (homeLogic.state.isLoading.isError) {
                            return Center(
                              child: Text(AppLocale.noVehicleAvailable.tr,
                                  style: AppTextStyles.heading
                                      .copyWith(color: AppColors.light1)),
                            );
                          }

                          /// Data Presenting
                          final data = homeLogic.state.vehicleAllType!.data;

                          return Container(
                            color: AppColors.light4,
                            child: SingleChildScrollView(
                              child: SizedBox(
                                height: Get.height / 2.2,
                                width: width,
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                vehicleCard(
                                                    src: data[0].image,
                                                    assetImage:
                                                        ImageAssets.tokt_tok,
                                                    title: data[0].name,
                                                    data: data[0],
                                                    height: 100.d),
                                                const SizedBox(width: 12),
                                                vehicleCard(
                                                    src: data[1].image,
                                                    assetImage:
                                                        ImageAssets.classic_car,
                                                    title: data[1].name,
                                                    data: data[1],
                                                    isRight: true,
                                                    height: 110.d),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                vehicleCard(
                                                    isBottom: true,
                                                    src: data?[2].image,
                                                    assetImage:
                                                        ImageAssets.suv_car,
                                                    title: data[2].name,
                                                    data: data[2],
                                                    height: 110.d),
                                                const SizedBox(width: 12),
                                                vehicleCard(
                                                    isBottom: true,
                                                    src: data[3].image,
                                                    assetImage:
                                                        ImageAssets.min_van_car,
                                                    title: data[3].name,
                                                    data: data[3],
                                                    isRight: true,
                                                    height: 120.d),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      _alphardVipCard(data: data[4]),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                // Positioned(
                //   right: 10,
                //   top: 10,
                //   child: IconButton(
                //     onPressed: () {
                //       Get.toNamed(AppRoutes.ANNOUNCEMENT);
                //     },
                //     icon: const Icon(
                //       CupertinoIcons.bell_circle_fill,
                //       color: Colors.white,
                //       size: 34,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _alphardVipCard({required SingleVehical data}) {
    return Positioned.fill(
      child: Center(
        child: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.MAP, arguments: {'vehicleId': data.id});
          },
          child: Container(
            padding: EdgeInsets.all(12.d),
            decoration: const BoxDecoration(
              color: AppColors.light4,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 80.d,
              backgroundColor: AppColors.red.withAlpha(80),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: XNetworkImage(
                          src: data.image ?? '',
                          width: 130.d,
                          errorWidget: Image.asset(ImageAssets.alphard_car),
                        ),
                      ),
                      Positioned(
                        bottom: -5.d,
                        child: Text(
                          data.name,
                          style: TextStyle(
                              fontSize: 16.d,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: "TimesNewRomance"),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget vehicleCard(
      {String? src,
      required String assetImage,
      required String title,
      required SingleVehical data,
      bool isBottom = false,
      bool isRight = false,
      double height = 140}) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.MAP, arguments: {"vehicleId": data.id});
      },
      child: Container(
        width: Get.width / 2.2,
        decoration: BoxDecoration(
          color: AppColors.red.withAlpha(80),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.d),
        child: Column(
          crossAxisAlignment:
              isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisAlignment:
              isBottom ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            SizedBox(height: 12.d),
            ...[
              if (isBottom)
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "TimesNewRomance"),
                ),
            ],
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: src != null
                    ? Image.network(
                        src,
                        height: 120.d,
                        // fit: BoxFit.cover,
                        // height: height.d,
                        errorBuilder: (context, error, stackTrace) =>
                            Image.asset(
                          assetImage,
                          height: 120.d,
                          // fit: BoxFit.cover,
                          // height: height.d,
                        ),
                      )
                    : Image.asset(
                        assetImage,
                        fit: BoxFit.fitWidth,
                        height: height.d,
                      ),
              ),
            ),
            SizedBox(height: 12.d),
            ...[
              if (!isBottom)
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: "TimesNewRomance"),
                ),
            ]
          ],
        ),
      ),
    );
  }
}
