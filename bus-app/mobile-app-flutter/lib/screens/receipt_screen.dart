import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import 'main_navigation.dart';
import '../widgets/app_card_shadow.dart';
import '../widgets/app_price_text.dart';

class ReceiptScreen extends StatelessWidget {
  final BookingModel booking;

  const ReceiptScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final draft = booking.draft;
    final qrData =
        'BookingID:${booking.id}|Route:${draft.routeName}|Stop:${draft.pickupStop}|Date:${draft.date}|Passengers:${draft.passengers}';

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Receipt'), automaticallyImplyLeading: false),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  boxShadow: AppCardShadow.soft,
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.yellow, size: 48),
                    const SizedBox(height: 10),
                    const Text(
                      'Booking Confirmed',
                      style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.white,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 180,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ReceiptRow(label: 'Booking ID', value: booking.id),
                    _ReceiptRow(label: 'Tour', value: draft.routeName),
                    _ReceiptRow(label: 'Pickup Stop', value: draft.pickupStop),
                    _ReceiptRow(label: 'Date', value: '${draft.date.day}/${draft.date.month}/${draft.date.year}'),
                    _ReceiptRow(label: 'Time', value: draft.time),
                    _ReceiptRow(label: 'Passengers', value: '${draft.passengers}'),
                    _ReceiptRow(label: 'Type', value: draft.isLocal ? 'Local' : 'International'),
                    _ReceiptRow(label: 'Payment Method', value: booking.paymentMethod),
                    const SizedBox(height: 10),
                    const Text('Total Paid', style: TextStyle(color: AppColors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    AppPriceText(currency: draft.currency, amount: draft.totalPrice, isLocal: draft.isLocal, fontSize: 28),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
