import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// "Use ride credit" on the booking sheet (D40, option 1b): a switch that
/// takes the whole balance, and "Change" for a part of it.
///
/// The amount is "up to": the fare is not known until drop-off, and the
/// server never uses more credit than the fare.
class RideCreditRow extends StatelessWidget {
  const RideCreditRow({
    super.key,
    required this.balance,
    required this.use,
    required this.chosen,
    required this.onUseChanged,
    required this.onChosen,
  });

  /// Ride credit the passenger has.
  final double balance;
  final bool use;

  /// The amount set with "Change"; null means the whole balance.
  final double? chosen;
  final ValueChanged<bool> onUseChanged;
  final ValueChanged<double?> onChosen;

  @override
  Widget build(BuildContext context) {
    final double upTo =
        rideCreditToAsk(use: true, chosen: chosen, balance: balance);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TaColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.confirmation_number_outlined,
              size: 20, color: TaColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocale.useRideCredit.tr,
                  style: TaTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TaColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        AppLocale.upToAmount
                            .trParams({'amount': formatMoney(upTo)}),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TaTextStyles.bodySmall
                            .copyWith(color: TaColors.textSecondary),
                      ),
                    ),
                    if (use)
                      Semantics(
                        button: true,
                        child: TaPressable(
                          onTap: () => _change(context),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Text(
                              AppLocale.changeAmount.tr,
                              style: TaTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w700,
                                color: TaColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: use,
            activeTrackColor: TaColors.primary,
            onChanged: onUseChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _change(BuildContext context) async {
    final double? amount = await TaBottomSheet.show<double>(
      context,
      RideCreditAmountSheet(balance: balance, initial: chosen),
    );
    if (amount == null) return;
    // The whole balance is "all": it follows the balance if that grows.
    onChosen(amount >= balance ? null : amount);
  }
}

/// The amount of ride credit for one trip. Pops with the amount on "Done".
class RideCreditAmountSheet extends StatefulWidget {
  const RideCreditAmountSheet({super.key, required this.balance, this.initial});

  final double balance;
  final double? initial;

  @override
  State<RideCreditAmountSheet> createState() => _RideCreditAmountSheetState();
}

class _RideCreditAmountSheetState extends State<RideCreditAmountSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: (widget.initial ?? widget.balance).toStringAsFixed(2),
  );

  /// Said only after "Done" was pressed on a wrong amount.
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final double? amount = parseCreditAmount(_controller.text);
    final String? error = switch (checkCreditAmount(amount, widget.balance)) {
      CreditAmountCheck.ok => null,
      CreditAmountCheck.moreThanBalance => AppLocale.creditMoreThanBalance.tr,
      CreditAmountCheck.empty ||
      CreditAmountCheck.notAboveZero =>
        AppLocale.creditAboveZero.tr,
    };
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // The sheet's own scroll view does not move for the keyboard.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocale.rideCreditForTrip.tr,
            style: TaTextStyles.headlineMedium,
          ),
          const SizedBox(height: 4),
          Text(
            AppLocale.amountAvailable
                .trParams({'amount': formatMoney(widget.balance)}),
            style:
                TaTextStyles.bodySmall.copyWith(color: TaColors.textSecondary),
          ),
          const SizedBox(height: 14),
          TaTextField(
            controller: _controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              LengthLimitingTextInputFormatter(8),
            ],
            errorText: _error,
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
            prefix: const Text('\$', style: TaTextStyles.titleLarge),
            suffix: Semantics(
              button: true,
              child: TaPressable(
                onTap: () {
                  _controller.text = widget.balance.toStringAsFixed(2);
                  if (_error != null) setState(() => _error = null);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: TaColors.primaryBg,
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    AppLocale.useAllCredit.tr,
                    style: TaTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TaColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            AppLocale.creditSheetNote.tr,
            style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
          ),
          const SizedBox(height: 16),
          TaButton(label: AppLocale.done.tr, onTap: _submit),
        ],
      ),
    );
  }
}
