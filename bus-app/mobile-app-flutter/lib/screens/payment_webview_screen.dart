import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/booking_model.dart';
import 'payment_status_waiting_screen.dart';

class PaymentWebViewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String txRef;
  final BookingDraft draft;
  final String paymentMethodLabel;

  const PaymentWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.txRef,
    required this.draft,
    required this.paymentMethodLabel,
  });

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _webViewController;

  // Must match PESAPAL_CALLBACK_URL on the backend.
  static const String redirectUrlPrefix = 'https://busapp.local/payment-callback';

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.startsWith(redirectUrlPrefix)) {
              _goToWaitingScreen();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _goToWaitingScreen() {
    // PesaPal has redirected back, but the IPN webhook confirming the
    // final status may take a few seconds to arrive — the waiting
    // screen's polling handles that gap gracefully.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentStatusWaitingScreen(
          txRef: widget.txRef,
          draft: widget.draft,
          paymentMethodLabel: widget.paymentMethodLabel,
          waitingMessage: 'Confirming your payment with PesaPal...',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Payment')),
      body: WebViewWidget(controller: _webViewController),
    );
  }
}