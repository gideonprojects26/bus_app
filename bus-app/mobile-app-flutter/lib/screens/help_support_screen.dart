import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';

/// Screen displaying FAQs and contact information for customer support.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded Color(0xFF1A1A1A)/AppColors.white.
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
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Help and Support'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600), // was AppColors.white — now theme-aware
            ),
            const SizedBox(height: 12),
            // Pass theme down to each FAQ tile so they stay light/dark aware
            ..._faqs.map((faq) => _FaqTile(question: faq['question']!, answer: faq['answer']!, theme: theme)),
            const SizedBox(height: 24),
            Text(
              'Still need help?',
              style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600), // was AppColors.white — now theme-aware
            ),
            const SizedBox(height: 12),
            // Pass theme down to each contact tile
            const _ContactTile(icon: Icons.email_outlined, label: 'support@bustours.co.ug'),
            const _ContactTile(icon: Icons.phone_outlined, label: '+256 700 123 456'),
            const _ContactTile(icon: Icons.chat_bubble_outline, label: 'Live chat (available 8am - 8pm)'),
          ],
        ),
      ),
    );
  }
}

/// Expandable tile widget for displaying FAQ questions and answers.
/// Now theme-aware — accepts ThemeProvider for surface and text colors.
class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;
  final ThemeProvider theme; // added for light/dark mode support

  const _FaqTile({required this.question, required this.answer, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: Material(
          color: Colors.transparent,
          child: ExpansionTile(
            title: Text(
              question,
              style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), // was AppColors.white — now theme-aware
            ),
            iconColor: AppColors.yellow,
            collapsedIconColor: AppColors.yellow,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  answer,
                  style: const TextStyle(color: AppColors.grey, fontSize: 12, height: 1.4), // grey stays as static accent
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tile widget for displaying contact information (email, phone, chat).
/// Now theme-aware — accepts ThemeProvider for surface and text colors.
class _ContactTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    // Access theme provider since _ContactTile can't receive it as a parameter (used with const in the parent)
    final theme = context.watch<ThemeProvider>();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.yellow, size: 18),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(color: theme.textPrimary, fontSize: 13), // was AppColors.white — now theme-aware
          ),
        ],
      ),
    );
  }
}