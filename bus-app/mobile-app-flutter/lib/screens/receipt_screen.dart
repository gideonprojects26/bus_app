import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../services/receipt_pdf_service.dart';
import 'main_navigation.dart';
import '../widgets/app_card_shadow.dart';
import '../widgets/app_price_text.dart';

/// Receipt screen displaying booking confirmation details, a QR code
/// for the booking, and options to download the receipt or return home.
///
/// THEME: Converted to be theme-aware (light/dark). Uses ThemeProvider for
/// surface colors and text colors instead of hardcoded Color(0xFF1A1A1A)/AppColors.white.
class ReceiptScreen extends StatelessWidget {
  final BookingModel booking;

  const ReceiptScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final draft = booking.draft;
    // Access theme provider for light/dark mode aware colors
    final theme = context.watch<ThemeProvider>();

    // Build QR code payload with booking details for verification
    final qrData =
        'BookingID:${booking.id}|Route:${draft.routeName}|Stop:${draft.pickupStop}|Date:${draft.date}|Passengers:${draft.passengers}';

    return Scaffold(
      backgroundColor: theme.background, // now theme-aware
      appBar: AppBar(
        title: const Text('Booking Receipt'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // --- Receipt Card ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  boxShadow: AppCardShadow.soft,
                  color: theme.surface, // was Color(0xFF1A1A1A) — now theme-aware
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.yellow, size: 48), // yellow stays as brand accent
                    const SizedBox(height: 10),
                    Text(
                      'Booking Confirmed',
                      style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold), // was AppColors.white — now theme-aware
                    ),
                    const SizedBox(height: 20),
                    // QR Code — white background container needed for scanner readability
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.white, // QR needs white background for scanners to read reliably
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 180,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ReceiptRow(label: 'Booking ID', value: booking.id, theme: theme),
                    _ReceiptRow(label: 'Tour', value: draft.routeName, theme: theme),
                    _ReceiptRow(label: 'Pickup Stop', value: draft.pickupStop, theme: theme),
                    _ReceiptRow(label: 'Date', value: '${draft.date.day}/${draft.date.month}/${draft.date.year}', theme: theme),
                    _ReceiptRow(label: 'Time', value: draft.time, theme: theme),
                    _ReceiptRow(label: 'Passengers', value: '${draft.passengers}', theme: theme),
                    _ReceiptRow(label: 'Type', value: draft.isLocal ? 'Local' : 'International', theme: theme),
                    _ReceiptRow(label: 'Payment Method', value: booking.paymentMethod, theme: theme),
                    const SizedBox(height: 10),
                    const Text('Total Paid', style: TextStyle(color: AppColors.grey, fontSize: 12)), // grey stays as static accent
                    const SizedBox(height: 4),
                    AppPriceText(currency: draft.currency, amount: draft.totalPrice, isLocal: draft.isLocal, fontSize: 28),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Download Digital Receipt Button ---
              // Generates a professional PDF receipt using ReceiptPdfService
              // and opens the native share sheet for saving/printing/sharing.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      // Show a brief loading indicator
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating receipt...'),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppColors.yellow,
                        ),
                      );

                      // Generate PDF and trigger share sheet
                      await ReceiptPdfService.downloadReceipt(booking);
                    } catch (e) {
                      // Handle any errors during PDF generation
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Could not generate receipt. Please try again.'),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: theme.textPrimary, // matches text color for outlined button consistency
                    size: 24,
                  ),
                  label: Text(
                    'Download Digital Receipt',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.yellow, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // --- Done Button ---
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

/// Row widget for displaying receipt detail labels and values.
/// Now theme-aware — accepts ThemeProvider for text colors.
class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeProvider theme; // added for light/dark mode support

  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.grey, fontSize: 13), // grey stays as static accent
          ),
          Text(
            value,
            style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), // was AppColors.white — now theme-aware
          ),
        ],
      ),
    );
  }
}