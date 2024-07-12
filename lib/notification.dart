import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'dart:io' show Platform;

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static init() async {
    tz.initializeTimeZones();
    var krLocation = tz.getLocation('Asia/Seoul');
    tz.setLocalLocation(krLocation);

    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
        'channel id', 'channel name',
        channelDescription: 'channel description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false);

    const NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1,subtitle: "subtitle test"));

    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Routine+',
        '이것은 예약된 알림입니다.',
        tz.TZDateTime(tz.local, 2024, 7, 10, 15, 07),
        notificationDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
  }

  static Future<void> scheduleDailyNotifications() async {
    final startDate = tz.TZDateTime(tz.local, 2024, 7, 10);
    final endDate = tz.TZDateTime(tz.local, 2024, 7, 11);
    final time = const Duration(days: 1);

    for (var date = startDate; date.isBefore(endDate) || date.isAtSameMomentAs(endDate); date = date.add(time)) {
      final scheduledDate = tz.TZDateTime(tz.local, date.year, date.month, date.day, 10, 17);

      const AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
          'channel id', 'channel name',
          channelDescription: 'channel description',
          importance: Importance.max,
          priority: Priority.max,
          showWhen: false);

      const NotificationDetails notificationDetails = NotificationDetails(
          android: androidNotificationDetails,
          iOS: DarwinNotificationDetails(badgeNumber: 1));

      await flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          'Routine+',
          '이것은 예약된 알림입니다.',
          scheduledDate,
          notificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time); // This ensures the notification is scheduled daily at the specified time
    }
  }

  static Future<void> requestNotificationPermission() async {
    bool permissionGranted = false; // Initialize as false
    if (Platform.isIOS) {
      final bool? result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      permissionGranted = result ?? false; // Handle null (when result is null, default to false)
    } else {
      permissionGranted = true; // Assume permission is granted on non-iOS platforms
    }
    // Use permissionGranted as needed
  }


}