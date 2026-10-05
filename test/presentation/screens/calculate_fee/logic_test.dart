import 'dart:async';

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/data/datasources/check_request_book_source.dart';
import 'package:com.tara.passenger/data/models/request_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/calculate_fee_screen.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/logic.dart';
import 'package:com.tara.passenger/presentation/screens/rating/rating_prompt_store.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fare request the test answers by hand: each call waits until it is
/// completed or failed. Hand-written fake, no mocktail
/// (`.agent/skills/testing.md`).
class _FakeCheckBookingApi extends CheckBookingApi {
  final List<Completer<RequestBookingModel>> calls = [];

  @override
  Future<RequestBookingModel> checkBookingApi() {
    final call = Completer<RequestBookingModel>();
    calls.add(call);
    return call.future;
  }
}

/// `syncNavigateBack` re-inits the socket on its way out; the real one reads
/// storage and opens a connection.
// ignore: must_call_super
class _FakeAppLogic extends AppLogic {
  int socketInits = 0;

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  Future<void> initSocket({required BuildContext context}) async {
    socketInits++;
  }
}

RequestBookingModel _trip({String? amount = '17800'}) => RequestBookingModel(
      data: Data(
        id: 7,
        startAddress: 'Central Market',
        driver: Driver(name: 'Dara Sok'),
        payment: Payment(amount: amount, paymentMethod: 'Wallet'),
      ),
    );

void main() {
  late _FakeCheckBookingApi api;

  setUp(() {
    Get.testMode = true;
    Get.reset();
    api = _FakeCheckBookingApi();
  });

  tearDown(Get.reset);

  group('CalculateFeeLogic.getCalculateFeeApi', () {
    test('loads the trip', () async {
      final logic = CalculateFeeLogic(checkBookingApi: api);

      final loading = logic.getCalculateFeeApi();
      expect(logic.state.isLoading.value, isTrue);
      api.calls.single.complete(_trip());
      await loading;

      expect(logic.state.isLoading.value, isFalse);
      expect(logic.state.hasError.value, isFalse);
      expect(logic.state.data.value?.data?.payment?.amount, '17800');
    });

    test('a failed request is recorded, not swallowed', () async {
      final logic = CalculateFeeLogic(checkBookingApi: api);

      final loading = logic.getCalculateFeeApi();
      api.calls.single.completeError('connection error');
      await loading;

      expect(logic.state.isLoading.value, isFalse);
      expect(logic.state.hasError.value, isTrue);
    });

    test('a retry that succeeds clears the failure', () async {
      final logic = CalculateFeeLogic(checkBookingApi: api);

      final first = logic.getCalculateFeeApi();
      api.calls[0].completeError('connection error');
      await first;

      final retry = logic.getCalculateFeeApi();
      expect(logic.state.hasError.value, isFalse,
          reason: 'the skeleton shows while the retry is out');
      api.calls[1].complete(_trip());
      await retry;

      expect(logic.state.hasError.value, isFalse);
      expect(logic.state.data.value?.data?.id, 7);
    });
  });

  group('CalculateFeeScreen', () {
    Future<void> pumpScreen(WidgetTester tester) async {
      // `Get.put` runs `onInit`, which starts the first request.
      Get.put<CalculateFeeLogic>(CalculateFeeLogic(checkBookingApi: api));
      await tester.pumpWidget(
        const GetMaterialApp(home: CalculateFeeScreen()),
      );
      await tester.pump();
    }

    testWidgets('skeleton, then the fare', (tester) async {
      await pumpScreen(tester);
      expect(find.byType(FeeLoadingView), findsOneWidget);

      api.calls.single.complete(_trip());
      await tester.pump();

      expect(find.byType(FeeContent), findsOneWidget);
      expect(find.text('17,800 ${AppLocale.khmerCurrency}'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
    });

    testWidgets('a failed load offers Retry, and Retry loads the fare',
        (tester) async {
      await pumpScreen(tester);
      api.calls.single.completeError('connection error');
      await tester.pump();

      expect(find.byType(FeeErrorView), findsOneWidget);
      expect(find.text(AppLocale.couldNotLoadFare), findsOneWidget);

      await tester.tap(find.text(AppLocale.retry));
      await tester.pump();
      expect(api.calls, hasLength(2));
      expect(find.byType(FeeLoadingView), findsOneWidget);

      api.calls[1].complete(_trip());
      await tester.pump();

      expect(find.byType(FeeErrorView), findsNothing);
      expect(find.text('17,800 ${AppLocale.khmerCurrency}'), findsOneWidget);
    });

    testWidgets('an answer with no booking in it is a failed load too',
        (tester) async {
      await pumpScreen(tester);
      api.calls.single.complete(RequestBookingModel());
      await tester.pump();

      expect(find.byType(FeeErrorView), findsOneWidget);
      expect(find.byType(TaDriverCard), findsNothing,
          reason: 'not a receipt made of dashes');
    });
  });

  /// The driver confirmed the payment. The rating used to be a page between
  /// the fare and the Thank you page; it is now a dialog the Thank you page
  /// opens, so the fare page always hands over to that page and only tells it
  /// whether to ask.
  group('CalculateFeeLogic.syncNavigateBack', () {
    const receiptMarker = Key('receipt-stub');
    const homeMarker = Key('home-stub');
    Object? receiptArguments;

    Future<CalculateFeeLogic> pumpFee(
      WidgetTester tester, {
      RequestBookingModel? loaded,
      List<String> handled = const [],
    }) async {
      receiptArguments = null;
      SharedPreferences.setMockInitialValues(
          {'rating_handled_booking_ids': handled});
      final logic = CalculateFeeLogic(
        checkBookingApi: api,
        promptStore: RatingPromptStore(
          preferences: await SharedPreferences.getInstance(),
        ),
      );
      logic.state.data.value = loaded;
      Get.put<AppLogic>(_FakeAppLogic());

      await tester.pumpWidget(GetMaterialApp(
        builder: EasyLoading.init(),
        initialRoute: '/fee',
        getPages: [
          GetPage(name: '/fee', page: () => const Scaffold()),
          GetPage(
            name: AppRoutes.RECEIPT,
            page: () {
              receiptArguments = Get.arguments;
              return const Scaffold(body: SizedBox(key: receiptMarker));
            },
          ),
          GetPage(
            name: AppRoutes.BOTTOMNAV,
            page: () => const Scaffold(body: SizedBox(key: homeMarker)),
          ),
        ],
      ));
      await tester.pump();
      return logic;
    }

    /// The handler's own 2s settle, then the route change and the loader.
    Future<void> settle(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
    }

    testWidgets('goes to the Thank you page and asks it to offer the rating',
        (tester) async {
      final logic = await pumpFee(tester, loaded: _trip());

      logic.syncNavigateBack();
      await settle(tester);

      expect(find.byKey(receiptMarker), findsOneWidget);
      final args = receiptArguments as Map;
      expect((args['booking'] as Data).id, 7);
      expect(args['promptRating'], isTrue);
      expect((Get.find<AppLogic>() as _FakeAppLogic).socketInits, 1);
    });

    testWidgets('a trip already rated or skipped still gets its Thank you '
        'page, without being asked again', (tester) async {
      final logic = await pumpFee(tester, loaded: _trip(), handled: ['7']);

      logic.syncNavigateBack();
      await settle(tester);

      expect(find.byKey(receiptMarker), findsOneWidget);
      expect((receiptArguments as Map)['promptRating'], isFalse);
    });

    testWidgets('with no trip loaded there is nothing to thank for: home',
        (tester) async {
      final logic = await pumpFee(tester);

      logic.syncNavigateBack();
      await settle(tester);

      expect(find.byKey(homeMarker), findsOneWidget);
      expect(find.byKey(receiptMarker), findsNothing);
    });
  });
}
