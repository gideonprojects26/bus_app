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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
            _checkUrlAndRedirect(url);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) {
            if (_isCallbackUrl(request.url)) {
              _goToWaitingScreen();
              return NavigationDecision.prevent; // Stop WebView from loading HTML
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  /// Checks if the URL is our backend callback redirect
  bool _isCallbackUrl(String url) {
    return url.contains('pesapal-callback') || url.contains('OrderTrackingId=');
  }

  void _checkUrlAndRedirect(String url) {
    if (_isCallbackUrl(url)) {
      _goToWaitingScreen();
    }
  }

  void _goToWaitingScreen() {
    if (!mounted) return; // Prevent context errors if widget unmounted

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
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}