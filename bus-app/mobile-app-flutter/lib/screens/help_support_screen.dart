import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  static const List<Map<String, String>> _faqs = [
    {
      'question': 'How do I book a tour?',
      'answer':
          'Go to Home, tap Routes or Bookings, choose the Religious Tour or City Highlights Tour, select your pickup stop, date, time, and number of passengers, then complete payment.',
    },
    {
      'question': 'What is the difference between Local and International pricing?',
      'answer':
          'Local passengers are charged UGX 50,000 per person. International passengers are charged USD 30 per person and can only pay by credit card.',
    },
    {
      'question': 'Can I cancel a booking?',
      'answer':
          'Yes. Go to Activity, find your upcoming booking, and tap Cancel Booking. Refund eligibility depends on how close to departure the cancellation is made.',
    },
    {
      'question': 'What payment methods are accepted?',
      'answer':
          'MTN Mobile Money, Airtel Money, and Credit Card are accepted for local passengers. International passengers must use a Credit Card.',
    },
    {
      'question': 'How will I know when my bus is arriving?',
      'answer':
          'If Bus Arrival Reminders are enabled in Notifications, you will receive a push notification shortly before your bus reaches your selected pickup stop.',
    },
    {
      'question': 'Where can I find my receipt?',
      'answer':
          'Your receipt with QR code appears immediately after payment, and is also saved under Activity for later reference.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Help and Support'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._faqs.map((faq) => _FaqTile(question: faq['question']!, answer: faq['answer']!)),
            const SizedBox(height: 24),
            const Text(
              'Still need help?',
              style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const _ContactTile(icon: Icons.email_outlined, label: 'support@bustours.co.ug'),
            const _ContactTile(icon: Icons.phone_outlined, label: '+256 700 123 456'),
            const _ContactTile(icon: Icons.chat_bubble_outline, label: 'Live chat (available 8am - 8pm)'),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            title: Text(question, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            iconColor: AppColors.yellow,
            collapsedIconColor: AppColors.yellow,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(answer, style: const TextStyle(color: AppColors.grey, fontSize: 12, height: 1.4)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.yellow, size: 18),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: AppColors.white, fontSize: 13)),
        ],
      ),
    );
  }
}