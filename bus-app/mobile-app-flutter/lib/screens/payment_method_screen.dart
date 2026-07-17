import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_price_text.dart';
import 'mobile_money_entry_screen.dart';
import 'payment_processing_helper.dart';

class PaymentMethodScreen extends StatefulWidget {
  final BookingDraft draft;

  const PaymentMethodScreen({super.key, required this.draft});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  bool _isLoadingCard = false;

  Future<void> _selectCard() async {
    setState(() => _isLoadingCard = true);
    await PaymentProcessingHelper.initiateAndNavigate(
      context: context,
      draft: widget.draft,
      paymentMethodChosen: 'card',
    );
    if (mounted) setState(() => _isLoadingCard = false);
  }

  void _selectMobileMoney() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MobileMoneyEntryScreen(draft: widget.draft)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Payment Method')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.black2, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.routeName, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Pickup: ${draft.pickupStop}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                    Text('${draft.date.day}/${draft.date.month}/${draft.date.year} at ${draft.time}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                    Text('${draft.passengers} passenger(s) - ${draft.isLocal ? "Local" : "International"}', style: const TextStyle(color: AppColors.grey, fontSize: 13)),
                    const SizedBox(height: 10),
                    const Text('Estimated Total', style: TextStyle(color: AppColors.grey, fontSize: 11)),
                    const SizedBox(height: 4),
                    AppPriceText(currency: draft.currency, amount: draft.totalPrice, isLocal: draft.isLocal, fontSize: 26),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Select Payment Method', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: draft.isLocal ? _selectMobileMoney : null,
                child: Opacity(
                  opacity: draft.isLocal ? 1 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: AppColors.black2,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.phone_android, color: AppColors.yellow),
                        SizedBox(width: 12),
                        Text('Mobile Money', style: TextStyle(color: AppColors.white, fontSize: 14)),
                        Spacer(),
                        Icon(Icons.chevron_right, color: AppColors.grey),
                      ],
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: _isLoadingCard ? null : _selectCard,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.black2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.yellow),
                      const SizedBox(width: 12),
                      const Text('Credit/Debit Card', style: TextStyle(color: AppColors.white, fontSize: 14)),
                      const Spacer(),
                      if (_isLoadingCard)
                        const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.yellow))
                      else
                        const Icon(Icons.chevron_right, color: AppColors.grey),
                    ],
                  ),
                ),
              ),
              if (!draft.isLocal)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'International bookings are payable by credit card only.',
                    style: TextStyle(color: AppColors.grey, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}