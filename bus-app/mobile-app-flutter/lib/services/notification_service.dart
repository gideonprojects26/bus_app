import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_preferences.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Must be called once, early in main.dart, before any notification
  // is shown or scheduled.
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Android 13+ requires runtime permission to show notifications at all.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Required separately for scheduled (future-dated) notifications on
    // newer Android versions, since exact alarms are a sensitive permission.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  static const _generalDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'bus_app_channel',
      'Bus App Notifications',
      channelDescription: 'Booking, payment, and bus arrival notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  // Fired immediately after a successful payment.
  static Future<void> showPaymentConfirmed({required String routeName, required String amount}) async {
    if (!NotificationPreferences.paymentConfirmations) return;
    await _plugin.show(
      1,
      'Payment Confirmed',
      'Your payment of $amount for $routeName was successful.',
      _generalDetails,
    );
  }

  // Fired immediately after payment, alongside the confirmation above,
  // letting the rider know their receipt with QR code is ready.
  static Future<void> showReceiptReady({required String bookingId}) async {
    if (!NotificationPreferences.receiptReady) return;
    await _plugin.show(
      2,
      'Receipt Ready',
      'Your booking receipt (ID: $bookingId) is ready. Tap to view your QR code.',
      _generalDetails,
    );
  }

  // Scheduled ahead of time to fire shortly before the bus reaches the
  // rider's chosen pickup stop. `arrivalTime` is when the bus is expected;
  // this fires `minutesBefore` earlier than that.
  static Future<void> scheduleBusArrivalReminder({
    required DateTime arrivalTime,
    required String stopName,
    int minutesBefore = 10,
  }) async {
    if (!NotificationPreferences.busArrivalReminders) return;

    final scheduledTime = arrivalTime.subtract(Duration(minutes: minutesBefore));
    if (scheduledTime.isBefore(DateTime.now())) return; // don't schedule for the past

    await _plugin.zonedSchedule(
      3,
      'Your Bus is Arriving Soon',
      'Your bus will reach $stopName in about $minutesBefore minutes. Please head to your pickup point.',
      tz.TZDateTime.from(scheduledTime, tz.local),
      _generalDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}