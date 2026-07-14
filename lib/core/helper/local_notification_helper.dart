import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../utils/app_constant.dart';
import '../utils/pretty_logger.dart';
import '../utils/status_util.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class NotificationLocal {
  static final notifications = FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    '${AppConstant.titleApp} Notification V2',
    '${AppConstant.titleApp} Taxi',
    description: 'Channel for ${AppConstant.titleApp} notifications',
    importance: Importance.high,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('booking_sound'),
    showBadge: true,
  );

  // * Init Local Notification
  initLocationNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped with payload: ${response.payload}');
      },
    );

    // Create the notification channel for Android
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    tlog("Init Local Notification");
  }

  // 3. Request Permission Method
  Future<bool> requestPermission() async {
    bool? permissionGranted = false;

    if (Platform.isIOS || Platform.isMacOS) {
      permissionGranted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      // Request permissions for Android 13+
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      permissionGranted =
          await androidImplementation?.requestNotificationsPermission();
    }

    return permissionGranted ?? false;
  }

  static Future<void> notificationBooking(
      {required AndroidNotificationChannel channel,
      required FlutterLocalNotificationsPlugin plugin,
      required String title,
      bool useCustomSound = false,
      String? description}) async {
    const int notificationId = FcmType.request;
    final channelId = useCustomSound ? 'booking_urgent' : 'booking_normal';
    // Cancel any existing notifications with the same ID
    await plugin.cancel(notificationId);
    // Android Notification Details
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channelId,
      useCustomSound ? 'Urgent Booking' : 'Booking',
      channelDescription: channel.description,
      importance: Importance.high,
      priority: Priority.high,
      sound: null,
      // useCustomSound
      //     ? const RawResourceAndroidNotificationSound('booking_sound')
      //     : null,
      playSound: true,
      autoCancel: true,
      icon: "@mipmap/ic_launcher",
      enableLights: useCustomSound,
      enableVibration: useCustomSound,
      ongoing: false,
      channelShowBadge: true,
      fullScreenIntent: false,
      ticker: 'Booking',
    );

    // iOS Notification Details
    DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentSound: useCustomSound,
      presentBadge: useCustomSound,
      presentAlert: useCustomSound,
      sound: useCustomSound ? 'booking_sound.wav' : null,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    // await plugin.cancelAll();
    // Show the notification
    await plugin.show(
      notificationId,
      title,
      description,
      platformChannelSpecifics,
    );
  }
}
