import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import '../models/booking_model.dart';
import '../services/receipt_pdf_service.dart';
import 'main_navigation.dart';
import '../widgets/app_card_shadow.dart';

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
      backgroundColor: theme.background,
      appBar: AppBar(
        title: const Text('BOOKING RECEIPT'),
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
                  color: theme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.yellow, size: 48),
                    const SizedBox(height: 10),
                    // Only "Booking Confirmed" keeps normal casing
                    Text(
                      'Booking Confirmed',
                      style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // QR Code — white background container needed for scanner readability
                    Container(
                      padding: const EdgeInsets.all(12),
                      color: AppColors.white,
                      child: QrImageView(
                        data: qrData,
                        version: QrVersions.auto,
                        size: 180,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // All labels and values in UPPERCASE for a clean receipt look
                    _ReceiptRow(label: 'BOOKING ID', value: booking.id.toUpperCase(), theme: theme),
                    _ReceiptRow(label: 'TOUR', value: draft.routeName.toUpperCase(), theme: theme),
                    _ReceiptRow(label: 'PICKUP STOP', value: draft.pickupStop.toUpperCase(), theme: theme),
                    _ReceiptRow(label: 'DATE', value: '${draft.date.day}/${draft.date.month}/${draft.date.year}', theme: theme),
                    _ReceiptRow(label: 'TIME', value: draft.time.toUpperCase(), theme: theme),
                    _ReceiptRow(label: 'PASSENGERS', value: '${draft.passengers}', theme: theme),
                    _ReceiptRow(label: 'TYPE', value: draft.isLocal ? 'LOCAL' : 'INTERNATIONAL', theme: theme),
                    _ReceiptRow(label: 'PAYMENT METHOD', value: booking.paymentMethod.toUpperCase(), theme: theme),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- Download Digital Receipt Button ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Generating receipt...'),
                          duration: Duration(seconds: 1),
                          backgroundColor: AppColors.yellow,
                        ),
                      );
                      await ReceiptPdfService.downloadReceipt(booking);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not generate receipt. Please try again.'),
                            backgroundColor: AppColors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.download_rounded,
                    color: theme.textPrimary,
                    size: 24,
                  ),
                  label: Text(
                    'DOWNLOAD DIGITAL RECEIPT',
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
                  child: const Text('DONE'),
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
/// All values are displayed in uppercase for a clean receipt style.
class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeProvider theme;

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
            style: const TextStyle(color: AppColors.grey, fontSize: 13),
          ),
          Text(
            value,
            style: TextStyle(color: theme.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}