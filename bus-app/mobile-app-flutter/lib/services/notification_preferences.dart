// Holds the user's notification preferences in memory for this session.
// Read by NotificationService before firing any notification, and
// written to by NotificationSettingsScreen when the user toggles a switch.
class NotificationPreferences {
  static bool paymentConfirmations = true;
  static bool receiptReady = true;
  static bool busArrivalReminders = true;
  static bool promotions = false;
}