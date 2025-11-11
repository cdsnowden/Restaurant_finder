enum SearchType {
  restaurantName,
  zipCode,
  cityState,
  route,
}

class SearchFilters {
  final SearchType searchType;
  final String zipCode;
  final String city;
  final String state;
  final String restaurantName; // Search by restaurant name (optional)
  final double radiusInMiles;

  // Route-specific fields
  final double? originLat;
  final double? originLng;
  final String destinationAddress; // Can be address, city+state, or zip
  final double maxDetourMiles; // How far off route to search

  final List<String> cuisineTypes;
  final List<int> priceRanges; // Changed to support multiple price levels
  final bool openNow;
  final double minRating; // Minimum star rating filter

  SearchFilters({
    this.searchType = SearchType.zipCode,
    this.zipCode = '',
    this.city = '',
    this.state = '',
    this.restaurantName = '',
    this.radiusInMiles = 5.0,
    this.originLat,
    this.originLng,
    this.destinationAddress = '',
    this.maxDetourMiles = 5.0,
    this.cuisineTypes = const [],
    this.priceRanges = const [],
    this.openNow = false,
    this.minRating = 0.0, // Default to no rating filter
  });

  SearchFilters copyWith({
    SearchType? searchType,
    String? zipCode,
    String? city,
    String? state,
    String? restaurantName,
    double? radiusInMiles,
    double? originLat,
    double? originLng,
    String? destinationAddress,
    double? maxDetourMiles,
    List<String>? cuisineTypes,
    List<int>? priceRanges,
    bool? openNow,
    double? minRating,
  }) {
    return SearchFilters(
      searchType: searchType ?? this.searchType,
      zipCode: zipCode ?? this.zipCode,
      city: city ?? this.city,
      state: state ?? this.state,
      restaurantName: restaurantName ?? this.restaurantName,
      radiusInMiles: radiusInMiles ?? this.radiusInMiles,
      originLat: originLat ?? this.originLat,
      originLng: originLng ?? this.originLng,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      maxDetourMiles: maxDetourMiles ?? this.maxDetourMiles,
      cuisineTypes: cuisineTypes ?? this.cuisineTypes,
      priceRanges: priceRanges ?? this.priceRanges,
      openNow: openNow ?? this.openNow,
      minRating: minRating ?? this.minRating,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'search_type': searchType.toString(),
      'zip_code': zipCode,
      'city': city,
      'state': state,
      'restaurant_name': restaurantName,
      'radius_in_miles': radiusInMiles,
      'origin_lat': originLat,
      'origin_lng': originLng,
      'destination_address': destinationAddress,
      'max_detour_miles': maxDetourMiles,
      'cuisine_types': cuisineTypes,
      'price_ranges': priceRanges,
      'open_now': openNow,
      'min_rating': minRating,
    };
  }

  factory SearchFilters.fromJson(Map<String, dynamic> json) {
    return SearchFilters(
      searchType: SearchType.values.firstWhere(
        (e) => e.toString() == json['search_type'],
        orElse: () => SearchType.zipCode,
      ),
      zipCode: json['zip_code'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      restaurantName: json['restaurant_name'] ?? '',
      radiusInMiles: json['radius_in_miles']?.toDouble() ?? 5.0,
      originLat: json['origin_lat']?.toDouble(),
      originLng: json['origin_lng']?.toDouble(),
      destinationAddress: json['destination_address'] ?? '',
      maxDetourMiles: json['max_detour_miles']?.toDouble() ?? 5.0,
      cuisineTypes: List<String>.from(json['cuisine_types'] ?? []),
      priceRanges: List<int>.from(json['price_ranges'] ?? []),
      openNow: json['open_now'] ?? false,
      minRating: json['min_rating']?.toDouble() ?? 0.0,
    );
  }

  // Helper to check if search location is valid
  bool get hasValidLocation {
    switch (searchType) {
      case SearchType.restaurantName:
        return restaurantName.trim().isNotEmpty &&
            (zipCode.trim().isNotEmpty || (city.trim().isNotEmpty && state.trim().isNotEmpty));
      case SearchType.zipCode:
        return zipCode.trim().isNotEmpty;
      case SearchType.cityState:
        return city.trim().isNotEmpty && state.trim().isNotEmpty;
      case SearchType.route:
        return originLat != null && originLng != null && destinationAddress.trim().isNotEmpty;
    }
  }

  // Get location string for display
  String get locationDisplay {
    switch (searchType) {
      case SearchType.restaurantName:
        String loc = '';
        if (zipCode.isNotEmpty) loc = 'near $zipCode';
        if (city.isNotEmpty && state.isNotEmpty) loc = 'in $city, $state';
        return '$restaurantName $loc';
      case SearchType.zipCode:
        return 'Zip: $zipCode';
      case SearchType.cityState:
        return '$city, $state';
      case SearchType.route:
        return 'Route to $destinationAddress';
    }
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