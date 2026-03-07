import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print('Notification clicked: ${response.payload}');
        }
      },
    );

    _isInitialized = true;
  }

  Future<bool> requestExactAlarmsPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.scheduleExactAlarm.request();
      if (kDebugMode) {
        print('Exact Alarm Permission: $status');
      }
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestBatteryOptimizationExemption() async {
    if (Platform.isAndroid) {
      final status = await Permission.ignoreBatteryOptimizations.request();
      if (kDebugMode) {
        print('Ignore Battery Optimization Permission: $status');
      }
      return status.isGranted;
    }
    return true;
  }

  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (kDebugMode) {
        print('Notification Permission: $status');
      }
      return status.isGranted;
    } else if (Platform.isIOS) {
      final result = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return true;
  }

  Future<void> scheduleAdhan({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String payload,
    bool playSound = true,
  }) async {
    try {
      final tz.TZDateTime scheduledTzDate =
          tz.TZDateTime.from(scheduledDate, tz.local);

      if (scheduledTzDate.isBefore(tz.TZDateTime.now(tz.local))) {
        if (kDebugMode) {
          print('Cannot schedule alarm in the past: $scheduledDate');
        }
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'adhan_channel_id',
            'Adhan Notifications',
            channelDescription: 'Notifications for prayer times and Adhan',
            importance: Importance.max,
            priority: Priority.high,
            sound: playSound
                ? const RawResourceAndroidNotificationSound('adhan')
                : null,
            playSound: playSound,
            enableVibration: true,
            fullScreenIntent: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
        payload: payload,
      );

      if (kDebugMode) {
        print('Successfully scheduled $title at $scheduledTzDate with id $id');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error scheduling notification: $e');
      }
    }
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
