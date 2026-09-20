// ignore_for_file: must_call_super — this harness overrides the heavyweight
// onInit/onReady of the real controllers to render states without side effects.

import 'package:com.tara.passenger/app/logic.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/data/models/vehical_model.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:com.tara.passenger/presentation/screens/home/view.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Light no-op doubles so HomeScreen can render its GetBuilder/Obx without
/// network or heavy collaborators. Behaviour stays 100 % driven by the
/// real HomeState/HomeLogic wiring.
class _FakeAppLogic extends AppLogic {
  @override
  void onInit() {
    // no super — the real onInit reads live storage + locale and schedules
    // frames that break the widget-test frame guard.
    languageKeyCode.value = AppConstant.englishCode;
  }
}

class _HomeLogicHarness extends HomeLogic {
  @override
  Future<void> onInit() async {}

  @override
  Future<void> onReady() async {}

  @override
  Future<void> getVehicleType() async {}
  @override
  Future<void> checkingBookingStatus() async {}
  @override
  Future<void> pushFcmToken() async {}
  @override
  Future<void> requestPermissionLocation() async {}
}

void main() {
  late _FakeAppLogic appLogic;
  late _HomeLogicHarness homeLogic;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.testMode = true;
    appLogic = _FakeAppLogic();
    homeLogic = _HomeLogicHarness();
    Get.put<AppLogic>(appLogic, permanent: true);
    Get.put<HomeLogic>(homeLogic, permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  group('HomeScreen states (C2)', () {
    testWidgets('loading → skeleton rows', (tester) async {
      homeLogic.state.isLoading = RxStatus.loading();
      homeLogic.update();
      await tester.pumpWidget(GetMaterialApp(home: HomeScreen()));
      await tester.pump();
      expect(find.byType(TaSkeletonCard), findsNWidgets(3));
      expect(find.byType(TaVehicleRow), findsNothing);
    });

    testWidgets('loaded → vehicle rows with name/seats/price/eta',
        (tester) async {
      homeLogic.state.vehicleAllType = VehicalTypeEntities(
        data: [
          SingleVehical(
            id: 1,
            name: 'Rickshaw',
            price: 1500,
            orderKey: 1,
            miniMunFare: 4000,
            image: null,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        ],
        message: '',
        status: true,
      );
      homeLogic.state.isLoading = RxStatus.success();
      homeLogic.update();
      await tester.pumpWidget(GetMaterialApp(home: HomeScreen()));
      await tester.pump();

      expect(find.byType(TaVehicleRow), findsOneWidget);
      expect(find.text('Rickshaw'), findsOneWidget);
      expect(find.textContaining('1,500'), findsWidgets); // pricePerKm / priceFrom
      expect(find.textContaining('2 min'), findsWidgets); // ETA
    });

    testWidgets('error → skeleton rows (toast fired separately by logic)',
        (tester) async {
      homeLogic.state.isLoading = RxStatus.error();
      homeLogic.update();
      await tester.pumpWidget(GetMaterialApp(home: HomeScreen()));
      await tester.pump();
      expect(find.byType(TaSkeletonCard), findsNWidgets(3));
      expect(find.byType(TaVehicleRow), findsNothing);
    });

    testWidgets('empty → EmptyData message', (tester) async {
      homeLogic.state.vehicleAllType = null;
      homeLogic.state.isLoading = RxStatus.success();
      homeLogic.update();
      await tester.pumpWidget(GetMaterialApp(home: HomeScreen()));
      await tester.pump();
      expect(find.byType(EmptyData), findsOneWidget);
      expect(find.text(AppLocale.noVehicleAvailable.tr), findsOneWidget);
    });
  });
}