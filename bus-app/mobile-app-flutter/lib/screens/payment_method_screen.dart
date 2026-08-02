import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../widgets/app_back_button.dart';
import '../widgets/app_price_text.dart';
import 'mobile_money_entry_screen.dart';
import 'payment_processing_helper.dart';

/// Screen allowing users to select a payment method (Mobile Money or Credit Card)
/// and review their booking summary before proceeding with payment.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded AppColors.black2/white.
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
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Payment Method')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Booking Summary Card ---
              Container(
                padding: const EdgeInsets.all(16),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: theme.surface, // was AppColors.black2 — now theme-aware
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.routeName,
                      style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16), // was AppColors.white — now theme-aware
                    ),
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
              Text(
                'Select Payment Method',
                style: TextStyle(color: theme.textPrimary, fontSize: 16, fontWeight: FontWeight.w600), // was AppColors.white — now theme-aware
              ),
              const SizedBox(height: 14),

              // --- Mobile Money Option ---
              GestureDetector(
                onTap: draft.isLocal ? _selectMobileMoney : null,
                child: Opacity(
                  opacity: draft.isLocal ? 1 : 0.4,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: theme.surface, // was AppColors.black2 — now theme-aware
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.phone_android, color: AppColors.yellow),
                        const SizedBox(width: 12),
                        Text(
                          'Mobile Money',
                          style: TextStyle(color: theme.textPrimary, fontSize: 14), // was AppColors.white — now theme-aware
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.grey),
                      ],
                    ),
                  ),
                ),
              ),

              // --- Credit/Debit Card Option ---
              GestureDetector(
                onTap: _isLoadingCard ? null : _selectCard,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.surface, // was AppColors.black2 — now theme-aware
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.credit_card, color: AppColors.yellow),
                      const SizedBox(width: 12),
                      Text(
                        'Credit/Debit Card',
                        style: TextStyle(color: theme.textPrimary, fontSize: 14), // was AppColors.white — now theme-aware
                      ),
                      const Spacer(),
                      if (_isLoadingCard)
                        const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.yellow))
                      else
                        const Icon(Icons.chevron_right, color: AppColors.grey),
                    ],
                  ),
                ),
              ),

              // --- International Booking Notice ---
              if (!draft.isLocal)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'International bookings are payable by credit card only.',
                    style: TextStyle(color: AppColors.grey, fontSize: 12), // grey stays as static accent
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}