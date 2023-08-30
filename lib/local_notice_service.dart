import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

class LocalNoticeService {

  FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  void addNotificationCall(String title,String body) async {
    // #1
    _localNotificationsPlugin ??= FlutterLocalNotificationsPlugin();
    tzData.initializeTimeZones();
    final scheduleTime = tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, DateTime.now().millisecondsSinceEpoch+1500);

// #2
    const androidDetail = AndroidNotificationDetails(
        "channel", // channel Id
        "channel",  // channel Name
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true, // Cho phép rung điện thoại
        actions: [
          AndroidNotificationAction('id_1', 'Trả lời'),
          AndroidNotificationAction('id_2', 'Từ chối'),
        ]
    );

    const iosDetail = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true
    );

    const noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

// #3
    const id = 0;

// #4
    await _localNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      noticeDetail,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
    );
  }
}