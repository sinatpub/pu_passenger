// ignore_for_file: deprecated_member_use
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class HistoryCardWidget extends StatelessWidget {
  final Datum? data;
  const HistoryCardWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.d),
      decoration: BoxDecoration(
        color: AppColors.light4,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            blurStyle: BlurStyle.normal,
            color: Colors.grey.withOpacity(0.3),
            offset: const Offset(0, 0),
            // spreadRadius: 1,
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Get.toNamed(AppRoutes.HISTORYDETAIL, arguments: data);
        },
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundColor: Colors.transparent,
                  child:
                      XNetworkImage(src: data?.passenger?.profileImage ?? ""),
                ),
                Expanded(
                  child: Container(
                    alignment: Alignment.centerLeft,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4.d,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${AppLocale.inVoiceNo.tr}: # ${data?.payment?.invoiceId}",
                              style: ThemeConstands.font14Regular
                                  .copyWith(color: AppColors.dark2),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                        Text(
                          data?.driver?.name ?? AppLocale.unKnown.tr,
                          style: ThemeConstands.font18SemiBold
                              .copyWith(color: AppColors.dark1),
                        ),
                        Text(
                          "${AppLocale.method.tr}: ${data?.payment?.paymentMethod ?? AppLocale.unKnown.tr}",
                          style: ThemeConstands.font14Regular
                              .copyWith(color: AppColors.dark1),
                        ),
                        Builder(builder: (context) {
                          String date = data?.createdAt != null
                              ? DateTime.parse("${data?.createdAt}")
                                  .formatDateTime()
                              : AppLocale.unKnown.tr;
                          return Text(
                            date,
                            style: ThemeConstands.font12Regular
                                .copyWith(color: AppColors.dark1),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    data?.status == 4
                        ? AppLocale.completed.tr
                        : AppLocale.cancel.tr,
                    style: ThemeConstands.font14SemiBold.copyWith(
                        color: data?.status == 4
                            ? AppColors.success
                            : AppColors.error),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SvgPicture.asset(
                        ImageAssets.map_outline,
                        width: 20,
                        color: AppColors.red,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        data?.payment?.distance ?? AppLocale.unKnown.tr,
                        style: ThemeConstands.font16SemiBold
                            .copyWith(color: AppColors.dark1),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        ImageAssets.time_outline,
                        width: 20,
                        color: AppColors.red,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      SizedBox(
                        width: 90,
                        child: Text(
                          data?.payment?.duration?.toShortTimeFormat() ??
                              AppLocale.unKnown.tr,
                          style: ThemeConstands.font14Regular
                              .copyWith(color: AppColors.dark1),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SvgPicture.asset(
                        ImageAssets.payment_outline,
                        width: 20,
                        color: AppColors.red,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        "${data?.payment?.amount ?? 0.0} ៛",
                        style: ThemeConstands.font14Regular
                            .copyWith(color: AppColors.dark1),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            const Divider(
              color: AppColors.light1,
              thickness: 1,
              height: 1,
            ),
            const SizedBox(
              height: 18,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4.d,
                  children: [
                    Text(
                      AppLocale.vehicleType.tr,
                      style: ThemeConstands.font14Regular,
                    ),
                    Text(
                      data?.driver?.vehicle?.vehicleTypeName.toString() ??
                          "---",
                      style: ThemeConstands.font10SemiBold,
                    ),
                  ],
                ),
                const SizedBox.shrink(),
                // Column(
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   spacing: 4.d,
                //   children: [
                //     Text(
                //       AppLocale.pricePerKM.tr,
                //       style: ThemeConstands.font14Regular,
                //     ),
                //     Text(
                //       "${Get.find<HistoryLogic>().getVehiclePrice(vehicleTypeId: data?.driver?.vehicle?.typeVehicleId ?? 0)} ${AppLocale.khmerCurrency.tr}",
                //       style: ThemeConstands.font10SemiBold,
                //     ),
                //   ],
                // ),
              ],
            ),
            const SizedBox(
              height: 18,
            ),
            const Divider(
              color: AppColors.light1,
              thickness: 1,
              height: 1,
            ),
            const SizedBox(
              height: 18,
            ),
            Image.asset("assets/image/png/map_placeholder.png"),
            const SizedBox(
              height: 18,
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      ImageAssets.current_location,
                      width: 20,
                      color: AppColors.dark1,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        data?.startAddress?.isNotEmpty == true &&
                                data?.startAddress != null
                            ? data!.startAddress!
                            : AppLocale.unKnown.tr,
                        style: ThemeConstands.font16Regular
                            .copyWith(color: AppColors.dark1),
                      ),
                    ),
                  ],
                ),
                data?.endAddress == null
                    ? const SizedBox()
                    : Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(left: 9),
                            alignment: Alignment.centerLeft,
                            child: const DottedLine(
                              alignment: WrapAlignment.start,
                              lineLength: 30,
                              direction: Axis.vertical,
                              lineThickness: 1,
                              dashColor: AppColors.dark1,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SvgPicture.asset(
                                ImageAssets.book_outline,
                                width: 20,
                                color: AppColors.red,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Expanded(
                                child: Text(
                                  data?.endAddress ?? AppLocale.unKnown.tr,
                                  style: ThemeConstands.font16Regular
                                      .copyWith(color: AppColors.dark1),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
