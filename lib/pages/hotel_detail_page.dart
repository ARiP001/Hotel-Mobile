import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/currency_util.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../models/boxes.dart';
import 'package:intl/intl.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';
import '../utilities/notification_service.dart';
import '../pages/receipt_page.dart';

class HotelDetailPage extends StatefulWidget {
  final Map<String, dynamic> hotel;
  const HotelDetailPage({super.key, required this.hotel});

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  String _region = 'usd';

  @override
  void initState() {
    super.initState();
    _loadRegion();
  }

  Future<void> _loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final user = prefs.getString('logged_in_user');
    final region = user != null ? prefs.getString('user_${user}_region') : null;
    setState(() {
      _region = region ?? 'usd';
    });
  }

  Widget roomInfo(String label, double price) {
    final converted = CurrencyUtil.convert(price, _region);
    return Card(
      child: ListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(CurrencyUtil.format(converted, _region)),
      ),
    );
  }

  Future<void> _showShakeConfirmationDialog({
    required Transaction transaction,
    required double total,
    required String username,
  }) async {
    bool isConfirmed = false;
    StreamSubscription<AccelerometerEvent>? _subscription;
    BuildContext? dialogContext;

    void onShake() async {
      print('onShake called, isConfirmed=$isConfirmed');
      if (isConfirmed) return;
      isConfirmed = true;
      _subscription?.cancel();
      if (dialogContext != null) {
        Navigator.of(dialogContext!).pop();
        await Future.delayed(const Duration(milliseconds: 200));
      }

      // Cek balance
      final prefs = await SharedPreferences.getInstance();
      final balanceKey = 'user_${username}_balance';
      final currentBalance = prefs.getDouble(balanceKey) ?? 0.0;
      if (currentBalance < total) {
        // Tampilkan pesan error saldo tidak cukup
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Saldo Tidak Cukup'),
              content: const Text('Saldo Anda tidak mencukupi untuk melakukan pemesanan ini.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // Notifikasi shake
      await NotificationService().showNotification(
        title: 'Konfirmasi Booking',
        body: 'Pemesanan kamar berhasil dikonfirmasi dengan shake!',
      );

      // Update balance
      final newBalance = currentBalance - total;
      await prefs.setDouble(balanceKey, newBalance);

      // Simpan transaksi ke Hive
      final box = await Hive.openBox<Transaction>(HiveBoxes.transaction);
      await box.add(transaction);

      // Navigasi ke ReceiptPage
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(
            builder: (context) => ReceiptPage(transaction: transaction),
          ),
        );
      }
    }

    _subscription = accelerometerEvents.listen((event) {
      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      print('Shake acceleration: ' + acceleration.toStringAsFixed(2));
      if (acceleration > 15) {
        onShake();
      }
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return AlertDialog(
          title: const Text('Konfirmasi Pemesanan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.phone_android, size: 60, color: Colors.green),
              SizedBox(height: 16),
              Text('Shake HP Anda untuk konfirmasi pemesanan!'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _subscription?.cancel();
                Navigator.pop(ctx);
              },
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
    _subscription?.cancel();
  }

  Future<void> _showBookingDialog() async {
    DateTime? checkin;
    DateTime? checkout;
    String roomType = 'Economist';
    final hotel = widget.hotel;
    final price = hotel['price_ranges'] ?? {};
    final minPrice = (price['minimum'] is num) ? price['minimum'].toDouble() : double.tryParse(price['minimum']?.toString() ?? '') ?? 0;
    final maxPrice = (price['maximum'] is num) ? price['maximum'].toDouble() : double.tryParse(price['maximum']?.toString() ?? '') ?? 0;
    final regPrice = ((minPrice + maxPrice) / 2);
    final review = hotel['review_summary'] ?? {};
    final isSpecialOffer = (review['count'] == 0);

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Pesan Kamar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Check-in: ${checkin != null ? DateFormat('dd MMM yyyy').format(checkin!) : '-'}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => checkin = picked);
                        print('Check-in picked ${checkin}');
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Check-out ${checkout != null ? DateFormat('dd MMM yyyy').format(checkout!) : '-'}'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: checkin == null
                        ? null
                        : () async {
                            print('Check-in value before checkout: \\${checkin}');
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: checkin!.add(const Duration(days: 1)),
                              firstDate: checkin!.add(const Duration(days: 1)),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => checkout = picked);
                              print('Check-out picked: \\${checkout}');
                            }
                          },
                  ),
                  DropdownButton<String>(
                    value: roomType,
                    items: ['Economist', 'Regular', 'VIP'].map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                    onChanged: (val) => setState(() => roomType = val!),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (checkin == null || checkout == null || !checkout!.isAfter(checkin!)) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tanggal tidak valid')));
                      return;
                    }
                    final day = checkout!.difference(checkin!).inDays;
                    double priceVal;
                    if (roomType == 'Economist') priceVal = minPrice;
                    else if (roomType == 'VIP') priceVal = maxPrice;
                    else priceVal = regPrice;
                    double total = priceVal * day;
                    bool appliedDiscount = false;
                    if (isSpecialOffer) {
                      total = total * 0.5;
                      appliedDiscount = true;
                    }

                    // Ambil username dari SharedPreferences
                    final prefs = await SharedPreferences.getInstance();
                    final username = prefs.getString('logged_in_user') ?? '-';

                    final transaction = Transaction(
                      username: username,
                      hotelKey: hotel['key'] ?? '',
                      hotelName: hotel['name'] ?? '',
                      checkin: checkin!,
                      checkout: checkout!,
                      day: day,
                      price: priceVal,
                      total: total,
                    );

                    // Tampilkan dialog konfirmasi shake
                    await _showShakeConfirmationDialog(
                      transaction: transaction,
                      total: total,
                      username: username,
                    );

                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Pesan'),
                      if (isSpecialOffer)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.local_offer, color: Colors.orange, size: 20),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hotel = widget.hotel;
    final review = hotel['review_summary'] ?? {};
    final price = hotel['price_ranges'] ?? {};
    final geo = hotel['geo'] ?? {};
    final mentions = hotel['mentions'] as List<dynamic>? ?? [];
    final minPrice = (price['minimum'] is num) ? price['minimum'].toDouble() : double.tryParse(price['minimum']?.toString() ?? '') ?? 0;
    final maxPrice = (price['maximum'] is num) ? price['maximum'].toDouble() : double.tryParse(price['maximum']?.toString() ?? '') ?? 0;
    final regPrice = ((minPrice + maxPrice) / 2).toStringAsFixed(0);
    final isSpecialOffer = (review['count'] == 0);

    // Mapping location codes to names
    String getLocationName(String key) {
      if (key.contains('g2304080')) return 'Sleman';
      if (key.contains('g2304084')) return 'Bantul';
      if (key.contains('g2304083')) return 'Gunungkidul';
      if (key.contains('g2304082')) return 'Kulonprogo';
      if (key.contains('g14782503')) return 'Kota Yogyakarta';
      return '-';
    }
    final locationName = getLocationName(hotel['key'] ?? '');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        title: Text(hotel['name'] ?? 'Detail Hotel', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: (hotel['image'] != null && hotel['image'].toString().startsWith('http'))
                    ? CachedNetworkImage(
                        imageUrl: hotel['image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SizedBox(
                          width: double.infinity,
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.hotel, size: 80, color: Colors.green),
                      )
                    : const Icon(Icons.hotel, size: 80, color: Colors.green),
              ),
              const SizedBox(height: 16),
              Text(hotel['name'] ?? '-', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              if (locationName != '-')
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Text(locationName, style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500)),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 20),
                  const SizedBox(width: 4),
                  Text('${review['rating'] ?? '-'}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 16),
                  const Icon(Icons.people, size: 20),
                  const SizedBox(width: 4),
                  Text('${review['count'] ?? '-'} pemesanan', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red, size: 20),
                  const SizedBox(width: 4),
                  Text('Lat: ${geo['latitude'] ?? '-'}, Lng: ${geo['longitude'] ?? '-'}', style: const TextStyle(fontSize: 16)),
                ],
              ),
              const SizedBox(height: 8),
              if (mentions.isNotEmpty) ...[
                const Text('Kategori:', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: mentions.map((m) => Chip(label: Text(m.toString()))).toList(),
                ),
                const SizedBox(height: 8),
              ],
              if (isSpecialOffer) ...[
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.local_offer, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Special Offer: 50% Discount',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Jenis Kamar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              roomInfo('Economist', minPrice),
              roomInfo('Regular', double.tryParse(regPrice) ?? minPrice),
              roomInfo('VIP', maxPrice),
              const SizedBox(height: 16),
              if (hotel['url'] != null && hotel['url'].toString().startsWith('http'))
                TextButton.icon(
                  onPressed: () {
                    // TODO: open url
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Lihat di TripAdvisor'),
                ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF388E3C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    _showBookingDialog();
                  },
                  child: const Text('Pesan Kamar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 