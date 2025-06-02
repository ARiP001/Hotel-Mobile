import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

class HotelNetwork {
  static const String _baseUrl = 'https://data.xotelo.com/api/list';
  static final _logger = Logger();

  // Fetch hotels by location code, offset, and limit
  static Future<List<Map<String, dynamic>>> getHotels({
    required String locationKey,
    int offset = 0,
    int limit = 30,
  }) async {
    final uri = Uri.parse('$_baseUrl?location_key=$locationKey&offset=$offset&limit=$limit');
    _logger.i('GET hotels: $uri');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      _logger.i('Response : [32m${response.statusCode}[0m');
      _logger.t('Body : ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonObject = json.decode(response.body);
        final List<dynamic> jsonList = jsonObject['result']['list'];
        return jsonList.cast<Map<String, dynamic>>();
      } else {
        _logger.e('Error : ${response.statusCode}');
        throw Exception('Server Error : ${response.statusCode}');
      }
    } on TimeoutException {
      _logger.e('Request timeout : $uri');
      throw Exception('Request timeout');
    } catch (e) {
      _logger.e('Error fetching data from $uri : $e');
      throw Exception('Error fetching data : $e');
    }
  }
} 