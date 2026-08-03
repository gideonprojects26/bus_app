// ignore_for_file: duplicate_ignore, prefer_const_constructors

import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: unused_import
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr/qr.dart';
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

  /// Generates QR code image bytes by painting the QR matrix onto a BMP.
  static Uint8List _generateQrCodeBytes(String data) {
    final qrCode = QrCode.fromData(
      data: data,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );

    final moduleCount = qrCode.moduleCount;
    const scale = 4;
    final size = moduleCount * scale;
    final rowBytes = (size * 3 + 3) ~/ 4 * 4;
    final pixelDataSize = rowBytes * size;

    final bmpData = Uint8List(54 + pixelDataSize);
    final bmpView = ByteData.view(bmpData.buffer);

    // BMP Header
    bmpData[0] = 0x42;
    bmpData[1] = 0x4D;
    bmpView.setUint32(2, bmpData.length, Endian.little);
    bmpView.setUint32(10, 54, Endian.little);
    bmpView.setUint32(14, 40, Endian.little);
    bmpView.setInt32(18, size, Endian.little);
    bmpView.setInt32(22, -size, Endian.little);
    bmpView.setUint16(26, 1, Endian.little);
    bmpView.setUint16(28, 24, Endian.little);
    bmpView.setUint32(30, 0, Endian.little);
    bmpView.setUint32(34, pixelDataSize, Endian.little);
    bmpView.setInt32(38, 2835, Endian.little);
    bmpView.setInt32(42, 2835, Endian.little);

    for (int row = 0; row < moduleCount; row++) {
      for (int col = 0; col < moduleCount; col++) {
        final dark = (qrCode as dynamic).isDark(row, col) as bool;
        
        for (int y = 0; y < scale; y++) {
          for (int x = 0; x < scale; x++) {
            final px = col * scale + x;
            final py = row * scale + y;
            final offset = 54 + py * rowBytes + px * 3;
            
            if (dark) {
              bmpData[offset] = 0;
              bmpData[offset + 1] = 0;
              bmpData[offset + 2] = 0;
            } else {
              bmpData[offset] = 255;
              bmpData[offset + 1] = 255;
              bmpData[offset + 2] = 255;
            }
          }
        }
      }
    }

    return bmpData;
  }

  /// Builds the PDF document with booking details and an embedded QR code.
  /// All text is uppercase except "Booking Receipt" subtitle.
  /// Total price section removed.
  static Future<pw.Document> _generatePdf(BookingModel booking) async {
    final pdf = pw.Document();
    final draft = booking.draft;

    final qrData =
        'BookingID:${booking.id}|Route:${draft.routeName}|Stop:${draft.pickupStop}|Date:${draft.date}|Passengers:${draft.passengers}';

    final qrImageBytes = _generateQrCodeBytes(qrData);

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
                // Only "Booking Receipt" keeps normal casing
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

                // --- QR Code ---
                pw.Center(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      border: pw.Border.all(color: PdfColors.grey, width: 1),
                    ),
                    child: pw.Image(
                      pw.MemoryImage(qrImageBytes),
                      width: 130,
                      height: 130,
                    ),
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'SCAN TO VERIFY BOOKING',
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey,
                    ),
                  ),
                ),
                pw.SizedBox(height: 18),

                // --- Booking Details (all uppercase) ---
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
                
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 16),

                // --- Footer ---
                pw.Center(
                  child: pw.Text(
                    'ENJOY YOUR HOP OFF HOP ON TOUR!',
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