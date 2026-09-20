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

/// Screen 12 — Receipt.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<ReceiptLogic>();
    final booking = logic.state.booking;

    return PopScope(
      // The trip is finished; Back would land on the rating screen the
      // passenger has already answered.
      canPop: false,
      child: Scaffold(
        backgroundColor: TaColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Center(child: ReceiptSuccessCheck()),
                const SizedBox(height: 16),
                Text(
                  AppLocale.thankYou.tr,
                  style: TaTextStyles.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  AppLocale.tripCompleteReceiptSent.tr,
                  style: TaTextStyles.bodyMedium
                      .copyWith(color: TaColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ReceiptCard(booking: booking, stars: logic.state.stars),
                const Spacer(),
                TaButton(
                  label: AppLocale.backToHome.tr,
                  onTap: logic.backToHome,
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
        width: 96,
        height: 96,
        decoration: const BoxDecoration(
          color: TaColors.successBg,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, size: 48, color: TaColors.success),
      ),
    );
  }
}

/// Invoice, rating, destination + amount, and the payment row — all from
/// existing trip data (roadmap C7 Done When). Rows the backend did not fill
/// are dropped rather than shown empty.
class ReceiptCard extends StatelessWidget {
  const ReceiptCard({super.key, required this.booking, required this.stars});

  final Data? booking;
  final int? stars;

  @override
  Widget build(BuildContext context) {
    final payment = booking?.payment;
    final invoice = receiptInvoice(payment);
    final rating = receiptRating(stars);
    final amount = feeAmount(payment?.amount);
    final method = payment?.paymentMethod?.toString().trim();

    return TaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (invoice != null)
            TaKVRow(
              label: invoice,
              // Skipping the rating leaves this row's value empty rather than
              // claiming a score the passenger never gave.
              value: rating ?? '—',
            ),
          TaKVRow(
            label: feeDisplayValue(booking?.endAddress),

            /// Money fails loudly, but a `TaKVRow` value is a short
            /// pre-formatted string — the explanation goes below the card
            /// rather than being stuffed into the row, which overflows it.
            value: amount ?? '—',
          ),
          if (method != null && method.isNotEmpty && method != 'null')
            TaKVRow(label: method, value: AppLocale.paid.tr),
          if (amount == null) ...[
            const SizedBox(height: 10),
            Text(
              AppLocale.fareUnavailable.tr,
              style: TaTextStyles.bodySmall.copyWith(color: TaColors.error),
            ),
          ],
        ],
      ),
    );
  }
}
