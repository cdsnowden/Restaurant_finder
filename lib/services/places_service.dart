import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/search_filters.dart';
import '../models/restaurant_with_route_info.dart';
import 'directions_service.dart';

// Search result class to handle pagination
class SearchResult {
  final List<Restaurant> restaurants;
  final String? nextPageToken;

  SearchResult({
    required this.restaurants,
    this.nextPageToken,
  });
}

class PlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _geocodeUrl = 'https://maps.googleapis.com/maps/api/geocode';
  static const String _apiKey = 'AIzaSyCgoC5_2Ap1P1qJptgZvq8vKaa3JEgBVqc'; // Google Places API key

  Future<SearchResult> searchRestaurants(SearchFilters filters, {String? pageToken}) async {
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
      String? nextPageToken;

      // If restaurant name is provided, search by name
      if (filters.restaurantName.trim().isNotEmpty) {
        final result = await _searchByName(
          filters.restaurantName,
          locationString,
          radiusInMeters,
          filters.openNow,
          filters.priceRanges,
          pageToken: pageToken,
        );
        allRestaurants = result['restaurants'] as List<Restaurant>;
        nextPageToken = result['nextPageToken'] as String?;
      }
      // If cuisine types are selected, use text search for each cuisine
      else if (filters.cuisineTypes.isNotEmpty) {
        for (String cuisine in filters.cuisineTypes) {
          final result = await _searchByCuisine(
            cuisine,
            locationString,
            radiusInMeters,
            filters.openNow,
            filters.priceRanges,
            pageToken: pageToken,
          );
          allRestaurants.addAll(result['restaurants'] as List<Restaurant>);
          // Keep the last page token
          nextPageToken = result['nextPageToken'] as String?;
        }

        // Remove duplicates by place_id
        final uniqueRestaurants = <String, Restaurant>{};
        for (var restaurant in allRestaurants) {
          uniqueRestaurants[restaurant.placeId] = restaurant;
        }
        allRestaurants = uniqueRestaurants.values.toList();
      } else {
        // No cuisine filter - use nearby search
        final result = await _searchNearby(
          locationString,
          radiusInMeters,
          filters.openNow,
          filters.priceRanges,
          pageToken: pageToken,
        );
        allRestaurants = result['restaurants'] as List<Restaurant>;
        nextPageToken = result['nextPageToken'] as String?;
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

      return SearchResult(
        restaurants: allRestaurants,
        nextPageToken: nextPageToken,
      );
    } catch (e) {
      throw Exception('Failed to search restaurants: $e');
    }
  }

  /// Search for restaurants along a route
  Future<List<RestaurantWithRouteInfo>> searchRestaurantsAlongRoute(
    SearchFilters filters,
  ) async {
    try {
      if (filters.originLat == null || filters.originLng == null) {
        throw Exception('Origin location is required for route search');
      }

      final directionsService = DirectionsService();

      // Get the route
      final route = await directionsService.getRoute(
        filters.originLat!,
        filters.originLng!,
        filters.destinationAddress,
      );

      if (route == null) {
        throw Exception('Could not calculate route. Please check your destination.');
      }

      // Sample points along the route (every 3 miles / 5,000 meters)
      final sampledPoints = directionsService.sampleRoutePoints(
        route.points,
        5000, // 3 miles in meters
      );

      final maxDetourMeters = filters.maxDetourMiles * 1609.34;
      final List<Restaurant> allRestaurants = [];
      final seenPlaceIds = <String>{};

      // Use a fixed search radius of 10 miles (16000 meters) around each sample point
      // We'll filter by actual detour distance afterwards
      const searchRadiusMeters = 16000; // ~10 miles

      // Search around each sampled point
      for (final point in sampledPoints) {
        final locationString = '${point.lat},${point.lng}';

        Map<String, dynamic> searchResult;

        // Use cuisine search if cuisines are specified, otherwise nearby search
        if (filters.cuisineTypes.isNotEmpty) {
          for (final cuisine in filters.cuisineTypes) {
            searchResult = await _searchByCuisine(
              cuisine,
              locationString,
              searchRadiusMeters,
              filters.openNow,
              filters.priceRanges,
            );
            final restaurants = searchResult['restaurants'] as List<Restaurant>;

            for (final restaurant in restaurants) {
              if (!seenPlaceIds.contains(restaurant.placeId)) {
                allRestaurants.add(restaurant);
                seenPlaceIds.add(restaurant.placeId);
              }
            }
          }
        } else {
          searchResult = await _searchNearby(
            locationString,
            searchRadiusMeters,
            filters.openNow,
            filters.priceRanges,
          );
          final restaurants = searchResult['restaurants'] as List<Restaurant>;

          for (final restaurant in restaurants) {
            if (!seenPlaceIds.contains(restaurant.placeId)) {
              allRestaurants.add(restaurant);
              seenPlaceIds.add(restaurant.placeId);
            }
          }
        }
      }

      // Filter and add route info to each restaurant
      final List<RestaurantWithRouteInfo> restaurantsWithRouteInfo = [];

      for (final restaurant in allRestaurants) {
        if (restaurant.latitude == null || restaurant.longitude == null) continue;

        // Calculate distance from route
        final distanceFromRoute = directionsService.distanceFromRoute(
          restaurant.latitude!,
          restaurant.longitude!,
          route.points,
        );

        // Filter by max detour
        if (distanceFromRoute > maxDetourMeters) continue;

        // Filter by rating if specified
        if (filters.minRating > 0 && (restaurant.rating ?? 0) < filters.minRating) {
          continue;
        }

        // Calculate position along route
        final position = directionsService.getPositionAlongRoute(
          restaurant.latitude!,
          restaurant.longitude!,
          route.points,
        );

        final distanceAlongRoute = position * route.distanceMeters;

        restaurantsWithRouteInfo.add(RestaurantWithRouteInfo(
          restaurant: restaurant,
          distanceFromRouteMeters: distanceFromRoute,
          positionAlongRoute: position,
          distanceAlongRouteMeters: distanceAlongRoute,
        ));
      }

      // Sort by position along route
      restaurantsWithRouteInfo.sort((a, b) => a.positionAlongRoute.compareTo(b.positionAlongRoute));

      return restaurantsWithRouteInfo;
    } catch (e) {
      throw Exception('Failed to search restaurants along route: $e');
    }
  }

  Future<Map<String, dynamic>> _searchNearby(
    String location,
    int radius,
    bool openNow,
    List<int> priceRanges,
    {String? pageToken}
  ) async {
    final params = {
      'location': location,
      'radius': radius.toString(),
      'type': 'restaurant',
      'key': _apiKey,
    };

    if (pageToken != null) {
      params['pagetoken'] = pageToken;
    }

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
        final nextPageToken = data['next_page_token'] as String?;

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

        return {
          'restaurants': restaurants,
          'nextPageToken': nextPageToken,
        };
      } else {
        throw Exception('Places API error: ${data['status']}');
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _searchByCuisine(
    String cuisine,
    String location,
    int radius,
    bool openNow,
    List<int> priceRanges,
    {String? pageToken}
  ) async {
    final params = {
      'query': '$cuisine restaurant',
      'location': location,
      'radius': radius.toString(),
      'key': _apiKey,
    };

    if (pageToken != null) {
      params['pagetoken'] = pageToken;
    }

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
        final nextPageToken = data['next_page_token'] as String?;

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

        return {
          'restaurants': restaurants,
          'nextPageToken': nextPageToken,
        };
      } else {
        return {
          'restaurants': <Restaurant>[],
          'nextPageToken': null,
        }; // Return empty result if no results for this cuisine
      }
    } else {
      throw Exception('HTTP error: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> _searchByName(
    String restaurantName,
    String location,
    int radius,
    bool openNow,
    List<int> priceRanges,
    {String? pageToken}
  ) async {
    final params = {
      'query': '$restaurantName restaurant',
      'location': location,
      'radius': radius.toString(),
      'key': _apiKey,
    };

    if (pageToken != null) {
      params['pagetoken'] = pageToken;
    }

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
        final nextPageToken = data['next_page_token'] as String?;

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

        return {
          'restaurants': restaurants,
          'nextPageToken': nextPageToken,
        };
      } else {
        return {
          'restaurants': <Restaurant>[],
          'nextPageToken': null,
        };
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

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
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

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return {
            'lat': location['lat'].toDouble(),
            'lng': location['lng'].toDouble(),
          };
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  List<String> getSupportedCuisineTypes() {
    return [
      'american_restaurant',
      'bakery',
      'bar',
      'breakfast_restaurant',
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

  // Public method to get location from filters
  Future<Map<String, double>?> getLocationFromFilters(SearchFilters filters) async {
    return await _getLocation(filters);
  }

  // Calculate distance between two coordinates using Haversine formula (returns meters)
  // Made public so provider can use it for sorting
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Keep private version for backward compatibility
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return calculateDistance(lat1, lon1, lat2, lon2);
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}