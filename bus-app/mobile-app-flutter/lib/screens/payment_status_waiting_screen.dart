import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../services/payment_service.dart';
import 'receipt_screen.dart';

class PaymentStatusWaitingScreen extends StatefulWidget {
  final String txRef;
  final BookingDraft draft;
  final String paymentMethodLabel;
  final String waitingMessage;

  const PaymentStatusWaitingScreen({
    super.key,
    required this.txRef,
    required this.draft,
    required this.paymentMethodLabel,
    this.waitingMessage = 'Confirming your payment...',
  });

  @override
  State<PaymentStatusWaitingScreen> createState() => _PaymentStatusWaitingScreenState();
}

class _PaymentStatusWaitingScreenState extends State<PaymentStatusWaitingScreen> {
  Timer? _pollTimer;
  int _secondsElapsed = 0;
  static const int _timeoutSeconds = 90;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    _secondsElapsed += 3;

    if (_secondsElapsed >= _timeoutSeconds) {
      _pollTimer?.cancel();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This is taking longer than expected. Check Activity later for status.')),
        );
        Navigator.pop(context);
      }
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await PaymentService.checkStatus(token: authProvider.token!, txRef: widget.txRef);

    if (!mounted) return;

    final status = result['data']?['status'];

    if (status == 'paid') {
      _pollTimer?.cancel();
      final backendBooking = result['data']['booking'];

      final booking = BookingModel(
        id: backendBooking['id'],
        draft: widget.draft,
        paymentMethod: widget.paymentMethodLabel,
        status: 'upcoming',
        createdAt: DateTime.now(),
      );

      Provider.of<BookingProvider>(context, listen: false).addBooking(booking);

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReceiptScreen(booking: booking)));
    } else if (status == 'failed') {
      _pollTimer?.cancel();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed or was cancelled.')),
      );
      Navigator.pop(context);
    }
    // if 'pending', just keep polling silently
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: AppColors.yellow, strokeWidth: 3),
                const SizedBox(height: 28),
                Text(
                  widget.waitingMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                const Text(
                  'This may take up to a minute.',
                  style: TextStyle(color: AppColors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}