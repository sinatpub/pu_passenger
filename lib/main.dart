import 'package:com.tara.passenger/app/root_main.dart';
import 'package:com.tara.passenger/app/service.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/service/notification_logic.dart';
import 'package:com.tara.passenger/taxi_single_ton/taxi_notification.dart';
import 'package:com.tara.passenger/presentation/widgets/custom_animated_loading.dart';
import 'package:com.tara.passenger/core/api_service/client/dio_http_client.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'translations/app_locale.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
@pragma('vm:entry-point')
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  BaseHttpClient.init();
  WidgetsFlutterBinding.ensureInitialized();
  // init firebase notification — also initializes Firebase itself, which
  // Crashlytics below depends on
  await NotificationLogic().setupInteractedMessage();

  // F-09 / Phase 0.6 (docs/12, docs/05): firebase_crashlytics was declared in
  // pubspec.yaml but never referenced anywhere in lib/, so the passenger app
  // shipped with crash reporting as a dependency and not as a feature. Wired
  // here to match pu_driver (2026-08-29), including the debug-mode opt-out so
  // local crashes stay out of production data.
  await FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(!kDebugMode);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await TaxiNotification.shared.initLocationNotification();

  await initialService();
  configLoading();

  runApp(
    const ToastificationWrapper(child: Root()),
  );
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.light
    ..indicatorSize = 45.0
    ..radius = 18.0
    ..infoWidget = const ShowInfoWidget()
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..contentPadding = EdgeInsets.zero
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withValues(alpha: 0.5)
    ..userInteractions = true
    ..dismissOnTap = true
    ..customAnimation = CustomAnimation();
}

class ShowInfoWidget extends StatelessWidget {
  const ShowInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8..d),
      child: SizedBox(
        height: 260..d,
        width: 300..d,
        child: Column(
          children: [
            const Icon(Icons.report_problem, color: Colors.redAccent, size: 56),
            const SizedBox(height: 16),
            const Text(
              "Driver Cancelled the Trip",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "We're sorry, but your driver has canceled the trip after accepting your booking. You can request a new ride.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      EasyLoading.dismiss();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: Text(AppLocale.close.tr),
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
