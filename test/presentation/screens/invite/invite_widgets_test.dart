import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/my_qr_sheet.dart';
import 'package:com.tara.passenger/presentation/screens/invite/rewards_view.dart';
import 'package:com.tara.passenger/presentation/screens/invite/widgets/invite_code_field.dart';
import 'package:com.tara.passenger/presentation/screens/invite/widgets/payment_split_rows.dart';
import 'package:com.tara.passenger/presentation/screens/invite/widgets/ride_credit_row.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// D40 — what the invite widgets show. Texts are the English keys: without
/// loaded translations `.tr` gives the key back.
void main() {
  Widget host(Widget child) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: child,
          ),
        ),
      );

  group('InviteCodeField', () {
    Widget field(InviteCodeStatus status, {String? inviter}) => host(
          InviteCodeField(
            controller: TextEditingController(),
            status: status,
            inviterName: inviter,
            onChanged: (_) {},
            onScan: () {},
          ),
        );

    testWidgets('idle: the note, and a scan button', (t) async {
      await t.pumpWidget(field(InviteCodeStatus.idle));

      expect(find.text(AppLocale.inviteCodeNote), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('checking: a spinner in place of the scan button', (t) async {
      await t.pumpWidget(field(InviteCodeStatus.checking));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsNothing);
    });

    testWidgets('valid: who invited them', (t) async {
      await t.pumpWidget(field(InviteCodeStatus.valid, inviter: 'Dara Sok'));

      expect(find.text('Invited by Dara Sok'), findsOneWidget);
      expect(find.text(AppLocale.inviteCodeNote), findsNothing);
    });

    testWidgets('refused, and failed, each say why', (t) async {
      await t.pumpWidget(field(InviteCodeStatus.invalid));
      expect(find.text(AppLocale.inviteCodeUnknown), findsOneWidget);

      await t.pumpWidget(field(InviteCodeStatus.failed));
      expect(find.text(AppLocale.inviteCodeCheckFailed), findsOneWidget);
    });

    testWidgets('typing is upper-cased, letters and digits only', (t) async {
      final controller = TextEditingController();
      await t.pumpWidget(host(InviteCodeField(
        controller: controller,
        status: InviteCodeStatus.idle,
        onChanged: (_) {},
        onScan: () {},
      )));
      await t.enterText(find.byType(TextField), 'pu-7k 2m!');

      expect(controller.text, 'PU7K2M');
    });
  });

  group('RideCreditRow', () {
    Widget row({required bool use, double? chosen, ValueChanged<bool>? onUse}) =>
        host(RideCreditRow(
          balance: 2.40,
          use: use,
          chosen: chosen,
          onUseChanged: onUse ?? (_) {},
          onChosen: (_) {},
        ));

    testWidgets('off: the whole balance on offer, nothing to change',
        (t) async {
      await t.pumpWidget(row(use: false));

      expect(find.text('Up to \$2.40'), findsOneWidget);
      expect(find.text(AppLocale.changeAmount), findsNothing);
    });

    testWidgets('on: "Change" appears', (t) async {
      await t.pumpWidget(row(use: true));

      expect(find.text(AppLocale.changeAmount), findsOneWidget);
    });

    testWidgets('a chosen amount is what is on offer', (t) async {
      await t.pumpWidget(row(use: true, chosen: 1));

      expect(find.text('Up to \$1.00'), findsOneWidget);
    });

    testWidgets('the switch reports the choice', (t) async {
      bool? turned;
      await t.pumpWidget(row(use: false, onUse: (v) => turned = v));
      await t.tap(find.byType(Switch));

      expect(turned, isTrue);
    });

    testWidgets('the amount sheet refuses more than the balance', (t) async {
      await t.pumpWidget(
          host(const RideCreditAmountSheet(balance: 2.40, initial: 1)));
      expect(find.text('1.00'), findsOneWidget);

      await t.enterText(find.byType(TextField), '9');
      await t.tap(find.text(AppLocale.done));
      await t.pump();
      expect(find.text(AppLocale.creditMoreThanBalance), findsOneWidget);

      await t.tap(find.text(AppLocale.useAllCredit));
      await t.pump();
      expect(find.text('2.40'), findsOneWidget);
      expect(find.text(AppLocale.creditMoreThanBalance), findsNothing);
    });
  });

  group('paymentSplitRows', () {
    testWidgets('a trip with credit: credit, then the cash', (t) async {
      await t.pumpWidget(host(Column(
        children: paymentSplitRows(amount: '3.50', rideCredit: '1.00'),
      )));

      expect(find.text(AppLocale.paidByRideCredit), findsOneWidget);
      expect(find.text('\$1.00'), findsOneWidget);
      expect(find.text(AppLocale.paidInCash), findsOneWidget);
      expect(find.text('\$2.50'), findsOneWidget);
    });

    testWidgets('on the fare page the cash is still to pay', (t) async {
      await t.pumpWidget(host(Column(
        children: paymentSplitRows(
            amount: '3.50', rideCredit: '1.00', settled: false),
      )));

      expect(find.text(AppLocale.payInCash), findsOneWidget);
    });

    test('a trip without credit adds no row', () {
      expect(paymentSplitRows(amount: '3.50', rideCredit: '0.00'), isEmpty);
      expect(paymentSplitRows(amount: '3.50', rideCredit: null), isEmpty);
    });
  });

  const referral = ReferralModel(
    code: 'PS4N7Q',
    link: 'https://putaxi.example/i/PS4N7Q',
    driverTopUpRate: 1,
    passengerCommissionRate: 10,
    rewardBalance: 1.07,
    invitees: [
      Invitee(id: 1, name: 'Sokha Vann', role: 'driver', earned: 2),
    ],
    rewards: [
      ReferralReward(
          inviteeName: 'Sokha Vann',
          amount: 2.07,
          createdAt: '2026-10-10 09:00:00'),
    ],
    uses: [
      CreditUse(bookingId: 15, amount: 1, createdAt: '2026-10-12 09:05:00'),
    ],
  );

  testWidgets('My QR: the QR, the code, the rates and what was earned',
      (t) async {
    await t.pumpWidget(host(const MyQrContent(referral: referral)));

    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.text('PS4N7Q'), findsOneWidget);
    expect(find.text('1% of every top-up by a driver you invite'),
        findsOneWidget);
    expect(find.textContaining('10% of our commission'), findsOneWidget);
    expect(find.text('\$2.07 earned · 1 invited'), findsOneWidget);
    expect(find.byTooltip(AppLocale.copyCode), findsOneWidget);
    expect(find.text(AppLocale.shareInvite), findsOneWidget);
  });

  testWidgets('rewards: credit, earned and used, newest first', (t) async {
    await t.pumpWidget(host(Column(children: [
      const RideCreditSummary(referral: referral),
      ...rewardRows(referral),
    ])));

    expect(find.text('\$1.07'), findsOneWidget);
    expect(find.text('+\$2.07'), findsOneWidget);
    expect(find.text('−\$1.00'), findsOneWidget);
    final double use = t.getTopLeft(find.text(AppLocale.usedOnATrip)).dy;
    final double earned = t.getTopLeft(find.text('From Sokha Vann')).dy;
    expect(use, lessThan(earned), reason: 'the trip is the newer row');
  });

  testWidgets('people: who joined, and what each has earned', (t) async {
    await t.pumpWidget(host(Column(children: peopleRows(referral))));

    expect(find.text('Sokha Vann'), findsOneWidget);
    expect(find.text(AppLocale.driver), findsOneWidget);
    expect(find.text('Earned \$2.00'), findsOneWidget);
  });

  testWidgets('nobody yet: an invitation, not a blank', (t) async {
    await t.pumpWidget(host(Column(
      children: [
        ...rewardRows(const ReferralModel()),
        ...peopleRows(const ReferralModel()),
      ],
    )));

    expect(find.text(AppLocale.noRewardsYet), findsOneWidget);
    expect(find.text(AppLocale.noPeopleYet), findsOneWidget);
  });

  testWidgets('could not load: as wide as the sheet it is alone in', (t) async {
    // A bottom sheet takes the width of its content. Alone in "My invite QR",
    // the message used to leave a sheet as narrow as its one line of text.
    await t.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [InviteLoadError(onRetry: () {})],
          ),
        ),
      ),
    ));

    expect(find.text(AppLocale.couldntLoadRewards), findsOneWidget);
    expect(
      t.getSize(find.byType(InviteLoadError)).width,
      t.getSize(find.byType(Scaffold)).width,
    );
  });
}
