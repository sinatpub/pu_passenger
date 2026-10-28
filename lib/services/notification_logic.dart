import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../core/utils/app_log.dart';
import '../data/datasources/check_request_book_source.dart';
import '../data/models/request_booking_model.dart';
import '../firebase_options.dart';
import '../presentation/screens/home/booking_redirect.dart';
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
    await showIOSForegroundBanner();
    await initializeNotification();
  }

  // Neither platform shows a message that arrives while the app is open.
  // iOS does once it is asked to here; Android never does, so the foreground
  // listener below raises the notification itself.
  static Future<void> showIOSForegroundBanner() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
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
      // iOS shows its own banner (showIOSForegroundBanner); raising one here
      // as well would show the message twice.
      if (Platform.isAndroid) showNotificationMessage(message);
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
        handleOnNotificationPress(message.data, isTerminate: true);
      }
    });

    // Request permission for iOS
    //
    // Not provisional: iOS grants a provisional request without asking and
    // then delivers every notification quietly, with no banner and no sound.
    try {
      await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
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
        // A notification raised while the app is open carries no payload:
        // the passenger is already on the screen it is about.
        final String? payload = message.payload;
        if (payload == null || payload.isEmpty) return;
        handleOnNotificationPress(jsonDecode(payload));
      },
    );
  }

  /// Audit S-4: this opened the ride screen for every tap — an announcement,
  /// a promotion, anything — whether or not there was a ride. Now:
  ///
  ///  * a push about an announcement opens that announcement;
  ///  * anything else asks the server for the passenger's booking and goes
  ///    where Home would send them on launch ([bookingRedirectRoute]): the
  ///    ride screen, the fee page, or nowhere;
  ///  * a push that launched the app ([isTerminate]) navigates nowhere:
  ///    the splash screen is still running, and Home sends the passenger
  ///    into an active trip by itself (P-03).
  static Future<void> handleOnNotificationPress(
    Map<String, dynamic> payload, {
    bool isTerminate = false,
    RemoteNotification? remoteNotification,
    CheckBookingApi? checkBookingApi,
  }) async {
    xPrettyLog(
        message:
            "handleOnNotificationPress: $payload - ${remoteNotification.toString()}");
    if (isTerminate) return;

    final int? announcementId = announcementIdOf(payload);
    if (announcementId != null) {
      Get.toNamed(AppRoutes.ANNOUNCEMENTDETAIL, arguments: {'id': announcementId});
      return;
    }

    final RequestBookingModel booking;
    try {
      booking = await (checkBookingApi ?? CheckBookingApi()).checkBookingApi();
    } catch (e) {
      xPrettyLog(message: "Notification tap: could not read the booking: $e");
      return;
    }
    final String? route = bookingRedirectRoute(booking.data?.status);
    if (route != null && Get.currentRoute != route) Get.offNamed(route);
  }
}

/// The announcement a push is about, or null when it is not about one. The
/// id is `notification_id`, the key the driver app reads off the same
/// backend's pushes.
int? announcementIdOf(Map<String, dynamic> payload) =>
    int.tryParse('${payload['notification_id'] ?? ''}');
