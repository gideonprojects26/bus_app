import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/booking_provider.dart';
import 'package:provider/provider.dart';
import 'receipt_screen.dart';
import '../widgets/app_back_button.dart';
import '../services/notification_service.dart';

class PaymentDetailsScreen extends StatefulWidget {
  final BookingDraft draft;
  final String paymentMethod;

  const PaymentDetailsScreen({
    super.key,
    required this.draft,
    required this.paymentMethod,
  });

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardNameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  bool _isProcessing = false;

  bool get _isMobileMoney => widget.paymentMethod != 'Credit Card';

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isProcessing = true);

    await Future.delayed(const Duration(seconds: 2));

    final booking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      draft: widget.draft,
      paymentMethod: widget.paymentMethod,
      status: 'upcoming',
      createdAt: DateTime.now(),
    );

    if (!mounted) return;

    Provider.of<BookingProvider>(context, listen: false).addBooking(booking);

    // Fire the two immediate notifications: payment confirmed and
    // receipt ready, as requested — both check the user's notification
    // preferences internally before actually showing anything.
    await NotificationService.showPaymentConfirmed(
      routeName: widget.draft.routeName,
      amount: '${widget.draft.currency} ${widget.draft.totalPrice.toStringAsFixed(widget.draft.isLocal ? 0 : 2)}',
    );
    await NotificationService.showReceiptReady(bookingId: booking.id);

    // Schedule the bus arrival reminder for the pickup time on the
    // booking's selected date, using the time string the user chose.
    final arrivalDateTime = _combineDateAndTime(widget.draft.date, widget.draft.time);
    if (arrivalDateTime != null) {
      await NotificationService.scheduleBusArrivalReminder(
        arrivalTime: arrivalDateTime,
        stopName: widget.draft.pickupStop,
      );
    }

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ReceiptScreen(booking: booking)),
    );
  }

  // Combines the booking's selected date (a DateTime with time zeroed out)
  // with its time string (e.g. "08:30 AM", formatted by TimeOfDay.format)
  // into one DateTime the notification scheduler can use.
  // This is a proper class method (sibling to _submitPayment), not nested
  // inside it — that mistake was the source of the earlier linter error.
  DateTime? _combineDateAndTime(DateTime date, String timeString) {
    try {
      final isPm = timeString.toUpperCase().contains('PM');
      final cleanTime = timeString.toUpperCase().replaceAll('AM', '').replaceAll('PM', '').trim();
      final parts = cleanTime.split(':');
      int hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(widget.paymentMethod),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount to pay: ${widget.draft.currency} ${widget.draft.totalPrice.toStringAsFixed(widget.draft.isLocal ? 0 : 2)}',
                  style: const TextStyle(color: AppColors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                if (_isMobileMoney) ...[
                  TextFormField(
                    controller: _phoneController,
                    style: const TextStyle(color: AppColors.white),
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: '${widget.paymentMethod} phone number',
                    ),
                    validator: (v) => (v == null || v.length < 9) ? 'Enter a valid phone number' : null,
                  ),
                ] else ...[
                  TextFormField(
                    controller: _cardNameController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: const InputDecoration(hintText: 'Cardholder Name'),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _cardNumberController,
                    style: const TextStyle(color: AppColors.white),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Card Number'),
                    validator: (v) => (v == null || v.length < 12) ? 'Enter a valid card number' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _expiryController,
                          style: const TextStyle(color: AppColors.white),
                          decoration: const InputDecoration(hintText: 'MM/YY'),
                          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          style: const TextStyle(color: AppColors.white),
                          obscureText: true,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(hintText: 'CVV'),
                          validator: (v) => (v == null || v.length < 3) ? 'Required' : null,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submitPayment,
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black),
                          )
                        : const Text('Confirm Payment'),
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