import 'package:flutter/material.dart';
import 'package:TuruKamar/utils/hotel_network.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'hotel_detail_page.dart';
import 'tracking_page.dart';
import 'welcome_page.dart';
import '../utils/session_manager.dart';
import '../utils/currency_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key, this.onFilterPressed});
  final VoidCallback? onFilterPressed;

  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}

class _MainMenuPageState extends State<MainMenuPage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _hotels = [];
  final List<String> _locationCodes = [
    'g2304080', // Sleman
    'g2304084', // Bantul
    'g2304083', // Gunungkidul
    'g2304082', // Kulonprogo
    'g14782503', // Kota Yogyakarta
  ];
  final Map<String, int> _offsets = {};
  bool _isLoading = false;
  bool _hasMore = true;
  String? _region;
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  String? _selectedLocation;
  double? _maxPrice;
  double? _minRating;
  String _searchQuery = '';
  bool _discountOnly = false;

  List<Map<String, dynamic>> get _filteredHotels {
    return _hotels.where((hotel) {
      // Filter pencarian nama
      if (_searchQuery.isNotEmpty) {
        final name = (hotel['name'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase())) return false;
      }
      // Filter lokasi
      if (_selectedLocation != null && _selectedLocation != 'Semua') {
        final key = hotel['key'] ?? '';
        if (_selectedLocation == 'Sleman' && !key.contains('g2304080')) return false;
        if (_selectedLocation == 'Bantul' && !key.contains('g2304084')) return false;
        if (_selectedLocation == 'Gunungkidul' && !key.contains('g2304083')) return false;
        if (_selectedLocation == 'Kulonprogo' && !key.contains('g2304082')) return false;
        if (_selectedLocation == 'Kota Yogyakarta' && !key.contains('g14782503')) return false;
      }
      // Filter harga
      final minPrice = hotel['price_ranges']?['minimum'];
      final priceVal = (minPrice is num) ? minPrice.toDouble() : double.tryParse(minPrice?.toString() ?? '') ?? 0;
      double convertedMaxPrice = _maxPrice ?? 0;
      if (_maxPrice != null) {
        // Konversi nilai filter ke USD sebelum dibandingkan
        convertedMaxPrice = CurrencyUtil.convertToUSD(_maxPrice!, _region ?? 'usd');
        if (priceVal > convertedMaxPrice) return false;
      }
      // Filter rating
      final rating = hotel['review_summary']?['rating'];
      final ratingVal = (rating is num) ? rating.toDouble() : double.tryParse(rating?.toString() ?? '') ?? 0;
      if (_minRating != null && ratingVal < _minRating!) return false;
      // Filter diskon
      if (_discountOnly) {
        final orderCount = hotel['review_summary']?['count'];
        if (orderCount != 0) return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    for (var code in _locationCodes) {
      _offsets[code] = 0;
    }
    _checkSession();
    _loadRegion();
    _fetchHotels();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkSession() async {
    final isLoggedIn = await SessionManager.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomePage()),
      );
    }
  }

  Future<void> _loadRegion() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('logged_in_user');
    if (username != null) {
      final region = prefs.getString('user_${username}_region') ?? 'usd';
      setState(() {
        _region = region;
      });
    }
  }

  String _formatCurrency(double amount) {
    final converted = CurrencyUtil.convert(amount, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Future<void> _fetchHotels() async {
    if (_isLoading || !_hasMore) return;
    setState(() => _isLoading = true);
    List<Map<String, dynamic>> newHotels = [];
    for (var code in _locationCodes) {
      final offset = _offsets[code] ?? 0;
      final hotels = await HotelNetwork.getHotels(locationKey: code, offset: offset);
      final filtered = hotels.where((hotel) {
        final minPrice = hotel['price_ranges']?['minimum'];
        if (minPrice == null) return false;
        if (minPrice is num) return minPrice > 0;
        final minPriceStr = minPrice.toString();
        if (minPriceStr.isEmpty || minPriceStr == '-') return false;
        final parsed = double.tryParse(minPriceStr);
        return parsed != null && parsed > 0;
      }).toList();
      if (filtered.isNotEmpty) {
        newHotels.addAll(filtered);
        _offsets[code] = offset + hotels.length;
      }
      if (hotels.length < 30) {
        _hasMore = false;
      }
    }
    setState(() {
      _hotels.addAll(newHotels);
      _isLoading = false;
    });
    print('Total hotels loaded: ${_hotels.length}');
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoading && _hasMore) {
      _fetchHotels();
    }
  }

  void _showFilterDialog() async {
    String? tempLocation = _selectedLocation;
    double? tempMaxPrice = _maxPrice;
    double? tempMinRating = _minRating;
    bool tempDiscountOnly = _discountOnly;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Filter Hotel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: tempLocation ?? 'Semua',
                      items: const [
                        DropdownMenuItem(value: 'Semua', child: Text('Semua Lokasi')),
                        DropdownMenuItem(value: 'Sleman', child: Text('Sleman')),
                        DropdownMenuItem(value: 'Bantul', child: Text('Bantul')),
                        DropdownMenuItem(value: 'Gunungkidul', child: Text('Gunungkidul')),
                        DropdownMenuItem(value: 'Kulonprogo', child: Text('Kulonprogo')),
                        DropdownMenuItem(value: 'Kota Yogyakarta', child: Text('Kota Yogyakarta')),
                      ],
                      onChanged: (val) => setModalState(() => tempLocation = val),
                      decoration: const InputDecoration(labelText: 'Lokasi'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: tempMaxPrice?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Harga Maksimum'),
                      onChanged: (val) => setModalState(() => tempMaxPrice = double.tryParse(val)),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: tempMinRating?.toString() ?? '',
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Rating Minimum'),
                      onChanged: (val) => setModalState(() => tempMinRating = double.tryParse(val)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Checkbox(
                          value: tempDiscountOnly,
                          onChanged: (val) => setModalState(() => tempDiscountOnly = val ?? false),
                        ),
                        const Text('Tampilkan hanya hotel diskon'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedLocation = null;
                              _maxPrice = null;
                              _minRating = null;
                              _discountOnly = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF388E3C)),
                          onPressed: () {
                            setState(() {
                              _selectedLocation = tempLocation == 'Semua' ? null : tempLocation;
                              _maxPrice = tempMaxPrice;
                              _minRating = tempMinRating;
                              _discountOnly = tempDiscountOnly;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Terapkan', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF388E3C),
        title: const Text('Daftar Hotel', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.map, color: Colors.white),
            tooltip: 'Buka Peta',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrackingPage(hotels: _filteredHotels),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari hotel...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: _filteredHotels.isEmpty && _isLoading
          ? const Center(child: CircularProgressIndicator())
                : _filteredHotels.isEmpty
                    ? const Center(
                        child: Text(
                          'Tidak ada hotel yang ditemukan',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
          : ListView.builder(
              controller: _scrollController,
              itemCount: _filteredHotels.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _filteredHotels.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final hotel = _filteredHotels[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HotelDetailPage(hotel: hotel),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hotel['image'] != null && hotel['image'].toString().startsWith('http'))
                          CachedNetworkImage(
                            imageUrl: hotel['image'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const SizedBox(
                              height: 200,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.hotel, size: 80, color: Colors.green),
                          )
                        else
                          const SizedBox(
                            height: 200,
                            child: Center(child: Icon(Icons.hotel, size: 80, color: Colors.green)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel['name'] ?? 'No Name',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${hotel['review_summary']?['rating'] ?? '-'}'),
                                  const SizedBox(width: 16),
                                  const Icon(Icons.people, size: 20),
                                  const SizedBox(width: 4),
                                  Text('${hotel['review_summary']?['count'] ?? '-'} pemesanan'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Harga mulai: ${_formatCurrency((hotel['price_ranges']?['minimum'] as num?)?.toDouble() ?? 0.0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF388E3C),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
                      ),
          ),
        ],
            ),
    );
  }
} 