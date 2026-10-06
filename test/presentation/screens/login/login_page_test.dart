// ignore_for_file: must_call_super — the harness skips AppLogic's heavyweight
// onInit, as the Home screen tests do.

import 'dart:io';

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/debug_auth_bypass.dart';
import 'package:com.tara.passenger/data/models/login_phone_model.dart';
import 'package:com.tara.passenger/data/models/register_model.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/presentation/screens/login/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAppLogic extends AppLogic {
  @override
  void onInit() {
    languageKeyCode.value = AppConstant.englishCode;
  }
}

/// Hand-written fake, no mocktail (`.agent/skills/testing.md`). Every call is
/// counted: the debug login must not reach the backend from a build that has
/// not asked for the bypass.
class _CountingAuthRepository implements AuthRepository {
  int calls = 0;

  @override
  Future<Result<UserResponseModel>> passwordLogin({
    required String phone,
    required String password,
    required String deviceToken,
    required String platform,
  }) async {
    calls++;
    return Ok(UserResponseModel());
  }

  @override
  Future<Result<PhoneNumberModel>> loginPhone(String phone) {
    calls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<UserResponseModel>> verifyOtp({
    required String phone,
    required String otpCode,
  }) {
    calls++;
    throw UnimplementedError();
  }

  @override
  Future<Result<RegisterModel>> register({
    required String fullName,
    required String phoneNumber,
    File? profileImage,
    required String platform,
  }) {
    calls++;
    throw UnimplementedError();
  }
}

void main() {
  late _CountingAuthRepository repo;
  late LoginLogic logic;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    repo = _CountingAuthRepository();
    logic = LoginLogic(repository: repo);
    Get.put<AppLogic>(_FakeAppLogic(), permanent: true);
    Get.put<LoginLogic>(logic);
  });

  tearDown(Get.reset);

  Future<void> pump(WidgetTester tester, {bool? showDebugLogin}) async {
    await tester.pumpWidget(
      GetMaterialApp(home: LoginPage(showDebugLogin: showDebugLogin)),
    );
    await tester.pump();
  }

  testWidgets('no debug login unless the build asks for the bypass',
      (tester) async {
    await pump(tester);

    expect(find.text(DebugAuthBypass.loginLabel), findsNothing);
    expect(find.byType(TaButton), findsOneWidget);
  });

  testWidgets('the debug login sits under Next and says which account',
      (tester) async {
    await pump(tester, showDebugLogin: true);

    expect(find.text(DebugAuthBypass.loginLabel), findsOneWidget);
    expect(find.text(DebugAuthBypass.loginCaption), findsOneWidget);
    expect(
      tester.getTopLeft(find.text(DebugAuthBypass.loginLabel)).dy,
      greaterThan(tester.getBottomLeft(find.text(AppLocale.next)).dy),
    );
  });

  testWidgets('tapping it without the bypass signs nobody in', (tester) async {
    await pump(tester, showDebugLogin: true);
    await tester.tap(find.text(DebugAuthBypass.loginLabel));
    await tester.pump();

    expect(logic.state.debugLoggingIn.value, isFalse);
    expect(find.byType(LoginPage), findsOneWidget);
    expect(repo.calls, 0);
  });

  testWidgets('while it signs in, the field and Next are locked',
      (tester) async {
    await pump(tester, showDebugLogin: true);
    logic.state.debugLoggingIn.value = true;
    await tester.pump();

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
    // By position: a loading button shows a spinner, not its label.
    final buttons = tester.widgetList<TaButton>(find.byType(TaButton)).toList();
    expect(buttons.first.label, AppLocale.next);
    expect(buttons.first.isEnabled, isFalse);
    expect(buttons.last.label, DebugAuthBypass.loginLabel);
    expect(buttons.last.isLoading, isTrue);
  });
}
