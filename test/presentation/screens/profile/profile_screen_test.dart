import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/presentation/screens/profile/data/models/profile_model.dart';
import 'package:com.tara.passenger/presentation/screens/profile/data/repository/profile_repository.dart';
import 'package:com.tara.passenger/presentation/screens/contact_us/view.dart';
import 'package:com.tara.passenger/presentation/screens/profile/logic.dart';
import 'package:com.tara.passenger/presentation/screens/profile/view.dart';
import 'package:com.tara.passenger/presentation/screens/term_condition/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Hand-written fake, no mocktail (`.agent/skills/testing.md`).
class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.result);

  Result<ProfileModel> result;
  int calls = 0;

  @override
  Future<Result<ProfileModel>> getProfile() async {
    calls++;
    return result;
  }
}

ProfileModel _profile({
  String? name = 'Mey Lin',
  String? phone = '12 345 678',
  String? countryCode = '+855',
}) =>
    ProfileModel(
      data: Data(name: name, phone: phone, countryCode: countryCode),
    );

Future<ProfileLogic> _pumpCard(
  WidgetTester tester, {
  Result<ProfileModel>? result,
}) async {
  final repo = _FakeProfileRepository(result ?? Ok(_profile()));
  final logic = ProfileLogic(repository: repo);
  await logic.getProfile();

  await tester.pumpWidget(
    GetMaterialApp(home: Scaffold(body: ProfileCard(logic: logic))),
  );
  await tester.pump();
  return logic;
}

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  group('profilePhone', () {
    test('joins the country code and number', () {
      expect(profilePhone('+855', '12 345 678'), '+855 12 345 678');
    });

    test('falls back to the bare number with no country code', () {
      expect(profilePhone(null, '12 345 678'), '12 345 678');
      expect(profilePhone('  ', '12 345 678'), '12 345 678');
    });

    test('no phone at all yields null, so the caller can degrade', () {
      expect(profilePhone('+855', null), isNull);
      expect(profilePhone('+855', '  '), isNull);
      expect(profilePhone(null, 'null'), isNull);
    });
  });

  group('ProfileCard (03 §Screen 15)', () {
    testWidgets('renders name, phone and initials', (tester) async {
      await _pumpCard(tester);

      expect(find.text('Mey Lin'), findsOneWidget);
      expect(find.text('+855 12 345 678'), findsOneWidget);

      final avatar = tester.widget<TaAvatar>(find.byType(TaAvatar));
      expect(avatar.initials, 'ML');
    });

    testWidgets('an account with no phone shows the see-profile prompt',
        (tester) async {
      await _pumpCard(tester, result: Ok(_profile(phone: null)));

      expect(find.text(AppLocale.seeProfile), findsOneWidget);
    });

    testWidgets('an account with no name degrades rather than showing blank',
        (tester) async {
      await _pumpCard(tester, result: Ok(_profile(name: null)));

      expect(find.text(AppLocale.unKnown), findsOneWidget);
      final avatar = tester.widget<TaAvatar>(find.byType(TaAvatar));
      expect(avatar.initials, '');
    });

    testWidgets('a failed fetch finally renders its error (B5)',
        (tester) async {
      // `ProfileLogic` has always recorded `errorMessage`; nothing displayed
      // it, so a failed fetch showed an empty card and no explanation.
      await _pumpCard(
        tester,
        result: const Err(
          ApiException(
            type: ApiErrorType.connection,
            message: 'Connection error. Please check your internet connection.',
          ),
        ),
      );

      expect(
        find.text('Connection error. Please check your internet connection.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TaButton, AppLocale.retry), findsOneWidget);
    });

    testWidgets('retry re-fetches the profile', (tester) async {
      final repo = _FakeProfileRepository(
        const Err(
          ApiException(type: ApiErrorType.connection, message: 'offline'),
        ),
      );
      final logic = ProfileLogic(repository: repo);
      await logic.getProfile();
      expect(repo.calls, 1);

      await tester.pumpWidget(
        GetMaterialApp(home: Scaffold(body: ProfileCard(logic: logic))),
      );
      await tester.pump();

      repo.result = Ok(_profile());
      await tester.tap(find.widgetWithText(TaButton, AppLocale.retry));
      await tester.pumpAndSettle();

      expect(repo.calls, 2);
      expect(find.text('Mey Lin'), findsOneWidget);
    });
  });

  group('ProfileVersionLabel', () {
    testWidgets('shows the installed version, not a hardcoded one',
        (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ProfileVersionLabel(reader: () async => '1.1.8'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('${AppLocale.version} 1.1.8'), findsOneWidget);
    });

    testWidgets('renders nothing rather than a stale or empty version',
        (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ProfileVersionLabel(reader: () async => ''),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining(AppLocale.version), findsNothing);
    });
  });

  group('Terms (03 §Screen 16)', () {
    testWidgets('renders every term with its number', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: TermConditionPage()));
      await tester.pumpAndSettle();

      expect(
        find.byType(TermRow),
        findsNWidgets(kTermsAndConditions.length),
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.text('${kTermsAndConditions.length}'), findsOneWidget);
    });

    testWidgets('the legal copy itself is unchanged', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: TermConditionPage()));
      await tester.pumpAndSettle();

      expect(find.text(kTermsAndConditions.first), findsOneWidget);
    });
  });

  group('Contact Us (03 §Screen 17)', () {
    testWidgets('renders the contact rows', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: ContactUsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Smart: +855 70 427 213'), findsOneWidget);
      expect(find.text('Cellcard: +855 12 285 048'), findsOneWidget);
      expect(find.text(ContactUsPage.email), findsOneWidget);
      expect(find.text(ContactUsPage.address), findsOneWidget);
    });

    testWidgets('the address row is not tappable', (tester) async {
      await tester.pumpWidget(const GetMaterialApp(home: ContactUsPage()));
      await tester.pumpAndSettle();

      final addressRow = tester.widget<TaProfileRow>(
        find.widgetWithText(TaProfileRow, ContactUsPage.address),
      );
      expect(addressRow.onTap, isNull);
    });

    testWidgets('the phone and email rows keep their launch handlers',
        (tester) async {
      // Roadmap S2 Risk — the spec's "→ toast" is prototype behaviour; the
      // real rows must still launch `tel:`/`mailto:`.
      await tester.pumpWidget(const GetMaterialApp(home: ContactUsPage()));
      await tester.pumpAndSettle();

      final smart = tester.widget<TaProfileRow>(
        find.widgetWithText(TaProfileRow, 'Smart: +855 70 427 213'),
      );
      final mail = tester.widget<TaProfileRow>(
        find.widgetWithText(TaProfileRow, ContactUsPage.email),
      );
      expect(smart.onTap, isNotNull);
      expect(mail.onTap, isNotNull);
    });
  });
}
