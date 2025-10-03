class SearchFilters {
  final String zipCode;
  final double radiusInMiles;
  final List<String> cuisineTypes;
  final List<int> priceRanges; // Changed to support multiple price levels
  final bool openNow;

  SearchFilters({
    required this.zipCode,
    this.radiusInMiles = 5.0,
    this.cuisineTypes = const [],
    this.priceRanges = const [],
    this.openNow = false,
  });

  SearchFilters copyWith({
    String? zipCode,
    double? radiusInMiles,
    List<String>? cuisineTypes,
    List<int>? priceRanges,
    bool? openNow,
  }) {
    return SearchFilters(
      zipCode: zipCode ?? this.zipCode,
      radiusInMiles: radiusInMiles ?? this.radiusInMiles,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      priceRanges: priceRanges ?? this.priceRanges,
      openNow: openNow ?? this.openNow,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zip_code': zipCode,
      'radius_in_miles': radiusInMiles,
      'cuisine_types': cuisineTypes,
      'price_ranges': priceRanges,
      'open_now': openNow,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      zipCode: json['zip_code'] ?? '',
      radiusInMiles: json['radius_in_miles']?.toDouble() ?? 5.0,
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      priceRanges: List<int>.from(json['price_ranges'] ?? []),
      openNow: json['open_now'] ?? false,
    );
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