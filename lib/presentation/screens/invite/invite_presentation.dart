import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/money.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';

/// The rules of the invite feature that need no widget (D40): reading a code
/// out of what was typed or scanned, adding rewards up, and splitting a fare
/// between ride credit and cash.

enum InviteeRole {
  driver,
  passenger,
  unknown;

  static InviteeRole of(String? role) => switch (role?.toLowerCase()) {
        'driver' => InviteeRole.driver,
        'passenger' => InviteeRole.passenger,
        _ => InviteeRole.unknown,
      };
}

/// Letters and digits only. The length is the server's rule, not the app's.
final RegExp _codePattern = RegExp(r'^[A-Z0-9]{4,12}$');

/// The invite code in [raw], or null when there is none.
///
/// [raw] is what a person typed, or what a QR held: the code itself, or the
/// invite link, whose code is `?code=` or the last path segment. Letter case
/// and spaces are ignored.
String? parseInviteCode(String? raw) {
  final String text = (raw ?? '').trim();
  if (text.isEmpty) return null;

  String candidate = text;
  final Uri? uri = Uri.tryParse(text);
  if (uri != null && uri.hasScheme) {
    candidate = uri.queryParameters['code'] ??
        (uri.pathSegments.isEmpty ? '' : uri.pathSegments.last);
  }
  candidate = candidate.replaceAll(' ', '').toUpperCase();
  return _codePattern.hasMatch(candidate) ? candidate : null;
}

/// What the passenger's QR holds: the link, or the bare code without one.
String? inviteQrData(ReferralModel? referral) {
  final String? link = referral?.link;
  if (link != null && link.isNotEmpty) return link;
  final String? code = referral?.code;
  return code == null || code.isEmpty ? null : code;
}

double totalEarned(List<ReferralReward> rewards) =>
    roundToCents(rewards.fold<double>(0, (sum, r) => sum + (r.amount ?? 0)));

double totalUsed(List<CreditUse> uses) =>
    roundToCents(uses.fold<double>(0, (sum, u) => sum + (u.amount ?? 0)));

/// The amount typed in the ride credit sheet, or null when it is not one.
/// A comma is taken for the decimal point, as some keyboards give it.
double? parseCreditAmount(String text) {
  final double? amount = double.tryParse(text.trim().replaceAll(',', '.'));
  return amount == null || amount.isNaN ? null : roundToCents(amount);
}

enum CreditAmountCheck { ok, empty, notAboveZero, moreThanBalance }

CreditAmountCheck checkCreditAmount(double? amount, double balance) {
  if (amount == null) return CreditAmountCheck.empty;
  if (amount <= 0) return CreditAmountCheck.notAboveZero;
  if (amount > balance) return CreditAmountCheck.moreThanBalance;
  return CreditAmountCheck.ok;
}

/// What goes out as `ride_credit` with a booking: the most credit to use.
///
/// Zero when the switch is off or there is no credit. [chosen] is the amount
/// the passenger set with "Change"; without one it is the whole balance. It
/// is never more than the balance, which can have dropped since they chose.
double rideCreditToAsk({
  required bool use,
  required double? chosen,
  required double balance,
}) {
  if (!use || balance <= 0) return 0;
  final double wanted = chosen == null || chosen <= 0 ? balance : chosen;
  return roundToCents(wanted > balance ? balance : wanted);
}

/// A fare split between ride credit and cash.
class PaymentSplit {
  const PaymentSplit({
    required this.fare,
    required this.credit,
    required this.cash,
  });

  final double fare;
  final double credit;
  final double cash;

  bool get usesCredit => credit > 0;
}

/// Splits `payment.amount` by `payment.ride_credit`. Null when there is no
/// fare to split. Credit below zero counts as none, credit above the fare
/// counts as the fare: the cash is never negative.
PaymentSplit? paymentSplit(
    {required Object? amount, required Object? rideCredit}) {
  final double? fare = doubleOrNull(amount);
  if (fare == null) return null;
  final double asked = doubleOrNull(rideCredit) ?? 0;
  final double credit = asked <= 0 ? 0 : (asked > fare ? fare : asked);
  return PaymentSplit(
    fare: fare,
    credit: roundToCents(credit),
    cash: roundToCents(fare - credit),
  );
}
