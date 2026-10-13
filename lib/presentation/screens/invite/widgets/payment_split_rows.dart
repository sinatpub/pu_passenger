import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// "Paid by ride credit" and the cash that is left, for a trip that used
/// credit (D40). Nothing for a trip that did not: those screens stay as they
/// were.
///
/// [settled] is false on the fare page, where the cash is still to be paid.
List<Widget> paymentSplitRows({
  required Object? amount,
  required Object? rideCredit,
  bool settled = true,
}) {
  final PaymentSplit? split =
      paymentSplit(amount: amount, rideCredit: rideCredit);
  if (split == null || !split.usesCredit) return const <Widget>[];
  return <Widget>[
    TaKVRow(
      label: AppLocale.paidByRideCredit.tr,
      value: formatMoney(split.credit),
    ),
    TaKVRow(
      label: settled ? AppLocale.paidInCash.tr : AppLocale.payInCash.tr,
      value: formatMoney(split.cash),
    ),
  ];
}
