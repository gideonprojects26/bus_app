import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/booking_model.dart';

class ReceiptPdfService {
  /// Generates a PDF receipt and triggers the share/save dialog.
  static Future<void> downloadReceipt(BookingModel booking) async {
    final pdf = await _generatePdf(booking);
    
    // Save PDF to temporary directory
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${booking.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    // Open share sheet — user can save, print, email, etc.
    await Share.shareXFiles(
      [XFile(file.path)],
      text: 'Bus Tours Receipt - ${booking.draft.routeName}',
    );
  }

  /// Builds the PDF document with booking details styled as a receipt.
  static Future<pw.Document> _generatePdf(BookingModel booking) async {
    final pdf = pw.Document();
    final draft = booking.draft;

    // Load custom font for better appearance (optional)
    // final font = await PdfGoogleFonts.nunitoRegular();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(40),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // --- Header ---
                pw.Center(
                  child: pw.Text(
                    'BUS TOURS UGANDA',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.amber,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'Booking Receipt',
                    style: const pw.TextStyle(
                      fontSize: 16,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // --- Booking Status ---
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.green,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'CONFIRMED',
                      style: const pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // --- Booking Details ---
                _buildPdfRow('Booking ID', booking.id),
                _buildPdfRow('Tour', draft.routeName),
                _buildPdfRow('Pickup Stop', draft.pickupStop),
                _buildPdfRow(
                  'Date',
                  '${draft.date.day}/${draft.date.month}/${draft.date.year}',
                ),
                _buildPdfRow('Time', draft.time),
                _buildPdfRow('Passengers', '${draft.passengers}'),
                _buildPdfRow(
                  'Passenger Type',
                  draft.isLocal ? 'Local' : 'International',
                ),
                _buildPdfRow('Payment Method', booking.paymentMethod),
                
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 16),

                // --- Total ---
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    const pw.Text(
                      'Total Paid',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${draft.currency} ${draft.totalPrice.toStringAsFixed(draft.isLocal ? 0 : 2)}',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.amber,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),

                // --- Footer ---
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing Bus Tours Uganda!',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'For inquiries: support@bustours.co.ug | +256 700 123 456',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  /// Helper to build a consistent row in the PDF.
  static pw.Widget _buildPdfRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey,
            ),
          ),
          pw.Text(
            value,
            style: const pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}