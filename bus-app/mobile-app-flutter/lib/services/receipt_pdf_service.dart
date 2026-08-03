// ignore_for_file: duplicate_ignore, prefer_const_constructors

import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: unused_import
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../models/booking_model.dart';

class ReceiptPdfService {
  /// Generates a PDF receipt and triggers the share/save dialog.
  static Future<void> downloadReceipt(BookingModel booking) async {
    final pdf = await _generatePdf(booking);
    
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/receipt_${booking.id}.pdf');
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Bus Tours Receipt - ${booking.draft.routeName}',
      ),
    );
  }

  /// Builds the PDF document with booking details.
  /// All text is uppercase except "Booking Receipt" subtitle.
  /// QR code is available on the in-app screen receipt.
  static Future<pw.Document> _generatePdf(BookingModel booking) async {
    final pdf = pw.Document();
    final draft = booking.draft;

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
                    style: pw.TextStyle(
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
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),

                // --- Booking Details ---
                _buildPdfRow('BOOKING ID', booking.id.toUpperCase()),
                _buildPdfRow('TOUR', draft.routeName.toUpperCase()),
                _buildPdfRow('PICKUP STOP', draft.pickupStop.toUpperCase()),
                _buildPdfRow(
                  'DATE',
                  '${draft.date.day}/${draft.date.month}/${draft.date.year}',
                ),
                _buildPdfRow('TIME', draft.time.toUpperCase()),
                _buildPdfRow('PASSENGERS', '${draft.passengers}'),
                _buildPdfRow(
                  'TYPE',
                  draft.isLocal ? 'LOCAL' : 'INTERNATIONAL',
                ),
                _buildPdfRow('PAYMENT METHOD', booking.paymentMethod.toUpperCase()),
                
                pw.SizedBox(height: 30),

                // --- Footer ---
                pw.Center(
                  child: pw.Text(
                    'THANK YOU FOR CHOOSING BUS TOURS UGANDA!',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
                pw.Center(
                  child: pw.Text(
                    'FOR INQUIRIES: SUPPORT@BUSTOURS.CO.UG | +256 700 123 456',
                    style: pw.TextStyle(
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
            style: pw.TextStyle(
              fontSize: 12,
              color: PdfColors.grey,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}