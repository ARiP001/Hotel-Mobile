import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/bookmark.dart';
import '../utils/bookmark_service.dart';
import '../utils/currency_util.dart';
import '../utils/session_manager.dart';
import 'welcome_page.dart';
import 'hotel_detail_page.dart';

class BookmarkPage extends StatefulWidget {
  const BookmarkPage({super.key});

  @override
  State<BookmarkPage> createState() => _BookmarkPageState();
}

class _BookmarkPageState extends State<BookmarkPage> {
  List<HotelBookmark> _bookmarks = [];
  String? _username;
  String? _region;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
    _loadBookmarks();
  }

  Future<void> _checkSession() async {
    if (!await SessionManager.isLoggedIn()) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const WelcomePage()),
        );
      }
    }
  }

  Future<void> _loadBookmarks() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('logged_in_user');
    _region = prefs.getString('user_${_username}_region') ?? 'usd';
    
    if (_username != null) {
      final bookmarks = await BookmarkService.getBookmarks(_username!);
      setState(() {
        _bookmarks = bookmarks;
        _isLoading = false;
      });
    }
  }

  String _formatCurrency(double amount) {
    final converted = CurrencyUtil.convert(amount, _region ?? 'usd');
    return CurrencyUtil.format(converted, _region ?? 'usd');
  }

  Future<void> _removeBookmark(HotelBookmark bookmark) async {
    if (_username != null) {
      await BookmarkService.removeBookmark(bookmark.key, _username!);
      await _loadBookmarks();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmark Hotel'),
        backgroundColor: const Color(0xFF388E3C),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookmarks.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada hotel yang di-bookmark',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = _bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: bookmark.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: bookmark.image,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const SizedBox(
                                  width: 60,
                                  height: 60,
                                  child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.hotel, size: 40, color: Colors.green),
                              )
                            : const Icon(Icons.hotel, size: 40, color: Colors.green),
                        title: Text(
                          bookmark.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Rating: ${bookmark.review['rating'] ?? '-'} | Harga: ${_formatCurrency(bookmark.minPrice)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.bookmark, color: Colors.green),
                          onPressed: () => _removeBookmark(bookmark),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HotelDetailPage(
                                hotel: {
                                  'key': bookmark.key,
                                  'name': bookmark.name,
                                  'image': bookmark.image,
                                  'price_ranges': {
                                    'minimum': bookmark.minPrice,
                                    'maximum': bookmark.maxPrice,
                                  },
                                  'geo': bookmark.geo,
                                  'review_summary': bookmark.review,
                                  'mentions': bookmark.mentions,
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 