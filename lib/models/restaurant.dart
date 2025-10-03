class Restaurant {
  final String placeId;
  final String name;
  final String address;
  final double? rating;
  final String? priceLevel;
  final List<String> cuisineTypes;
  final String? phoneNumber;
  final String? website;
  final double? latitude;
  final double? longitude;
  final List<String> photos;
  final bool isOpenNow;
  final String? openingHours;

  Restaurant({
    required this.placeId,
    required this.name,
    required this.address,
    this.rating,
    this.priceLevel,
    this.cuisineTypes = const [],
    this.phoneNumber,
    this.website,
    this.latitude,
    this.longitude,
    this.photos = const [],
    this.isOpenNow = false,
    this.openingHours,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Handle both API format and stored format for photos
    List<String> photosList;
    if (json['photos'] is List) {
      final photosData = json['photos'] as List;
      if (photosData.isEmpty) {
        photosList = [];
      } else if (photosData.first is String) {
        // Already a list of strings (from localStorage)
        photosList = List<String>.from(photosData);
      } else {
        // List of objects with photo_reference (from API)
        photosList = _extractPhotoUrls(photosData);
      }
    } else {
      photosList = [];
    }

    // Handle both API format and stored format for other fields
    final address = json['address'] ??
                    json['formatted_address'] ??
                    json['vicinity'] ??
                    '';

    final cuisineTypes = json['cuisine_types'] ?? json['types'] ?? [];

    final phoneNumber = json['phone_number'] ?? json['formatted_phone_number'];

    final isOpenNow = json['is_open_now'] ??
                      json['opening_hours']?['open_now'] ??
                      false;

    final openingHours = json['opening_hours'] is String
        ? json['opening_hours']
        : _formatOpeningHours(json['opening_hours']);

    return Restaurant(
      placeId: json['place_id'] ?? '',
      name: json['name'] ?? '',
      address: address,
      rating: json['rating']?.toDouble(),
      priceLevel: json['price_level'] is int
          ? _convertPriceLevel(json['price_level'])
          : json['price_level'],
      cuisineTypes: List<String>.from(cuisineTypes),
      phoneNumber: phoneNumber,
      website: json['website'],
      latitude: json['latitude'] ?? json['geometry']?['location']?['lat']?.toDouble(),
      longitude: json['longitude'] ?? json['geometry']?['location']?['lng']?.toDouble(),
      photos: photosList,
      isOpenNow: isOpenNow,
      openingHours: openingHours,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'place_id': placeId,
      'name': name,
      'address': address,  // Use simple 'address' for storage
      'rating': rating,
      'price_level': priceLevel,  // Already a string after conversion
      'cuisine_types': cuisineTypes,  // Use simple 'cuisine_types' for storage
      'phone_number': phoneNumber,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
      'photos': photos,  // Already a list of strings
      'is_open_now': isOpenNow,
      'opening_hours': openingHours,  // Already a formatted string
    };
  }

  static String? _convertPriceLevel(int? priceLevel) {
    if (priceLevel == null) return null;
    switch (priceLevel) {
      case 0:
        return 'Free';
      case 1:
        return '\$';
      case 2:
        return '\$\$';
      case 3:
        return '\$\$\$';
      case 4:
        return '\$\$\$\$';
      default:
        return null;
    }
  }

  static List<String> _extractPhotoUrls(List<dynamic>? photos) {
    if (photos == null) return [];
    return photos
        .map((photo) => photo['photo_reference'] as String?)
        .where((ref) => ref != null)
        .cast<String>()
        .toList();
  }

  static String? _formatOpeningHours(Map<String, dynamic>? openingHours) {
    if (openingHours == null) return null;
    final weekdayText = openingHours['weekday_text'] as List<dynamic>?;
    if (weekdayText == null) return null;
    return weekdayText.join('\n');
  }
}