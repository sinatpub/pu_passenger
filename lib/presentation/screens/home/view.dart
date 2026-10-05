import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/vehicle_cell_data.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/login/auth_language_toggle.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Home tab (C2) — Screen 6 of `03-screen-redesign.md`.
///
/// Header + PROMO banner + vertical vehicle list (replacing the old 2×2 grid
/// with VIP circle). A vehicle row lands on `/map` with that vehicle; the
/// "Where to?" search card that opened the map without one is gone (D35).
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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

  /// Brand bar (D36): the PU Taxi mark, the name over its tagline, and the
  /// language segment, on one centre line.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          // The launcher icon, as on the splash. It is 1024px, so it is
          // decoded at the size it is shown.
          child: Image.asset(
            ImageAssets.brandMark,
            fit: BoxFit.cover,
            cacheWidth: 160,
          ),
        ),
        const SizedBox(width: 10),
        // The name and tagline shrink to fit a narrow screen rather than
        // wrap or push the language segment off the edge.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  AppConstant.titleApp,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: TaColors.textPrimary,
                  ),
                ),
              ),
              Obx(() {
                final isEn =
                    appLogic.languageKeyCode.value == AppConstant.englishCode;
                const kmWord = TextSpan(
                  text: AppConstant.titleAppKhmer,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: TaColors.primary,
                  ),
                );
                final tagline = AppLocale.rideWithTrust.tr;
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        if (!isEn) kmWord,
                        TextSpan(text: isEn ? tagline : ' · $tagline'),
                      ],
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      color: TaColors.textSecondary,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        const Row(
          children: [
            // Bell entry (PDD-03): stays commented out until explicit
            // sign-off — roadmap C2 "Bell entry point restored ONLY if
            // PDD-03 is approved".
            // TaIconButton(
            //   icon: const Icon(Icons.notifications_none),
            //   showDot: true,
            //   onTap: () => Get.toNamed(AppRoutes.ANNOUNCEMENT),
            // ),
            SizedBox(width: 10),
            AuthLanguageToggle(),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppLocale.chooseYourRide.tr,
            style: TaTextStyles.headlineMedium.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: TaColors.textPrimary,
            ),
          ),
        ),
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