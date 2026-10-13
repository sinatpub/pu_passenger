import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:flutter_test/flutter_test.dart';

/// D40 — the rules of invite and ride credit that need no widget.
void main() {
  group('parseInviteCode', () {
    test('a typed code, whatever its case and spaces', () {
      expect(parseInviteCode('pu7k2m'), 'PU7K2M');
      expect(parseInviteCode('  PU 7K2M '), 'PU7K2M');
    });

    test('the code in an invite link', () {
      expect(parseInviteCode('https://putaxi.example/i/PU7K2M'), 'PU7K2M');
      expect(parseInviteCode('https://putaxi.example/join?code=sokha88'),
          'SOKHA88');
    });

    test('nothing, a web page or a sentence is not a code', () {
      expect(parseInviteCode(null), isNull);
      expect(parseInviteCode('   '), isNull);
      expect(parseInviteCode('https://example.com/'), isNull);
      expect(parseInviteCode('hello there!'), isNull);
    });
  });

  group('rideCreditToAsk', () {
    test('nothing while the switch is off, or with no credit', () {
      expect(rideCreditToAsk(use: false, chosen: null, balance: 2.40), 0);
      expect(rideCreditToAsk(use: true, chosen: null, balance: 0), 0);
    });

    test('the whole balance until the passenger sets an amount', () {
      expect(rideCreditToAsk(use: true, chosen: null, balance: 2.40), 2.40);
    });

    test('the amount set with "Change"', () {
      expect(rideCreditToAsk(use: true, chosen: 1, balance: 2.40), 1);
    });

    test('never more than the balance, which may have dropped', () {
      expect(rideCreditToAsk(use: true, chosen: 2, balance: 1.25), 1.25);
    });
  });

  group('the amount typed in the sheet', () {
    test('a dot or a comma for the cents', () {
      expect(parseCreditAmount('1.5'), 1.5);
      expect(parseCreditAmount('1,5'), 1.5);
      expect(parseCreditAmount(''), isNull);
      expect(parseCreditAmount('1.2.3'), isNull);
    });

    test('is checked against the balance', () {
      expect(checkCreditAmount(1, 2.40), CreditAmountCheck.ok);
      expect(checkCreditAmount(2.40, 2.40), CreditAmountCheck.ok);
      expect(checkCreditAmount(null, 2.40), CreditAmountCheck.empty);
      expect(checkCreditAmount(0, 2.40), CreditAmountCheck.notAboveZero);
      expect(checkCreditAmount(2.41, 2.40), CreditAmountCheck.moreThanBalance);
    });
  });

  group('paymentSplit', () {
    test('a fare paid partly with credit: the rest is cash', () {
      final split = paymentSplit(amount: '3.50', rideCredit: '1.00')!;
      expect(split.fare, 3.50);
      expect(split.credit, 1.00);
      expect(split.cash, 2.50);
      expect(split.usesCredit, isTrue);
    });

    test('no credit, or a backend that does not send the field', () {
      expect(paymentSplit(amount: '3.50', rideCredit: '0.00')!.usesCredit,
          isFalse);
      final split = paymentSplit(amount: '3.50', rideCredit: null)!;
      expect(split.usesCredit, isFalse);
      expect(split.cash, 3.50);
    });

    test('credit never makes the cash negative', () {
      final split = paymentSplit(amount: 2, rideCredit: 5)!;
      expect(split.credit, 2);
      expect(split.cash, 0);
    });

    test('no fare, no split', () {
      expect(paymentSplit(amount: null, rideCredit: '1.00'), isNull);
      expect(paymentSplit(amount: 'n/a', rideCredit: '1.00'), isNull);
    });
  });

  test('totals add in cents, not in floating point', () {
    const rewards = [
      ReferralReward(amount: 0.1),
      ReferralReward(amount: 0.2),
      ReferralReward(),
    ];
    expect(totalEarned(rewards), 0.3);
    expect(totalUsed(const [CreditUse(amount: 1.1), CreditUse(amount: 2.2)]),
        3.3);
  });

  test('the QR holds the link, or the bare code without one', () {
    expect(
      inviteQrData(const ReferralModel(code: 'PS4N7Q', link: 'https://x/i/PS4N7Q')),
      'https://x/i/PS4N7Q',
    );
    expect(inviteQrData(const ReferralModel(code: 'PS4N7Q')), 'PS4N7Q');
    expect(inviteQrData(const ReferralModel()), isNull);
    expect(inviteQrData(null), isNull);
  });

  test('a referral answer is read tolerantly', () {
    final model = ReferralModel.fromJson({
      'status': true,
      'data': {
        'code': 'PS4N7Q',
        'reward_balance': '2.07',
        'driver_top_up_rate': 1,
        'invitees': [
          {'id': '1', 'name': 'Sokha Vann', 'role': 'driver', 'earned': '2.00'},
          'not a person',
        ],
        'rewards': null,
        'uses': [
          {'id': 4, 'booking_id': '15', 'amount': 1}
        ],
      },
    });
    expect(model.rewardBalance, 2.07);
    expect(model.invitees.single.earned, 2.00);
    expect(model.rewards, isEmpty);
    expect(model.uses.single.bookingId, 15);
    expect(ReferralModel.fromJson(null).code, isNull);
  });
}
