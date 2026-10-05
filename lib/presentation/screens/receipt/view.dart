import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/motion.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/fee_presentation.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/receipt/logic.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The invoice reference, or null when the backend sent none — the row is
/// then dropped rather than showing "INV-null".
String? receiptInvoice(Payment? payment) {
  final id = payment?.invoiceId;
  if (id == null) return null;
  return 'INV-$id';
}

/// `★★★★☆ · 4/5` for a given star count, or null when the trip was skipped.
String? receiptRating(int? stars) {
  if (stars == null || stars < 1 || stars > 5) return null;
  return '${'★' * stars}${'☆' * (5 - stars)} · $stars/5';
}

/// "Paid · Wallet" when the backend names a method, plain "Paid" otherwise —
/// the method is not invented.
String receiptPaidLabel(Payment? payment) {
  final method = feePaymentMethod(payment?.paymentMethod);
  return method == null
      ? AppLocale.paid.tr
      : '${AppLocale.paid.tr} · $method';
}

/// Screen 12 — Thank you.
///
/// What was paid, for which trip, and the way home. The rating is a dialog
/// `ReceiptLogic` opens over this page, and the page returns home by itself
/// when the countdown on "Back to Home" runs out.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ReceiptLogic>();

    return PopScope(
      // The trip is finished; Back has nowhere to return to.
      canPop: false,
      child: Scaffold(
        backgroundColor: TaColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Rebuilt when the rating lands, not on every tick.
                    child: GetBuilder<ReceiptLogic>(
                      builder: (logic) => ReceiptSummary(
                        booking: logic.state.booking,
                        stars: logic.state.stars,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GetBuilder<ReceiptLogic>(
                  id: ReceiptUpdate.countdown,
                  builder: (logic) => TaButton(
                    label: '${AppLocale.backToHome.tr} · '
                        '${AppLocale.secondsShort.trParams({
                          'count': '${logic.state.secondsLeft}'
                        })}',
                    onTap: logic.backToHome,
                  ),
                ),
                const SizedBox(height: 10),
                TaButton(
                  label: AppLocale.bookAgain.tr,
                  variant: TaButtonVariant.ghost,
                  onTap: logic.bookAgain,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The page above the buttons: the thank-you, the amount paid, the trip, and
/// the invoice details. Rows the backend did not fill are dropped rather
/// than shown empty.
class ReceiptSummary extends StatelessWidget {
  const ReceiptSummary({super.key, required this.booking, required this.stars});

  final Data? booking;

  /// Null until rated, and when the rating was skipped.
  final int? stars;

  @override
  Widget build(BuildContext context) {
    final payment = booking?.payment;
    final amount = feeAmount(payment?.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        const Center(child: ReceiptSuccessCheck()),
        const SizedBox(height: 12),
        Text(
          AppLocale.thankYou.tr,
          style: TaTextStyles.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          AppLocale.tripComplete.tr,
          style:
              TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),

        /// Money fails loudly: an amount the backend did not send, or sent
        /// unparseably, is said to be unavailable rather than shown as a
        /// number — and nothing is called "Paid" without one.
        if (amount != null) ...[
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              amount,
              maxLines: 1,
              style: TaTextStyles.displayLarge.copyWith(
                fontSize: 36,
                color: TaColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: TaBadge(
              label: receiptPaidLabel(payment),
              icon: const Icon(Icons.check_circle),
            ),
          ),
        ] else
          Text(
            AppLocale.fareUnavailable.tr,
            textAlign: TextAlign.center,
            style: TaTextStyles.bodyMedium.copyWith(color: TaColors.error),
          ),
        const SizedBox(height: 16),
        TaTripCard(
          pickupLabel: AppLocale.pickup.tr,
          pickup: feeDisplayValue(booking?.startAddress),
          dropOffLabel: AppLocale.destination.tr,
          dropOff: feeOptionalValue(booking?.endAddress),
          noDropOffText: AppLocale.noDropOffMeter.tr,
        ),
        const SizedBox(height: 10),
        ReceiptCard(booking: booking, stars: stars),
      ],
    );
  }
}

/// Invoice, date and the passenger's rating, each under its own label.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({super.key, required this.booking, required this.stars});

  final Data? booking;
  final int? stars;

  @override
  Widget build(BuildContext context) {
    final invoice = receiptInvoice(booking?.payment);
    final rating = receiptRating(stars);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaColors.border),
      ),
      child: Column(
        children: [
          if (invoice != null)
            TaKVRow(label: AppLocale.invoice.tr, value: invoice),
          TaKVRow(
            label: AppLocale.dateTime.tr,
            value: feeDateTime(booking?.startTime),
          ),

          /// Skipping leaves the row out rather than claiming a score the
          /// passenger never gave.
          if (rating != null)
            TaKVRow(label: AppLocale.yourRating.tr, value: rating),
        ],
      ),
    );
  }
}

/// The animated success check (`05 §Star pop`'s `pop2` curve).
class ReceiptSuccessCheck extends StatefulWidget {
  const ReceiptSuccessCheck({super.key});

  @override
  State<ReceiptSuccessCheck> createState() => _ReceiptSuccessCheckState();
}

class _ReceiptSuccessCheckState extends State<ReceiptSuccessCheck>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Motion.base,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _controller,
        curve: const Cubic(0.2, 0.9, 0.3, 1.2),
      ),
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: TaColors.successBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 36, color: TaColors.success),
      ),
    );
  }
}
