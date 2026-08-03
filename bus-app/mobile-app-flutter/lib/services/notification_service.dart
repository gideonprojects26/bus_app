import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'notification_preferences.dart';

/// Handles all local push notifications for the app.
/// Notifications are categorized by ID:
///   ID 1 — Payment confirmed
///   ID 2 — Receipt ready
///   ID 3 — Bus arrival reminder (scheduled)
///   ID 4 — Welcome new user (after signup)
///   ID 5 — Welcome back (after login)
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  // Must be called once, early in main.dart, before any notification
  // is shown or scheduled. Initializes timezones and Android permissions.
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Android 13+ requires runtime permission to show notifications at all
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // Required separately for scheduled (future-dated) notifications on
    // newer Android versions, since exact alarms are a sensitive permission
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // General notification details used by all notifications
  static const _generalDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'bus_app_channel',
      'Bus App Notifications',
      channelDescription: 'Booking, payment, and bus arrival notifications',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// ID 1 — Fired immediately after a successful payment.
  /// Checks user preferences before showing.
  static Future<void> showPaymentConfirmed({required String routeName, required String amount}) async {
    if (!NotificationPreferences.paymentConfirmations) return;
    await _plugin.show(
      1,
      'Payment Confirmed',
      'Your payment of $amount for $routeName was successful.',
      _generalDetails,
    );
  }

  /// ID 2 — Fired immediately after payment, alongside the confirmation above,
  /// letting the rider know their receipt with QR code is ready.
  /// Checks user preferences before showing.
  static Future<void> showReceiptReady({required String bookingId}) async {
    if (!NotificationPreferences.receiptReady) return;
    await _plugin.show(
      2,
      'Receipt Ready',
      'Your booking receipt (ID: $bookingId) is ready. Tap to view your QR code.',
      _generalDetails,
    );
  }

  /// ID 3 — Scheduled ahead of time to fire shortly before the bus reaches the
  /// rider's chosen pickup stop. `arrivalTime` is when the bus is expected;
  /// this fires `minutesBefore` earlier than that.
  /// Checks user preferences before scheduling.
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

  /// ID 4 — Fired immediately after signup to welcome new users.
  /// Always shows — not affected by notification preferences
  /// since it's a one-time onboarding message.
  static Future<void> showWelcome({required String name}) async {
    await _plugin.show(
      4,
      'Welcome to HopOn HopOff! 🎉',
      'Hi $name! Your account has been created. Start exploring Kampala with us.',
      _generalDetails,
    );
  }

  /// ID 5 — Fired immediately after login to welcome returning users.
  /// Always shows — not affected by notification preferences
  /// since it's a greeting, not a recurring alert.
  static Future<void> showWelcomeBack({required String name}) async {
    await _plugin.show(
      5,
      'Welcome Back! 👋',
      'Good to see you again, $name! Ready for your next adventure?',
      _generalDetails,
    );
  }
}