import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home tab (C2) — Screen 6 of `03-screen-redesign.md`.
///
/// Header + PROMO banner + "Where to?" search card + vertical vehicle list
/// (replacing the old 2×2 grid with VIP circle). Routing stays identical to
/// the baseline: a vehicle row (and the search card) lands on `/map` with the
/// same arguments.
class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final logic = Get.find<HomeLogic>();
  final AppLogic appLogic = Get.find<AppLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: logic.getVehicleType,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 46, 20, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 14),
                TaPromoBanner(
                  tag: AppLocale.promoTag,
                  title: AppLocale.promoTitle.tr,
                  subtitle: AppLocale.promoSubtitle.tr,
                  onTap: () => TaToast.show(context, AppLocale.promoApplied.tr),
                ),
                const SizedBox(height: 14),
                TaSearchCard(
                  label: AppLocale.whereTo.tr,
                  onTap: () => Get.toNamed(AppRoutes.MAP),
                ),
                const SizedBox(height: 18),
                _buildSectionHeader(context),
                const SizedBox(height: 12),
                GetBuilder<HomeLogic>(builder: (homeLogic) {
                  if (homeLogic.state.isLoading.isLoading ||
                      homeLogic.state.isLoading.isError) {
                    // Loading and error both keep the shimmer skeleton; the
                    // error toast is fired from `getVehicleType()`'s catch.
                    return _buildSkeleton();
                  }
                  final vehicles = homeLogic.state.vehicleAllType?.data ?? const <SingleVehical>[];
                  if (vehicles.isEmpty) {
                    return EmptyData(message: AppLocale.noVehicleAvailable.tr);
                  }
                  return Column(
                    children: [
for (final vehicle in vehicles)
                      TaVehicleRow(
                        vehicle: vehicleCellData(vehicle),
                        onTap: () => Get.toNamed(AppRoutes.MAP,
                            arguments: {'vehicleId': vehicle.id}),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TAARRAA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: TaColors.textPrimary,
              ),
            ),
            Obx(() {
              final isEn =
                  appLogic.languageKeyCode.value == AppConstant.englishCode;
              const kmWord = TextSpan(
                text: 'តារា',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: TaColors.primary,
                ),
              );
              final rest = '${isEn ? '' : ' · '}Ride with trust';
              return Text.rich(
                TextSpan(
                  children: [
                    if (!isEn) kmWord,
                    TextSpan(text: rest),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: TaColors.textSecondary,
                ),
              );
            }),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            // Bell entry (PDD-03): stays commented out until explicit
            // sign-off — roadmap C2 "Bell entry point restored ONLY if
            // PDD-03 is approved".
            // TaIconButton(
            //   icon: const Icon(Icons.notifications_none),
            //   showDot: true,
            //   onTap: () => Get.toNamed(AppRoutes.ANNOUNCEMENT),
            // ),
            const SizedBox(width: 10),
            TaIconButton(
              size: 42,
              semanticLabel: AppLocale.language.tr,
              icon: Obx(
                () => Text(
                  appLogic.languageKeyCode.value == AppConstant.englishCode
                      ? 'ខ្មែរ'
                      : 'EN',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: TaColors.primary,
                  ),
                ),
              ),
              onTap: appLogic.toggleLanguage,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          AppLocale.chooseYourRide.tr,
          style: TaTextStyles.headlineMedium.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: TaColors.textPrimary,
          ),
        ),
        const Spacer(),
        TaIconButton(
          size: 36,
          semanticLabel: AppLocale.refresh.tr,
          icon: const Icon(Icons.refresh, color: TaColors.textPrimary),
          onTap: () {
            logic.getVehicleType();
            TaToast.show(context, AppLocale.refreshed.tr);
          },
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        for (var i = 0; i < 3; i++)
          const TaSkeletonCard(
            children: [
              Row(
                children: [
                  TaSkeleton(width: 84, height: 52, radius: 10),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaSkeleton(width: double.infinity, height: 14, radius: 6),
                        SizedBox(height: 8),
                        TaSkeleton(width: 140, height: 12, radius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}