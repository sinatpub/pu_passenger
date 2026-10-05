import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_card.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/widgets/fee_waiting_banner.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 10 — Fee (CalculateFee).
///
/// Top to bottom in the order the passenger needs it: what they owe, that
/// the driver is confirming it, then the trip it was for.
///
/// The prototype's "Simulate: driver confirms payment" button and its 9s
/// auto-pay are demo-only (`D14`) and are not built: the screen waits for the
/// real `driverAcceptPayment` socket event, which `PassengerSocketService`
/// already routes to `CalculateFeeLogic.syncNavigateBack()`. That handler is
/// untouched.
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
              const SizedBox(height: 14),
              Expanded(
                child: Obx(() {
                  if (logic.state.isLoading.value) {
                    return const FeeLoadingView();
                  }
                  final data = logic.state.data.value?.data;
                  if (logic.state.hasError.value || data == null) {
                    return FeeErrorView(onRetry: logic.getCalculateFeeApi);
                  }
                  return FeeContent(
                    data: data,
                    onRetry: logic.getCalculateFeeApi,
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The shimmer placeholder, shaped like the loaded page so the layout does
/// not jump when the fare arrives.
class FeeLoadingView extends StatelessWidget {
  const FeeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        children: [
          TaSkeleton(width: 180, height: 44, radius: 10),
          SizedBox(height: 10),
          TaSkeleton(width: 72, height: 26, radius: 99),
          SizedBox(height: 16),
          TaSkeleton(height: 46, radius: 14),
          SizedBox(height: 12),
          TaSkeleton(height: 76, radius: 16),
          SizedBox(height: 10),
          TaSkeleton(height: 70, radius: 16),
          SizedBox(height: 10),
          TaSkeleton(height: 108, radius: 16),
        ],
      ),
    );
  }
}

/// The loaded page: the fare, the payment wait, then the trip.
class FeeContent extends StatelessWidget {
  const FeeContent({super.key, required this.data, this.onRetry});

  final Data? data;

  /// Asks for the fare again. Offered only where the fare is missing.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final amount = feeAmount(data?.payment?.amount);
    final method = feePaymentMethod(data?.payment?.paymentMethod);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          /// Money fails loudly: an amount the backend did not send, or sent
          /// unparseably, shows an explicit "fare unavailable" rather than a
          /// zero or a raw string the passenger might pay against.
          if (amount != null)
            _amount(amount, method)
          else
            _fareUnavailable(),
          const SizedBox(height: 16),

          /// Only the waiting state is rendered. In production this screen is
          /// left the moment the driver confirms — `driverAcceptPayment`
          /// navigates away — so a "paid" state would need a `payment.status`
          /// mapping the backend does not document and nothing else in the app
          /// reads. Recorded rather than guessed.
          const FeeWaitingBanner(),
          const SizedBox(height: 12),
          FeeCard(data: data),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// The fare, as large as anything on the page, with how it is being paid.
  Widget _amount(String amount, String? method) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            amount,
            maxLines: 1,
            style: TaTextStyles.displayLarge.copyWith(
              fontSize: 40,
              color: TaColors.textPrimary,
            ),
          ),
        ),
        if (method != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: TaColors.surface,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: TaColors.border),
            ),
            child: Text(
              method,
              style: TaTextStyles.labelMedium
                  .copyWith(color: TaColors.textSecondary),
            ),
          ),
        ],
      ],
    );
  }

  Widget _fareUnavailable() {
    return TaCard(
      color: TaColors.errorBg,
      child: Column(
        children: [
          Text(
            AppLocale.fareUnavailable.tr,
            textAlign: TextAlign.center,
            style: TaTextStyles.bodyMedium.copyWith(color: TaColors.error),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: 140,
              child: TaButton(
                label: AppLocale.retry.tr,
                variant: TaButtonVariant.ghost,
                size: TaButtonSize.small,
                onTap: onRetry,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// The trip could not be loaded at all. The passenger still owes a fare the
/// page cannot show, so it says who can — and keeps waiting for the driver's
/// confirmation, which still ends this screen.
class FeeErrorView extends StatelessWidget {
  const FeeErrorView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.receipt_long_outlined,
              size: 48, color: TaColors.textMuted),
          const SizedBox(height: 12),
          Text(
            AppLocale.couldNotLoadFare.tr,
            textAlign: TextAlign.center,
            style:
                TaTextStyles.titleLarge.copyWith(color: TaColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocale.askDriverForAmount.tr,
            textAlign: TextAlign.center,
            style:
                TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: 160,
              child: TaButton(
                label: AppLocale.retry.tr,
                variant: TaButtonVariant.ghost,
                size: TaButtonSize.small,
                onTap: onRetry,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const FeeWaitingBanner(),
        ],
      ),
    );
  }
}
