class SearchFilters {
  final String zipCode;
  final String city;
  final String state;
  final double radiusInMiles;
  final List<String> cuisineTypes;
  final List<int> priceRanges; // Changed to support multiple price levels
  final bool openNow;
  final double minRating; // Minimum star rating filter

  SearchFilters({
    this.zipCode = '',
    this.city = '',
    this.state = '',
    this.radiusInMiles = 5.0,
    this.cuisineTypes = const [],
    this.priceRanges = const [],
    this.openNow = false,
    this.minRating = 0.0, // Default to no rating filter
  });

  SearchFilters copyWith({
    String? zipCode,
    String? city,
    String? state,
    double? radiusInMiles,
    List<String>? cuisineTypes,
    List<int>? priceRanges,
    bool? openNow,
    double? minRating,
  }) {
    return SearchFilters(
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      state: state ?? this.state,
      radiusInMiles: radiusInMiles ?? this.radiusInMiles,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      priceRanges: priceRanges ?? this.priceRanges,
      openNow: openNow ?? this.openNow,
      minRating: minRating ?? this.minRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zip_code': zipCode,
      'city': city,
      'state': state,
      'radius_in_miles': radiusInMiles,
      'cuisine_types': cuisineTypes,
      'price_ranges': priceRanges,
      'open_now': openNow,
      'min_rating': minRating,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      zipCode: json['zip_code'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      radiusInMiles: json['radius_in_miles']?.toDouble() ?? 5.0,
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      priceRanges: List<int>.from(json['price_ranges'] ?? []),
      openNow: json['open_now'] ?? false,
      minRating: json['min_rating']?.toDouble() ?? 0.0,
    );
  }

  // Helper to check if search location is valid
  bool get hasValidLocation {
    return zipCode.trim().isNotEmpty || (city.trim().isNotEmpty && state.trim().isNotEmpty);
  }

  // Get location string for display
  String get locationDisplay {
    if (zipCode.isNotEmpty) return 'Zip: $zipCode';
    if (city.isNotEmpty && state.isNotEmpty) return '$city, $state';
    return 'No location set';
  }
}

class PriceRange {
  final int minLevel;
  final int maxLevel;

  PriceRange({
    required this.minLevel,
    required this.maxLevel,
  });

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      minLevel: json['min_level'] ?? 0,
      maxLevel: json['max_level'] ?? 4,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min_level': minLevel,
      'max_level': maxLevel,
    };
  }

  String get displayText {
    final min = _getLevelSymbol(minLevel);
    final max = _getLevelSymbol(maxLevel);
    return minLevel == maxLevel ? min : '$min - $max';
  }

  String _getLevelSymbol(int level) {
    switch (level) {
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
        return '\$';
    }
  }
}