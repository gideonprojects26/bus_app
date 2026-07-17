import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  static const List<Map<String, String>> _sections = [
    {
      'title': '1. Booking and Payment',
      'body':
          'All bookings must be paid in full at the time of reservation. Local passengers are charged in Ugandan Shillings (UGX) and may pay via MTN Mobile Money, Airtel Money, or Credit Card. International passengers are charged in US Dollars (USD) and may only pay by Credit Card.',
    },
    {
      'title': '2. Cancellations and Refunds',
      'body':
          'Bookings cancelled more than 24 hours before the scheduled departure are eligible for a full refund. Cancellations made within 24 hours of departure are non-refundable. No-shows are not eligible for any refund.',
    },
    {
      'title': '3. Pickup and Punctuality',
      'body':
          'Passengers must arrive at their selected pickup stop at least 10 minutes before the scheduled departure time. The bus will not wait beyond 5 minutes past departure time for delayed passengers.',
    },
    {
      'title': '4. Passenger Conduct',
      'body':
          'Passengers are expected to behave respectfully toward drivers, staff, and fellow passengers. The company reserves the right to deny boarding or remove any passenger who behaves in a disruptive, unsafe, or abusive manner, without refund.',
    },
    {
      'title': '5. Liability',
      'body':
          'While the company takes reasonable care to ensure passenger safety, it is not liable for personal injury, loss, or damage to belongings during the tour, except where caused by proven negligence on the part of the company or its staff.',
    },
    {
      'title': '6. Changes to Routes and Schedules',
      'body':
          'The company reserves the right to modify tour routes, stops, or schedules due to road conditions, weather, safety concerns, or operational requirements, with reasonable notice given to affected passengers where possible.',
    },
    {
      'title': '7. Privacy',
      'body':
          'Personal information collected during booking (name, email, phone number) is used solely for booking management, communication, and safety purposes, and is not shared with third parties for marketing purposes without consent.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Terms and Conditions'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Please read these terms carefully before using our booking service.',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 18),
            ..._sections.map((section) => Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(section['title']!,
                          style: const TextStyle(color: AppColors.yellow, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(section['body']!,
                          style: const TextStyle(color: AppColors.white, fontSize: 13, height: 1.5)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}