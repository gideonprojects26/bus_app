import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../services/notification_preferences.dart';

/// Screen for managing push notification preferences (payment confirmations,
/// receipt availability, bus arrival reminders, and promotional offers).
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded Color(0xFF1A1A1A)/AppColors.white.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _paymentConfirmations = true;
  bool _receiptReady = true;
  bool _busArrivalReminders = true;
  bool _promotions = false;

  @override
  void initState() {
    super.initState();
    // Load saved notification preferences from shared preferences / local storage
    _paymentConfirmations = NotificationPreferences.paymentConfirmations;
    _receiptReady = NotificationPreferences.receiptReady;
    _busArrivalReminders = NotificationPreferences.busArrivalReminders;
    _promotions = NotificationPreferences.promotions;
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Notifications'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Choose which notifications you want to receive',
              style: TextStyle(color: AppColors.grey, fontSize: 13), // grey stays as static accent
            ),
            const SizedBox(height: 20),
            _buildToggle(
              title: 'Payment Confirmations',
              subtitle: 'Get notified when a payment is successfully processed',
              value: _paymentConfirmations,
              onChanged: (v) {
                setState(() => _paymentConfirmations = v);
                NotificationPreferences.paymentConfirmations = v;
              },
              theme: theme, // pass theme to toggle builder
            ),
            _buildToggle(
              title: 'Receipt Ready',
              subtitle: 'Get notified when your booking receipt is available',
              value: _receiptReady,
              onChanged: (v) {
                setState(() => _receiptReady = v);
                NotificationPreferences.receiptReady = v;
              },
              theme: theme, // pass theme to toggle builder
            ),
            _buildToggle(
              title: 'Bus Arrival Reminders',
              subtitle: 'Get notified shortly before your bus reaches your pickup stop',
              value: _busArrivalReminders,
              onChanged: (v) {
                setState(() => _busArrivalReminders = v);
                NotificationPreferences.busArrivalReminders = v;
              },
              theme: theme, // pass theme to toggle builder
            ),
            _buildToggle(
              title: 'Promotions and Offers',
              subtitle: 'Occasional updates about discounts and new tours',
              value: _promotions,
              onChanged: (v) {
                setState(() => _promotions = v);
                NotificationPreferences.promotions = v;
              },
              theme: theme, // pass theme to toggle builder
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a single notification toggle row with title, subtitle, and switch.
  /// Now theme-aware — accepts ThemeProvider for surface and text colors.
  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required ThemeProvider theme, // added for light/dark mode support
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), // was AppColors.white — now theme-aware
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppColors.grey, fontSize: 11), // grey stays as static accent
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.yellow,
          ),
        ],
      ),
    );
  }
}