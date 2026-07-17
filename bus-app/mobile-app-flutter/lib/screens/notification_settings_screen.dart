import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../services/notification_preferences.dart';

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
    _paymentConfirmations = NotificationPreferences.paymentConfirmations;
    _receiptReady = NotificationPreferences.receiptReady;
    _busArrivalReminders = NotificationPreferences.busArrivalReminders;
    _promotions = NotificationPreferences.promotions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              style: TextStyle(color: AppColors.grey, fontSize: 13),
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
            ),
            _buildToggle(
              title: 'Receipt Ready',
              subtitle: 'Get notified when your booking receipt is available',
              value: _receiptReady,
              onChanged: (v) {
                setState(() => _receiptReady = v);
                NotificationPreferences.receiptReady = v;
              },
            ),
            _buildToggle(
              title: 'Bus Arrival Reminders',
              subtitle: 'Get notified shortly before your bus reaches your pickup stop',
              value: _busArrivalReminders,
              onChanged: (v) {
                setState(() => _busArrivalReminders = v);
                NotificationPreferences.busArrivalReminders = v;
              },
            ),
            _buildToggle(
              title: 'Promotions and Offers',
              subtitle: 'Occasional updates about discounts and new tours',
              value: _promotions,
              onChanged: (v) {
                setState(() => _promotions = v);
                NotificationPreferences.promotions = v;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: AppColors.grey, fontSize: 11)),
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