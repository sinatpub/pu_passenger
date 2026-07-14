import 'dart:async';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../core/helper/local_notification_helper.dart';
import '../data/datasources/check_request_book_source.dart';

class TaxiNotification {
  TaxiNotification._internal();

  static TaxiNotification? _singleton = TaxiNotification._internal();
  final CheckBookingApi checkBookingApi = CheckBookingApi();

  static TaxiNotification get shared {
    _singleton ??= TaxiNotification._internal();
    return _singleton!;
  }

  // *
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

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
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tlog("Init Local Notification");
  }

  Future<void> notifyBooking(
      {required String title, String? description, bool isSound = true}) async {
    await NotificationLocal.notificationBooking(
        channel: NotificationLocal.channel,
        plugin: NotificationLocal.notifications,
        title: title,
        useCustomSound: isSound,
        description: description);
  }
}
