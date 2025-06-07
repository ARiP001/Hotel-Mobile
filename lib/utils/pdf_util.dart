import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../utils/currency_util.dart';
import 'timezone_util.dart';

Future<void> generateAndDownloadPDF(Transaction t, String region) async {
  final pdf = pw.Document();
  final convertedPrice = CurrencyUtil.convert(t.price, region);
  final convertedTotal = CurrencyUtil.convert(t.total, region);
  final formattedPrice = CurrencyUtil.format(convertedPrice, region);
  final formattedTotal = CurrencyUtil.format(convertedTotal, region);
  final bookingTimeStr = DateFormat('dd MMM yyyy, HH:mm').format(t.bookingTime);
  final checkinTimeStr = DateFormat('dd MMM yyyy').format(t.checkin) + ' 14:00';
  final checkoutTimeStr = DateFormat('dd MMM yyyy').format(t.checkout) + ' 12:00';
  final checkinDateTime = DateTime(t.checkin.year, t.checkin.month, t.checkin.day, 14, 0);
  final checkoutDateTime = DateTime(t.checkout.year, t.checkout.month, t.checkout.day, 12, 0);
  final checkinTzStr = TimezoneUtil.formatAllTimezones(checkinDateTime);
  final checkoutTzStr = TimezoneUtil.formatAllTimezones(checkoutDateTime);
  pdf.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Bukti Pemesanan', style: pw.TextStyle(fontSize: 32, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 24),
          pw.Table(
            columnWidths: {
              0: pw.FixedColumnWidth(130),
              1: pw.FixedColumnWidth(12),
              2: const pw.FlexColumnWidth(),
            },
            children: [
              _pdfRow3('Hotel                ', t.hotelName),
              _pdfRow3('Username            ', t.username),
              _pdfRow3('Waktu Pemesanan     ', bookingTimeStr),
              _pdfRow3('Check-in            ', checkinTimeStr),
              _pdfRow3('', checkinTzStr),
              _pdfRow3('Check-out           ', checkoutTimeStr),
              _pdfRow3('', checkoutTzStr),
              _pdfRow3('Jumlah Hari         ', t.day.toString()),
              _pdfRow3('Harga per Hari      ', formattedPrice),
              _pdfRow3('Total                ', formattedTotal, isBold: true),
            ],
          ),
        ],
      ),
    ),
  );
  await Printing.layoutPdf(onLayout: (format) async => pdf.save());
}

pw.TableRow _pdfRow3(String label, String value, {bool isBold = false}) {
  return pw.TableRow(
    children: [
      pw.Container(
        alignment: pw.Alignment.centerRight,
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: pw.Text(label, style: pw.TextStyle(fontSize: 18, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ),
      pw.Container(
        alignment: pw.Alignment.center,
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        child: pw.Text(':', style: pw.TextStyle(fontSize: 18, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ),
      pw.Container(
        alignment: pw.Alignment.centerLeft,
        padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal)),
      ),
    ],
  );
} 