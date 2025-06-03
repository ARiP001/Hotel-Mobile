import 'package:flutter/material.dart';
import '../models/transaction.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/currency_util.dart';

class ReceiptPage extends StatefulWidget {
  final Transaction transaction;
  const ReceiptPage({super.key, required this.transaction});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  String _region = 'usd';

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final username = widget.transaction.username;
    final region = prefs.getString('user_${username}_region');
    setState(() {
      _region = region ?? 'usd';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final convertedPrice = CurrencyUtil.convert(t.price, _region);
    final convertedTotal = CurrencyUtil.convert(t.total, _region);
    final formattedPrice = CurrencyUtil.format(convertedPrice, _region);
    final formattedTotal = CurrencyUtil.format(convertedTotal, _region);
    final bool isDiscount = (t.total < t.price * t.day);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bukti Pemesanan'),
        backgroundColor: const Color(0xFF388E3C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Icon(Icons.receipt_long, size: 60, color: Colors.green[700]),
                ),
                const SizedBox(height: 16),
                Text('Hotel: ${t.hotelName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Username: ${t.username}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Check-in: ${DateFormat('dd MMM yyyy').format(t.checkin)}', style: const TextStyle(fontSize: 16)),
                Text('Check-out: ${DateFormat('dd MMM yyyy').format(t.checkout)}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Jumlah Hari: ${t.day}', style: const TextStyle(fontSize: 16)),
                Text('Harga per Hari: $formattedPrice', style: const TextStyle(fontSize: 16)),
                if (isDiscount)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: Text(
                      'Special Offer: 50% Discount diterapkan!',
                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                  ),
                const Divider(height: 24),
                Text('Total: $formattedTotal', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('Kembali ke Beranda'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF388E3C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 