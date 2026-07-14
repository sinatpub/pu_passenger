import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/resources/asset_resource.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/x_network_image.dart';
import 'logic.dart';
import 'state.dart';

class HistoryDetailPage extends StatelessWidget {
  HistoryDetailPage({super.key});

  final HistoryDetailLogic logic = Get.find<HistoryDetailLogic>();
  final HistoryDetailState state = Get.find<HistoryDetailLogic>().state;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocale.historyDetail.tr),
          centerTitle: true,
        ),
        body: GetBuilder<HistoryDetailLogic>(
          builder: (logic) {
            var data = state.data;
            return Container(
              padding: const EdgeInsets.all(18),
              margin: const EdgeInsets.only(left: 12, right: 12, top: 18),
              decoration: BoxDecoration(
                color: AppColors.light4,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 1,
                    blurStyle: BlurStyle.normal,
                    color: Colors.grey.withAlpha(30),
                    offset: const Offset(0, 0),
                    // spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                spacing: 12.d,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.transparent,
                        child: XNetworkImage(
                            src: data?.passenger?.profileImage ?? ""),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                data?.driver?.firstName ?? AppLocale.unKnown.tr,
                                style: ThemeConstands.font20SemiBold
                                    .copyWith(color: AppColors.dark1),
                              ),
                              Text(
                                "${AppLocale.method.tr}: ${data?.payment?.paymentMethod ?? AppLocale.unKnown.tr}",
                                style: ThemeConstands.font14Regular
                                    .copyWith(color: AppColors.dark1),
                              ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            SvgPicture.asset(
                              ImageAssets.map_outline,
                              width: 20,
                              colorFilter: const ColorFilter.mode(
                                  AppColors.red, BlendMode.srcIn),
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
                              colorFilter: const ColorFilter.mode(
                                  AppColors.red, BlendMode.srcIn),
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
                              colorFilter: const ColorFilter.mode(
                                  AppColors.red, BlendMode.srcIn),
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
                  const Divider(
                    color: AppColors.light1,
                    thickness: 1,
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${AppLocale.dateTime.tr} ${data?.createdAt?.formatDateString() ?? AppLocale.unKnown.tr}",
                        style: ThemeConstands.font14Regular
                            .copyWith(color: AppColors.dark1),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                    ],
                  ),
                  const Divider(
                    color: AppColors.light1,
                    thickness: 1,
                    height: 1,
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            ImageAssets.current_location,
                            width: 20,
                            colorFilter: const ColorFilter.mode(
                                AppColors.dark1, BlendMode.srcIn),
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
                                      colorFilter: const ColorFilter.mode(
                                        AppColors.red,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      child: Text(
                                        data?.endAddress ??
                                            AppLocale.unKnown.tr,
                                        style: ThemeConstands.font16Regular
                                            .copyWith(
                                          color: AppColors.dark1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                    ],
                  ),
                  Expanded(child: _mapPolyline()),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  _mapPolyline() {
    return GetBuilder<HistoryDetailLogic>(builder: (logic) {
      double startLat = double.tryParse("${state.data?.startLatitude}") ?? 0.0;
      double startLng = double.tryParse("${state.data?.startLongitude}") ?? 0.0;

      return GoogleMap(
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        },
        initialCameraPosition:
            CameraPosition(target: LatLng(startLat, startLng), zoom: 16),
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        indoorViewEnabled: false,
        mapType: MapType.normal,
        markers: logic.state.markers.toSet(),
        polylines: logic.state.polyline.toSet(),
        onMapCreated: (controller) {
          logic.drawPolyline();
        },
      );
    });
  }
}
