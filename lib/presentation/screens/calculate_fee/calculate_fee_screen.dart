import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:get/get.dart';

class CalculateFeeScreen extends StatefulWidget {
  const CalculateFeeScreen({super.key});

  @override
  State<CalculateFeeScreen> createState() => _CalculateFeeScreenState();
}

class _CalculateFeeScreenState extends State<CalculateFeeScreen> {
  final CalculateFeeLogic logic =
      Get.put<CalculateFeeLogic>(CalculateFeeLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light4,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1, color: AppColors.light1),
            Obx(
              () => logic.state.isLoading.value
                  ? _buildLoadingIndicator()
                  : Expanded(child: _buildContent()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        AppLocale.calculateFee.tr,
        style: ThemeConstands.font22SemiBold.copyWith(color: AppColors.dark1),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildDriverInfoCard(),
          const SizedBox(height: 18),
          _buildPaymentInfo(),
        ],
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    return Container(
      margin: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 1, color: AppColors.light1),
      ),
      child: Column(
        children: [
          _buildDriverDetails(),
          const SizedBox(height: 18),
          _buildTotalPriceSection(),
        ],
      ),
    );
  }

  Widget _buildDriverDetails() {
    var data = logic.state.data.value?.data;
    return Container(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30.0,
                backgroundImage:
                    NetworkImage('https://via.placeholder.com/150'),
                backgroundColor: Colors.transparent,
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data?.driver?.name.toString() ?? AppLocale.unKnown.tr,
                        style: ThemeConstands.font20SemiBold
                            .copyWith(color: AppColors.dark1),
                      ),
                      Text(
                        data?.payment?.paymentMethod ?? AppLocale.unKnown.tr,
                        style: ThemeConstands.font14Regular
                            .copyWith(color: AppColors.dark1),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                width: 100,
                child: Text(
                  AppLocale.paymentCollection.tr,
                  textAlign: TextAlign.left,
                  style: ThemeConstands.font16SemiBold
                      .copyWith(color: AppColors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          tRowCard(
            title: AppLocale.distance.tr,
            value: data?.payment?.distance.toString() ?? AppLocale.unKnown.tr,
          ),
          tRowCard(
            title: AppLocale.duration.tr,
            value: data?.payment?.duration.toString() ?? AppLocale.unKnown.tr,
          ),
          tRowCard(
            title: AppLocale.dateTime.tr,
            value: data?.startTime != null
                ? formatDateTime(data?.startTime)
                : AppLocale.unKnown.tr,
          ),
          _buildLocationDetails(),
        ],
      ),
    );
  }

  Widget _buildLocationDetails() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              ImageAssets.book_outline,
              width: 20,
              // ignore: deprecated_member_use
              color: AppColors.dark1,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                // AppLocale.locationPassengerStand.tr,
                logic.state.data.value?.data?.endAddress ??
                    AppLocale.unKnown.tr,
                style: ThemeConstands.font16Regular
                    .copyWith(color: AppColors.dark1),
              ),
            ),
          ],
        ),
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
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                logic.state.data.value?.data?.endAddress ??
                    AppLocale.unKnown.tr,
                style: ThemeConstands.font16Regular
                    .copyWith(color: AppColors.dark1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTotalPriceSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: AppColors.red,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              AppLocale.totalPrice.tr,
              style: ThemeConstands.font16SemiBold
                  .copyWith(color: AppColors.light4),
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            child: Text(
              "${logic.state.data.value?.data?.payment?.amount ?? ""} ${AppLocale.khmerCurrency.tr}",
              style: ThemeConstands.font18SemiBold
                  .copyWith(color: AppColors.light4),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo() {
    return Column(
      children: [
        SizedBox(
          width: Get.width * 0.9,
          child: Text(
            AppLocale.waitPaymentDriver.tr,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyDark.copyWith(
              color: AppColors.dark1,
              fontSize: 18,
            ),
          ),
        ),
        // Uncomment if needed:
        // SizedBox(
        //   width: Get.width / 2,
        //   child: FBTNWidget(
        //     onPressed: () {
        //       Get.offAllNamed(AppRoutes.HOME);
        //     },
        //     color: AppColors.dark2,
        //     textColor: AppColors.light4,
        //     label: "Back to home",
        //   ),
        // ),
      ],
    );
  }

  Widget tRowCard({
    required String title,
    String? iconPath,
    required String value,
  }) {
    return Column(
      children: [
        const Divider(color: AppColors.light1, thickness: 1, height: 1),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style:
                  ThemeConstands.font14Regular.copyWith(color: AppColors.dark1),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: ThemeConstands.font14SemiBold
                  .copyWith(color: AppColors.dark1),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: AppColors.light1, thickness: 1, height: 1),
      ],
    );
  }
}
