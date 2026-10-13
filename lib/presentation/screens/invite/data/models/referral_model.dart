import 'package:com.tara.passenger/core/utils/json_field.dart';

/// `GET /taxi-passenger/referral` (D40): the passenger's invite code, their
/// ride credit, who they invited, what that earned and where credit went.
///
/// Every field is read tolerantly, like the rest of the app's models: the
/// backend does not exist yet, and when it does a number may arrive as text.
class ReferralModel {
  const ReferralModel({
    this.code,
    this.link,
    this.driverTopUpRate,
    this.passengerCommissionRate,
    this.rewardBalance,
    this.invitees = const <Invitee>[],
    this.rewards = const <ReferralReward>[],
    this.uses = const <CreditUse>[],
  });

  factory ReferralModel.fromJson(dynamic json) {
    final Map<String, dynamic> map = _data(json);
    return ReferralModel(
      code: stringOrNull(map['code']),
      link: stringOrNull(map['link']),
      driverTopUpRate: doubleOrNull(map['driver_top_up_rate']),
      passengerCommissionRate: doubleOrNull(map['passenger_commission_rate']),
      rewardBalance: doubleOrNull(map['reward_balance']),
      invitees: _list(map['invitees'], Invitee.fromJson),
      rewards: _list(map['rewards'], ReferralReward.fromJson),
      uses: _list(map['uses'], CreditUse.fromJson),
    );
  }

  final String? code;

  /// What the QR holds. The code is its last path segment.
  final String? link;

  /// Percent of an invited driver's top-up.
  final double? driverTopUpRate;

  /// Percent of the company's commission on an invited passenger's trip.
  final double? passengerCommissionRate;

  /// Ride credit the passenger can use now: earned minus used.
  final double? rewardBalance;

  final List<Invitee> invitees;
  final List<ReferralReward> rewards;

  /// One row for each completed trip that used credit.
  final List<CreditUse> uses;
}

class Invitee {
  const Invitee(
      {this.id, this.name, this.image, this.role, this.joinedAt, this.earned});

  factory Invitee.fromJson(Map<String, dynamic> json) => Invitee(
        id: intOrNull(json['id']),
        name: stringOrNull(json['name']),
        image: stringOrNull(json['profile_image']),
        role: stringOrNull(json['role']),
        joinedAt: stringOrNull(json['joined_at']),
        earned: doubleOrNull(json['earned']),
      );

  final int? id;
  final String? name;
  final String? image;

  /// `"driver"` or `"passenger"`.
  final String? role;
  final String? joinedAt;

  /// Everything this person has earned the inviter.
  final double? earned;
}

class ReferralReward {
  const ReferralReward(
      {this.id, this.inviteeName, this.role, this.amount, this.createdAt});

  factory ReferralReward.fromJson(Map<String, dynamic> json) => ReferralReward(
        id: intOrNull(json['id']),
        inviteeName: stringOrNull(json['invitee_name']),
        role: stringOrNull(json['invitee_role']),
        amount: doubleOrNull(json['amount']),
        createdAt: stringOrNull(json['created_at']),
      );

  final int? id;
  final String? inviteeName;
  final String? role;
  final double? amount;
  final String? createdAt;
}

class CreditUse {
  const CreditUse({this.id, this.bookingId, this.amount, this.createdAt});

  factory CreditUse.fromJson(Map<String, dynamic> json) => CreditUse(
        id: intOrNull(json['id']),
        bookingId: intOrNull(json['booking_id']),
        amount: doubleOrNull(json['amount']),
        createdAt: stringOrNull(json['created_at']),
      );

  final int? id;
  final int? bookingId;
  final double? amount;
  final String? createdAt;
}

/// `GET /taxi-passenger/referral/check-code`.
class InviteCodeCheck {
  const InviteCodeCheck({required this.valid, this.inviterName});

  factory InviteCodeCheck.fromJson(dynamic json) {
    final Map<String, dynamic> map = _data(json);
    return InviteCodeCheck(
      valid: map['valid'] == true,
      inviterName: stringOrNull(map['inviter_name']),
    );
  }

  final bool valid;
  final String? inviterName;
}

Map<String, dynamic> _data(dynamic json) {
  final dynamic data = json is Map<String, dynamic> ? json['data'] : null;
  return data is Map<String, dynamic> ? data : const <String, dynamic>{};
}

List<T> _list<T>(dynamic json, T Function(Map<String, dynamic>) decode) => <T>[
      for (final dynamic item in json is List ? json : const <dynamic>[])
        if (item is Map<String, dynamic>) decode(item),
    ];
