import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_card.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 10 — Fee (CalculateFee).
///
/// The prototype's "Simulate: driver confirms payment" button and its 9s
/// auto-pay are demo-only (`D14`) and are not built: the screen waits for the
/// real `driverAcceptPayment` socket event, which `PassengerSocketService`
/// already routes to `CalculateFeeLogic.syncNavigateBack()`. That handler, and
/// the controller as a whole, are untouched by this task.
class CalculateFeeScreen extends StatelessWidget {
  const CalculateFeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<CalculateFeeLogic>();

    return Scaffold(
      backgroundColor: TaColors.background,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 26, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// No back button: the trip is over and the passenger cannot
              /// return to it (spec §Screen 10 Layout).
              Text(
                AppLocale.tripFare.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.titleLarge.copyWith(fontSize: 17),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Obx(
                  () => logic.state.isLoading.value
                      ? const FeeLoadingView()
                      : FeeContent(data: logic.state.data.value?.data),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shimmer placeholder, shaped like the loaded receipt so the layout does
/// not jump when the fare arrives.
class FeeLoadingView extends StatelessWidget {
  const FeeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          TaSkeletonCard(
            children: [
              const TaSkeleton(height: 52, radius: 14),
              const SizedBox(height: 14),
              for (var i = 0; i < 4; i++) ...[
                const TaSkeleton(height: 16),
                const SizedBox(height: 10),
              ],
              const TaSkeleton(height: 40, radius: 12),
            ],
          ),
          const SizedBox(height: 12),
          const TaSkeleton(height: 72, radius: 16),
        ],
      ),
    );
  }
}

/// The loaded receipt: fee card, total box and the payment-wait badge.
class FeeContent extends StatelessWidget {
  const FeeContent({super.key, required this.data});

  final Data? data;

  @override
  Widget build(BuildContext context) {
    final amount = feeAmount(data?.payment?.amount);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FeeCard(data: data),
          const SizedBox(height: 12),

          /// Money fails loudly: an amount the backend did not send, or sent
          /// unparseably, shows an explicit "fare unavailable" rather than a
          /// zero or a raw string the passenger might pay against.
          if (amount != null)
            TaTotalBox(
              amount: amount,
              label: _totalLabel(),
            )
          else
            TaCard(
              color: TaColors.errorBg,
              child: Text(
                AppLocale.fareUnavailable.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.bodyMedium.copyWith(color: TaColors.error),
              ),
            ),
          const SizedBox(height: 12),

          /// Only the waiting state is rendered. In production this screen is
          /// left the moment the driver confirms — `driverAcceptPayment`
          /// navigates away — so a "paid" badge would need a `payment.status`
          /// mapping the backend does not document and nothing else in the app
          /// reads. Recorded rather than guessed.
          TaCard(
            child: Center(
              child: TaBadge(
                label: AppLocale.waitPaymentDriver.tr,
                variant: TaBadgeVariant.warning,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// "Total · Cash" when the backend names a method, plain "Total" otherwise —
  /// the label is not invented.
  String _totalLabel() {
    final method = data?.payment?.paymentMethod?.toString().trim();
    if (method == null || method.isEmpty || method == 'null') {
      return AppLocale.totalPrice.tr;
    }
    return '${AppLocale.totalPrice.tr} · $method';
  }
}
