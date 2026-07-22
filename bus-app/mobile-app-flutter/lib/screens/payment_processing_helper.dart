import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking_model.dart';
import '../providers/auth_provider.dart';
import '../services/payment_service.dart';
import 'payment_webview_screen.dart';
import 'payment_status_waiting_screen.dart';

class PaymentProcessingHelper {
  static Future<void> initiateAndNavigate({
    required BuildContext context,
    required BookingDraft draft,
    required String paymentMethodChosen,
    String? phoneNumber,
  }) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await PaymentService.initiatePayment(
      token: authProvider.token!,
      draft: draft,
      paymentMethodChosen: paymentMethodChosen,
      phoneNumber: phoneNumber,
      email: '${authProvider.user?.phone ?? "guest"}@bustours.app',
    );

    if (!context.mounted) return;

    if (result['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Could not start payment.')),
      );
      return;
    }

    final data = result['data'];
    final flow = data['flow'];

    if (flow == 'ussd_push') {
      // MTN Direct: no URL to open, just wait and poll for confirmation.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentStatusWaitingScreen(
            txRef: data['txRef'],
            draft: draft,
            paymentMethodLabel: 'MTN Mobile Money',
            waitingMessage: 'Check your phone and enter your Mobile Money PIN to complete payment.',
          ),
        ),
      );
    } else if (flow == 'webview') {
      // PesaPal: open their checkout page.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentWebViewScreen(
            checkoutUrl: data['checkoutUrl'],
            txRef: data['txRef'],
            draft: draft,
            paymentMethodLabel: paymentMethodChosen == 'card' ? 'Credit/Debit Card' : 'Mobile Money',
          ),
        ),
      );
    }
  }
}