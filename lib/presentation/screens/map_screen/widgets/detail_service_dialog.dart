import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/widgets/t_image_widget.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DetailServiceDialog extends StatelessWidget {
  final SingleVehical? data;
  const DetailServiceDialog({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * .5,
      width: Get.width,
      color: Colors.white,
      alignment: Alignment.center,
      child: Column(
        children: [
          SizedBox(
            height: 8.d,
          ),
          SizedBox(
            height: 45.d,
            width: Get.width,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  right: 8,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 18.d,
          ),
          Divider(
            color: Colors.grey[100],
            height: .1,
          ),
          Row(
            children: [
              TImageWidget(
                image: null,
                vehicleId: data?.id,
                height: 120,
                width: 120,
              ),
              const SizedBox(width: 18),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      data?.id == 1
                          ? AppLocale.rickshaw.tr
                          : data?.id == 2
                              ? AppLocale.classicCar.tr
                              : data?.id == 3
                                  ? AppLocale.miniVan.tr
                                  : data?.id == 4
                                      ? AppLocale.suvCar.tr
                                      : AppLocale.alphard.tr,
                      style: ThemeConstands.font14SemiBold),
                  Text(
                    "${data?.id == 1 ? 3 : data?.id == 2 ? 4 : data?.id == 3 ? 7 : data?.id == 4 ? 4 : 5} ${AppLocale.seatCapacity.tr}",
                    style: ThemeConstands.font14Regular
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Divider(
            color: Colors.grey[100],
            height: .1,
          ),
          const SizedBox(
            height: 8,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        AppLocale.minFee.tr,
                        style: AppTextStyles.body,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Row(
                        spacing: 4,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${data?.miniMunFare}",
                            style: AppTextStyles.body,
                          ),
                          Text(
                            AppLocale.khmerCurrency.tr,
                            style: AppTextStyles.body.copyWith(
                                fontSize: 16..d,
                                fontWeight: FontWeight.w800,
                                fontFamily: "KantumruyPro"),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                        flex: 1, child: Text("${AppLocale.pricePerKM.tr} : ")),
                    Expanded(
                      flex: 2,
                      child: Row(
                        spacing: 4,
                        children: [
                          Text(
                            "${data?.price}",
                            style: AppTextStyles.body
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            AppLocale.khmerCurrency.tr,
                            style: AppTextStyles.body.copyWith(
                                fontSize: 16..d,
                                fontWeight: FontWeight.w800,
                                fontFamily: "KantumruyPro"),
                          ),
                          Text(
                            '/ ${AppLocale.km.tr}',
                            style: AppTextStyles.body.copyWith(fontSize: 16..d),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
