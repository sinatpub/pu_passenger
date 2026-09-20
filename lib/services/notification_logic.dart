import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../core/utils/app_log.dart';
import '../firebase_options.dart';
import '../routes/app_pages.dart';

class NotificationLogic {
  static FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
  static late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  static late AndroidNotificationChannel androidNotificationChannel;
  RemoteMessage? remoteMessage;

  Future<void> setupInteractedMessage() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await registerNotification();
    await initializeNotification();
    // await disableIOSForegroundBanner();
  }

  // Android: As Default it is not display banner in foreground
  // iOS: It is automatic display banner in any life cycle of app
  static Future<void> disableIOSForegroundBanner() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: false,
    );
  }

  static void showFcmSnackbar(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    Get.snackbar(
      notification.title ?? "Notification",
      notification.body ?? "",
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  static Future<void> initializeNotification() async {
    // Handle foreground messages | while running
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      xLog(message: "🧑🏽‍💻 Handle foreground");
      xLog(
        message: 'RemoteMessage'
            '\nNotification title: ${message.notification?.title}'
            '\nNotification body: ${message.notification?.body}'
            '\nNotification: ${message.notification}'
            '\nMessage data: ${message.data.toString()}',
      );
      // TaxiNotification.shared.onNotificationType();
    });

    // Handle background messages | not running but still alive
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      xLog(message: "🧑🏽‍💻 Handle background");
      if (message != null) handleOnNotificationPress(message.data);
    });

    // Handle terminated messages | not alive
    firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      xLog(message: "🧑🏽‍💻 Handle terminated");
      if (message != null) {
        handleOnNotificationPress(message.data);
      }
    });

    // Request permission for iOS
    try {
      await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        provisional: true,
        criticalAlert: true,
        sound: true,
        providesAppNotificationSettings: true,
      );
    } catch (e) {
      xPrettyLog(message: "firebaseMessaging.requestPermission $e");
    }
  }

  static Future<void> showNotificationMessage(RemoteMessage message) async {
    // Customize how you want to handle the message
    xLog(
      message: 'RemoteMessage'
          '\nNotification title: ${message.notification?.title}'
          '\nNotification body: ${message.notification?.body}'
          '\nNotification: ${message.notification}'
          '\nMessage data: ${message.data}',
    );
    if (message.notification != null) {
      RemoteNotification? notification = message.notification;
      await flutterLocalNotificationsPlugin.show(
        message.hashCode,
        message.notification?.title,
        message.notification?.body,
        NotificationDetails(
          iOS: const DarwinNotificationDetails(
            presentBadge: true,
            interruptionLevel: InterruptionLevel.critical,
            presentBanner: true,
            presentList: true,
            presentSound: true,
            // criticalSoundVolume: 1,
            presentAlert: true,
          ),
          android: AndroidNotificationDetails(
            androidNotificationChannel.id,
            androidNotificationChannel.name,
            // "${message.notification?.title}",
            // "${message.notification?.body}",
            // sound: const RawResourceAndroidNotificationSound("booking_sound"),
            playSound: true,
            silent: false,
            enableVibration: true,
            channelShowBadge: true,
            onlyAlertOnce: false,
            importance: Importance.max,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
          ),
        ),
      );
      xPrettyLog(
        message: "Android Alert Notification: ${notification.toString()}",
      );
    }
  }

  static registerNotification() {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    androidNotificationChannel = const AndroidNotificationChannel(
      "booking_channel", // id
      'High Importance Notifications', // title
      importance: Importance.max,
      showBadge: true,
      enableLights: true,
      sound: RawResourceAndroidNotificationSound("booking_sound"),
      playSound: true,
      enableVibration: true,
    );
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidNotificationChannel);
    //android
    const androidSetting = AndroidInitializationSettings("@mipmap/ic_launcher");
    // ios
    const iOSSetting = DarwinInitializationSettings(
      defaultPresentAlert: true,
      defaultPresentBadge: true,
      defaultPresentBanner: true,
      defaultPresentSound: true,
      defaultPresentList: true,
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestProvisionalPermission: true,
      requestSoundPermission: true,
    );
    //
    const initSetting = InitializationSettings(
      android: androidSetting,
      iOS: iOSSetting,
    );
    flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse: (message) {
        Map<String, dynamic> payload = jsonDecode(message.payload!);
        handleOnNotificationPress(payload);
      },
    );
  }

  static Future<void> handleOnNotificationPress(
    Map<String, dynamic> payload, {
    bool isTerminate = false,
    RemoteNotification? remoteNotification,
  }) async {
    xPrettyLog(
        message:
            "handleOnNotificationPress: $payload - ${remoteNotification.toString()}");
    if (Get.currentRoute != AppRoutes.BOOKING) {
      Get.offNamed(
        AppRoutes.BOOKING,
      );
    }
  }
}
