import 'package:shared_preferences/shared_preferences.dart';
import '../models/bookmark.dart';
import 'dart:convert';

class BookmarkService {
  static const String _bookmarksKey = 'saved_hotel_bookmarks';

  // Mendapatkan key bookmark untuk user tertentu
  static String _getUserBookmarksKey(String username) {
    return '${_bookmarksKey}_$username';
  }

  // Menyimpan bookmark
  static Future<void> saveBookmark(Map<String, dynamic> hotel, String username) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks(username);

    // Cek apakah sudah ada di bookmark
    if (!bookmarks.any((item) => item.key == hotel['key'])) {
      final bookmark = HotelBookmark(
        key: hotel['key'] ?? '',
        name: hotel['name'] ?? '',
        image: hotel['image'] ?? '',
        minPrice: (hotel['price_ranges']?['minimum'] as num?)?.toDouble() ?? 0.0,
        maxPrice: (hotel['price_ranges']?['maximum'] as num?)?.toDouble() ?? 0.0,
        geo: hotel['geo'] ?? {},
        review: hotel['review_summary'] ?? {},
        mentions: hotel['mentions'] ?? [],
      );
      
      bookmarks.add(bookmark);
      await prefs.setString(_getUserBookmarksKey(username), _encodeBookmarks(bookmarks));
    }
  }

  // Menghapus bookmark
  static Future<void> removeBookmark(String hotelKey, String username) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = await getBookmarks(username);

    bookmarks.removeWhere((item) => item.key == hotelKey);
    await prefs.setString(_getUserBookmarksKey(username), _encodeBookmarks(bookmarks));
  }

  // Mendapatkan semua bookmark
  static Future<List<HotelBookmark>> getBookmarks(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_getUserBookmarksKey(username));

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final json = jsonDecode(jsonString) as List;
      return json.map((item) => HotelBookmark.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  // Mengecek status bookmark
  static Future<bool> isBookmarked(String hotelKey, String username) async {
    final bookmarks = await getBookmarks(username);
    return bookmarks.any((item) => item.key == hotelKey);
  }

  // Helper untuk encode data
  static String _encodeBookmarks(List<HotelBookmark> bookmarks) {
    final jsonList = bookmarks.map((item) => item.toJson()).toList();
    return jsonEncode(jsonList);
  }
} 