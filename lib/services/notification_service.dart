import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Add constants for notification IDs
  static const int dailyReminderId = 0;
  static const int urgentReminderId = 1;
  static const int testNotificationId = 999;

  FlutterLocalNotificationsPlugin get pluginInstance => _notifications;

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidInitialize = AndroidInitializationSettings('app_icon');
    const iOSInitialize = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tapped logic here
      },
    );
  }

  Future<void> scheduleDailyNotification() async {
    await _notifications.zonedSchedule(
      0,
      'Morning Hygiene Routine',
      'Time to start your morning hygiene routine!',
      _nextInstanceOf7AM(),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'hygiene_reminders',
          'Hygiene Reminders',
          channelDescription: 'Daily reminders for hygiene tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOf7AM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      7, // 7 AM
      0, // 0 minutes
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Method to schedule a test notification
  Future<void> scheduleTestNotification() async {
    print("DEBUG: Scheduling test notification for 5 seconds from now.");
    try {
      await _notifications.zonedSchedule(
        999, // Unique ID for the test notification
        'Test Notification',
        'If you see this, notifications are working! 🥳',
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel', // Different channel ID for testing
            'Test Notifications',
            channelDescription: 'Channel for testing notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No need for matchDateTimeComponents for a one-off test
      );
      print("DEBUG: Test notification scheduled successfully.");
    } catch (e) {
      print("ERROR scheduling test notification: $e");
    }
  }

  Future<void> scheduleUrgentReminder() async {
    const int urgentHour = 7;
    const int urgentMinute = 30;

    // Cancel any existing reminders first
    await _notifications.cancel(urgentReminderId);
    print("DEBUG: Attempting to schedule urgent reminders...");

    try {
      await _notifications.zonedSchedule(
        urgentReminderId,
        'Last Call!',
        'Running late! Finish your tasks before school!',
        // Pass hour and minute directly
        _scheduleWeeklyOnDays(urgentHour, urgentMinute, [
          DateTime.monday,
          DateTime.tuesday,
          DateTime.wednesday,
          DateTime.thursday,
          DateTime.friday,
        ]),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'urgent_reminders',
            'Urgent Reminders',
            channelDescription: 'Last minute reminders before school',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
      print(
          "DEBUG: Scheduled urgent reminder for weekdays at $urgentHour:$urgentMinute");
    } catch (e) {
      print("ERROR scheduling urgent reminder: $e");
    }
  }

  // Helper function updated to take hour/minute
  tz.TZDateTime _scheduleWeeklyOnDays(int hour, int minute, List<int> days) {
    tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);
    while (!days.contains(scheduledDate.weekday)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
      while (!days.contains(scheduledDate.weekday)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }
    }
    return scheduledDate;
  }

  // Modified helper updated to take hour/minute
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month,
        now.day, hour, minute, 0); // Use 0 for seconds
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  // Method to cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    print("DEBUG: Cancelled notification with ID: $id");
  }
}
