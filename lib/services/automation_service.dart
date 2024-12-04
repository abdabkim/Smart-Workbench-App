import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../models/automation_schedule.dart';

class AutomationService {
  static const String _iftttOnUrl = 'https://maker.ifttt.com/trigger/turn_on_devices/with/key/2ZySHZZprglWIony9x0DF';
  static const String _iftttOffUrl = 'https://maker.ifttt.com/trigger/turn_off_device/with/key/2ZySHZZprglWIony9x0DF';
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _notifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );
  }

  static Future<void> _handleNotificationResponse(NotificationResponse response) async {
    if (response.payload != null) {
      try {
        final data = json.decode(response.payload!);
        await executeAutomation(data['deviceId'], data['action']);
      } catch (e) {
        print('Error executing automation: $e');
      }
    }
  }

  static Future<void> executeAutomation(String deviceId, bool turnOn) async {
    try {
      final url = turnOn ? _iftttOnUrl : _iftttOffUrl;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'deviceId': deviceId,
          'status': turnOn ? 'on' : 'off'
        }),
      );

      if (response.statusCode == 200) {
        print('Successfully executed automation: ${turnOn ? 'ON' : 'OFF'} for $deviceId');
        await _showNotification(
            'Device Automation',
            'Successfully turned ${turnOn ? 'ON' : 'OFF'} $deviceId'
        );
      } else {
        throw Exception('Failed to execute automation: ${response.statusCode}');
      }
    } catch (e) {
      print('Automation execution error: $e');
      await _showNotification(
          'Automation Error',
          'Failed to execute automation for $deviceId'
      );
      rethrow;
    }
  }

  static Future<void> scheduleAutomation(AutomationSchedule schedule) async {
    try {
      final deviceName = schedule.device.split(' (')[0];
      final uniqueId = '${schedule.name}_${deviceName}'.hashCode;

      await _notifications.cancelAll();

      for (var day in schedule.days) {
        var scheduledDate = _getNextScheduledDate(day, schedule.timeOfDay);

        Timer.periodic(Duration(minutes: 1), (timer) {
          final now = DateTime.now();
          if (now.weekday == day.index + 1 &&
              now.hour == schedule.timeOfDay.hour &&
              now.minute == schedule.timeOfDay.minute) {
            executeAutomation(deviceName, schedule.action);
          }
        });

        await _notifications.zonedSchedule(
          uniqueId + day.index,
          'Device Automation',
          '${schedule.name}: ${schedule.action ? 'Turning ON' : 'Turning OFF'} $deviceName',
          tz.TZDateTime.from(scheduledDate, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'device_automation',
              'Device Automation',
              channelDescription: 'Notifications for device automation',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: json.encode({
            'deviceId': deviceName,
            'action': schedule.action,
          }),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );
      }
    } catch (e) {
      print('Error in scheduleAutomation: $e');
    }
  }

  static bool _isScheduledTime(DateTime now, TimeOfDay scheduledTime) {
    return now.hour == scheduledTime.hour && now.minute == scheduledTime.minute;
  }

  static DateTime _getNextScheduledDate(DayOfWeek day, TimeOfDay time) {
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    while (scheduledDate.weekday != day.index + 1 || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  static Future<void> _showNotification(String title, String body) async {
    await _notifications.show(
      DateTime.now().millisecond,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'automation_channel',
          'Automation',
          channelDescription: 'Notifications for device automation',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }
}