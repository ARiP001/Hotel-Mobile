import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utilities/currency_util.dart';

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
                    // TODO: implement booking
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