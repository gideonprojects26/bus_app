import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_back_button.dart';
import '../models/booking_model.dart';
import 'payment_processing_helper.dart';

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
    return Scaffold(
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
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _phoneController,
                  style: const TextStyle(color: AppColors.white),
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