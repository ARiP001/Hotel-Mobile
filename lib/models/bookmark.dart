class HotelBookmark {
  final String key;
  final String name;
  final String image;
  final double minPrice;
  final double maxPrice;
  final Map<String, dynamic> geo;
  final Map<String, dynamic> review;
  final List<dynamic> mentions;

  HotelBookmark({
    required this.key,
    required this.name,
    required this.image,
    required this.minPrice,
    required this.maxPrice,
    required this.geo,
    required this.review,
    required this.mentions,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'image': image,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'geo': geo,
      'review': review,
      'mentions': mentions,
    };
  }

  factory HotelBookmark.fromJson(Map<String, dynamic> json) {
    return HotelBookmark(
      key: json['key'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      minPrice: (json['minPrice'] as num).toDouble(),
      maxPrice: (json['maxPrice'] as num).toDouble(),
      geo: json['geo'] as Map<String, dynamic>,
      review: json['review'] as Map<String, dynamic>,
      mentions: json['mentions'] as List<dynamic>,
    );
  }
} 