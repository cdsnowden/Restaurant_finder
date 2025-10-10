import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/search_filters.dart';

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodeUrl = 'https://maps.googleapis.com/maps/api/geocode';
  static const String _apiKey = 'AIzaSyCgoC5_2Ap1P1qJptgZvq8vKaa3JEgBVqc'; // Google Places API key

  Future<List<Restaurant>> searchRestaurants(SearchFilters filters) async {
    try {
      // Get location from either zip code or city/state
      final location = await _getLocation(filters);
      if (location == null) {
        throw Exception('Could not find location. Please check your search criteria.');
      }

      final radiusInMeters = (filters.radiusInMiles * 1609.34).round();
      final locationString = '${location['lat']},${location['lng']}';
      final centerLat = location['lat']!;
      final centerLng = location['lng']!;

      List<Restaurant> allRestaurants = [];

      // If cuisine types are selected, use text search for each cuisine
      if (filters.cuisineTypes.isNotEmpty) {
        for (String cuisine in filters.cuisineTypes) {
          final restaurants = await _searchByCuisine(
            cuisine,
            locationString,
            radiusInMeters,
            filters.openNow,
            filters.priceRanges,
          );
          allRestaurants.addAll(restaurants);
        }

        // Remove duplicates by place_id
        final uniqueRestaurants = <String, Restaurant>{};
        for (var restaurant in allRestaurants) {
          uniqueRestaurants[restaurant.placeId] = restaurant;
        }
        allRestaurants = uniqueRestaurants.values.toList();
      } else {
        // No cuisine filter - use nearby search
        allRestaurants = await _searchNearby(
          locationString,
          radiusInMeters,
          filters.openNow,
          filters.priceRanges,
        );
      }

      // Filter results by actual distance
      allRestaurants = allRestaurants.where((restaurant) {
        if (restaurant.latitude == null || restaurant.longitude == null) {
          return false; // Exclude if no location data
        }
        final distance = _calculateDistance(
          centerLat,
          centerLng,
          restaurant.latitude!,
          restaurant.longitude!,
        );
        return distance <= radiusInMeters;
      }).toList();

      // Filter by minimum rating if specified
      if (filters.minRating > 0) {
        allRestaurants = allRestaurants.where((restaurant) {
          return (restaurant.rating ?? 0) >= filters.minRating;
        }).toList();
      }

      return allRestaurants;
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  Future<List<Restaurant>> _searchNearby(
    String location,
    int radius,
    bool openNow,
    List<int> priceRanges,
  ) async {
    final params = {
      'location': location,
      'radius': radius.toString(),
      'type': 'restaurant',
      'key': _apiKey,
    };

    if (openNow) {
      params['opennow'] = 'true';
    }

    if (priceRanges.isNotEmpty) {
      params['minprice'] = priceRanges.reduce((a, b) => a < b ? a : b).toString();
      params['maxprice'] = priceRanges.reduce((a, b) => a > b ? a : b).toString();
    }

    final url = Uri.parse('$_baseUrl/nearbysearch/json').replace(queryParameters: params);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        List<Restaurant> restaurants = results
            .map((json) => Restaurant.fromJson(json))
            .toList();

        // Filter by price ranges if specific levels are selected
        if (priceRanges.isNotEmpty) {
          restaurants = restaurants.where((restaurant) {
            if (restaurant.priceLevel == null) return false;
            final restaurantPriceInt = _convertPriceLevelToInt(restaurant.priceLevel!);
            return restaurantPriceInt != null && priceRanges.contains(restaurantPriceInt);
          }).toList();
        }

        return restaurants;
      } else {
        throw Exception('Places API error: ${data['status']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Future<List<Restaurant>> _searchByCuisine(
    String cuisine,
    String location,
    int radius,
    bool openNow,
    List<int> priceRanges,
  ) async {
    final params = {
      'query': '$cuisine restaurant',
      'location': location,
      'radius': radius.toString(),
      'key': _apiKey,
    };

    if (openNow) {
      params['opennow'] = 'true';
    }

    if (priceRanges.isNotEmpty) {
      params['minprice'] = priceRanges.reduce((a, b) => a < b ? a : b).toString();
      params['maxprice'] = priceRanges.reduce((a, b) => a > b ? a : b).toString();
    }

    final url = Uri.parse('$_baseUrl/textsearch/json').replace(queryParameters: params);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = data['results'] as List;
        List<Restaurant> restaurants = results
            .map((json) => Restaurant.fromJson(json))
            .toList();

        // Filter by price ranges if specific levels are selected
        if (priceRanges.isNotEmpty) {
          restaurants = restaurants.where((restaurant) {
            if (restaurant.priceLevel == null) return false;
            final restaurantPriceInt = _convertPriceLevelToInt(restaurant.priceLevel!);
            return restaurantPriceInt != null && priceRanges.contains(restaurantPriceInt);
          }).toList();
        }

        return restaurants;
      } else {
        return []; // Return empty list if no results for this cuisine
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Future<Restaurant?> getRestaurantDetails(String placeId) async {
    try {
      final params = {
        'place_id': placeId,
        'fields': 'place_id,name,formatted_address,rating,price_level,types,formatted_phone_number,website,geometry,photos,opening_hours',
        'key': _apiKey,
      };

      final url = Uri.parse('$_baseUrl/details/json').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return Restaurant.fromJson(data['result']);
        }
      }
      return null;
    } catch (e) {
      print('Error getting restaurant details: $e');
      return null;
    }
  }

  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return '$_baseUrl/photo?maxwidth=$maxWidth&photoreference=$photoReference&key=$_apiKey';
  }

  /// Get location from search filters - tries zip code first, then city/state
  Future<Map<String, double>?> _getLocation(SearchFilters filters) async {
    // Try zip code first if provided
    if (filters.zipCode.trim().isNotEmpty) {
      return await _getLocationFromZipCode(filters.zipCode);
    }

    // Otherwise try city and state
    if (filters.city.trim().isNotEmpty && filters.state.trim().isNotEmpty) {
      return await _getLocationFromCityState(filters.city, filters.state);
    }

    return null;
  }

  /// Get location from city and state
  Future<Map<String, double>?> _getLocationFromCityState(String city, String state) async {
    try {
      final params = {
        'address': '$city, $state, USA',
        'components': 'country:US',
        'key': _apiKey,
      };

      final url = Uri.parse('$_geocodeUrl/json').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Geocoding response status for $city, $state: ${data['status']}');

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          print('Found location for $city, $state: ${location['lat']}, ${location['lng']}');
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        } else {
          print('Geocoding failed for $city, $state: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error geocoding city/state: $e');
      return null;
    }
  }

  Future<Map<String, double>?> _getLocationFromZipCode(String zipCode) async {
    try {
      final params = {
        'address': '$zipCode, USA',
        'components': 'country:US',
        'key': _apiKey,
      };

      final url = Uri.parse('$_geocodeUrl/json').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Geocoding response status: ${data['status']}');

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          print('Found location for $zipCode: ${location['lat']}, ${location['lng']}');
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        } else {
          print('Geocoding failed for $zipCode: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        print('HTTP error: ${response.statusCode} - ${response.body}');
      }
      return null;
    } catch (e) {
      print('Error geocoding zip code: $e');
      return null;
    }
  }

  List<String> getSupportedCuisineTypes() {
    return [
      'american_restaurant',
      'bakery',
      'bar',
      'cafe',
      'chinese_restaurant',
      'fast_food_restaurant',
      'french_restaurant',
      'greek_restaurant',
      'indian_restaurant',
      'italian_restaurant',
      'japanese_restaurant',
      'korean_restaurant',
      'mediterranean_restaurant',
      'mexican_restaurant',
      'middle_eastern_restaurant',
      'pizza_restaurant',
      'seafood_restaurant',
      'steak_house',
      'sushi_restaurant',
      'thai_restaurant',
      'vegetarian_restaurant',
    ];
  }

  String formatCuisineType(String type) {
    return type
        .replaceAll('_', ' ')
        .replaceAll('restaurant', '')
        .trim()
        .split(' ')
        .map((word) => word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : '')
        .join(' ');
  }

  int? _convertPriceLevelToInt(String priceLevel) {
    switch (priceLevel) {
      case 'Free':
        return 0;
      case '\$':
        return 1;
      case '\$\$':
        return 2;
      case '\$\$\$':
        return 3;
      case '\$\$\$\$':
        return 4;
      default:
        return null;
    }
  }

  // Calculate distance between two coordinates using Haversine formula (returns meters)
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}