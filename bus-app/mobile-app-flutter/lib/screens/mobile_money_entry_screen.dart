import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../models/booking_model.dart';
import 'payment_processing_helper.dart';

/// Screen for entering Mobile Money phone number to complete payment.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// text colors instead of hardcoded AppColors.white.
class MobileMoneyEntryScreen extends StatefulWidget {
  final BookingDraft draft;

  const MobileMoneyEntryScreen({super.key, required this.draft});

  @override
  State<MobileMoneyEntryScreen> createState() => _MobileMoneyEntryScreenState();
}

class _MobileMoneyEntryScreenState extends State<MobileMoneyEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await PaymentProcessingHelper.initiateAndNavigate(
      context: context,
      draft: widget.draft,
      paymentMethodChosen: 'mobile_money',
      phoneNumber: _phoneController.text.trim(),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(leading: const AppBackButton(), title: const Text('Mobile Money')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter the phone number registered for Mobile Money. We\u2019ll detect your network automatically.',
                  style: TextStyle(color: AppColors.grey, fontSize: 13), // grey stays as static accent
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  style: TextStyle(color: theme.textPrimary), // was AppColors.white — now theme-aware
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(hintText: '07XXXXXXXX'),
                  validator: (v) => (v == null || v.length < 9) ? 'Enter a valid phone number' : null,
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                        : const Text('Pay Now'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}