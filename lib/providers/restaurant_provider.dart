import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/restaurant_with_route_info.dart';
import '../models/search_filters.dart';
import '../services/places_service.dart';

class RestaurantProvider with ChangeNotifier {
  final PlacesService _placesService = PlacesService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<RestaurantWithRouteInfo> _routeRestaurants = []; // For route-based searches
  bool _isLoading = false;
  String? _errorMessage;
  SearchFilters? _currentFilters;
  final Set<String> _removedRestaurantIds = {}; // Track removed restaurants
  double? _searchCenterLat;
  double? _searchCenterLng;
  String? _nextPageToken; // For pagination
  bool _isLoadingMore = false; // For "Load More" loading state

  List<Restaurant> get restaurants => _filteredRestaurants;
  List<RestaurantWithRouteInfo> get routeRestaurants => _routeRestaurants;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  SearchFilters? get currentFilters => _currentFilters;
  bool get hasResults => _filteredRestaurants.isNotEmpty || _routeRestaurants.isNotEmpty;
  bool get hasMoreResults => _nextPageToken != null;

  bool isRestaurantRemoved(String placeId) => _removedRestaurantIds.contains(placeId);

  void toggleRestaurantRemoved(String placeId) {
    if (_removedRestaurantIds.contains(placeId)) {
      _removedRestaurantIds.remove(placeId);
    } else {
      _removedRestaurantIds.add(placeId);
    }
    notifyListeners();
  }

  Future<void> searchRestaurants(SearchFilters filters) async {
    _isLoading = true;
    _errorMessage = null;
    _currentFilters = filters;
    _nextPageToken = null; // Reset pagination

    // Defer the notification to avoid setState during build
    await Future.microtask(() {});
    notifyListeners();

    try {
      // Get search center coordinates for distance sorting
      final location = await _placesService.getLocationFromFilters(filters);
      if (location != null) {
        _searchCenterLat = location['lat'];
        _searchCenterLng = location['lng'];
      }

      final result = await _placesService.searchRestaurants(filters);
      _restaurants = result.restaurants;
      _filteredRestaurants = List.from(_restaurants);
      _nextPageToken = result.nextPageToken;

      if (_restaurants.isEmpty) {
        _errorMessage = 'No restaurants found for the specified criteria.';
      }
    } catch (e) {
      _errorMessage = 'Failed to search restaurants: ${e.toString()}';
      _restaurants = [];
      _filteredRestaurants = [];
      _nextPageToken = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchRestaurantsAlongRoute(SearchFilters filters) async {
    _isLoading = true;
    _errorMessage = null;
    _currentFilters = filters;
    _routeRestaurants = [];

    // Defer the notification to avoid setState during build
    await Future.microtask(() {});
    notifyListeners();

    try {
      final results = await _placesService.searchRestaurantsAlongRoute(filters);
      _routeRestaurants = results;

      if (_routeRestaurants.isEmpty) {
        _errorMessage = 'No restaurants found along your route.';
      }
    } catch (e) {
      _errorMessage = 'Failed to search restaurants along route: ${e.toString()}';
      _routeRestaurants = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreRestaurants() async {
    if (_nextPageToken == null || _currentFilters == null || _isLoadingMore) {
      return; // No more results to load or already loading
    }

    try {
      _isLoadingMore = true;
      notifyListeners();

      final result = await _placesService.searchRestaurants(
        _currentFilters!,
        pageToken: _nextPageToken,
      );

      // Append new restaurants to existing list
      _restaurants.addAll(result.restaurants);
      _filteredRestaurants = List.from(_restaurants);
      _nextPageToken = result.nextPageToken;

    } catch (e) {
      _setError('Failed to load more restaurants: ${e.toString()}');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Restaurant? getRandomRestaurant() {
    if (_filteredRestaurants.isEmpty) return null;

    // Filter out removed restaurants
    final availableRestaurants = _filteredRestaurants
        .where((r) => !_removedRestaurantIds.contains(r.placeId))
        .toList();

    if (availableRestaurants.isEmpty) return null;

    final random = Random();
    final randomIndex = random.nextInt(availableRestaurants.length);
    return availableRestaurants[randomIndex];
  }

  void showRandomRestaurantOnly() {
    if (_filteredRestaurants.isEmpty) return;

    final randomRestaurant = getRandomRestaurant();
    if (randomRestaurant != null) {
      _filteredRestaurants = [randomRestaurant];
      notifyListeners();
    }
  }

  void applyAdditionalFilters({
    double? minRating,
    List<String>? cuisineTypes,
    PriceRange? priceRange,
    bool? openNowOnly,
  }) {
    _filteredRestaurants = _restaurants.where((restaurant) {
      if (minRating != null && (restaurant.rating ?? 0) < minRating) {
        return false;
      }

      if (cuisineTypes != null && cuisineTypes.isNotEmpty) {
        bool hasCuisineMatch = restaurant.cuisineTypes
            .any((type) => cuisineTypes.contains(type));
        if (!hasCuisineMatch) return false;
      }

      if (priceRange != null && restaurant.priceLevel != null) {
        int? restaurantPriceLevel = _getPriceLevelNumber(restaurant.priceLevel!);
        if (restaurantPriceLevel != null) {
          if (restaurantPriceLevel < priceRange.minLevel ||
              restaurantPriceLevel > priceRange.maxLevel) {
            return false;
          }
        }
      }

      if (openNowOnly == true && !restaurant.isOpenNow) {
        return false;
      }

      return true;
    }).toList();

    notifyListeners();
  }

  int? _getPriceLevelNumber(String priceLevel) {
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

  void sortRestaurants(String sortOption) {
    RestaurantSortOption option;
    switch (sortOption) {
      case 'rating':
        option = RestaurantSortOption.rating;
        break;
      case 'name':
        option = RestaurantSortOption.name;
        break;
      case 'price_low':
        option = RestaurantSortOption.priceAscending;
        break;
      case 'price_high':
        option = RestaurantSortOption.priceDescending;
        break;
      case 'distance':
      default:
        option = RestaurantSortOption.distance;
        break;
    }

    switch (option) {
      case RestaurantSortOption.rating:
        _filteredRestaurants.sort((a, b) {
          final aRating = a.rating ?? 0;
          final bRating = b.rating ?? 0;
          return bRating.compareTo(aRating);
        });
        break;
      case RestaurantSortOption.name:
        _filteredRestaurants.sort((a, b) => a.name.compareTo(b.name));
        break;
      case RestaurantSortOption.priceAscending:
        _filteredRestaurants.sort((a, b) {
          final aPrice = _getPriceLevelNumber(a.priceLevel ?? '\$') ?? 1;
          final bPrice = _getPriceLevelNumber(b.priceLevel ?? '\$') ?? 1;
          return aPrice.compareTo(bPrice);
        });
        break;
      case RestaurantSortOption.priceDescending:
        _filteredRestaurants.sort((a, b) {
          final aPrice = _getPriceLevelNumber(a.priceLevel ?? '\$') ?? 1;
          final bPrice = _getPriceLevelNumber(b.priceLevel ?? '\$') ?? 1;
          return bPrice.compareTo(aPrice);
        });
        break;
      case RestaurantSortOption.distance:
        if (_searchCenterLat != null && _searchCenterLng != null) {
          _filteredRestaurants.sort((a, b) {
            // Calculate distance for restaurant a
            final aDistance = (a.latitude != null && a.longitude != null)
                ? _placesService.calculateDistance(
                    _searchCenterLat!,
                    _searchCenterLng!,
                    a.latitude!,
                    a.longitude!,
                  )
                : double.infinity;

            // Calculate distance for restaurant b
            final bDistance = (b.latitude != null && b.longitude != null)
                ? _placesService.calculateDistance(
                    _searchCenterLat!,
                    _searchCenterLng!,
                    b.latitude!,
                    b.longitude!,
                  )
                : double.infinity;

            return aDistance.compareTo(bDistance);
          });
        }
        break;
    }
    notifyListeners();
  }

  Future<Restaurant?> getRestaurantDetails(String placeId) async {
    try {
      return await _placesService.getRestaurantDetails(placeId);
    } catch (e) {
      // Error getting restaurant details
      return null;
    }
  }

  String getPhotoUrl(String photoReference, {int maxWidth = 400}) {
    return _placesService.getPhotoUrl(photoReference, maxWidth: maxWidth);
  }

  List<String> getSupportedCuisineTypes() {
    return _placesService.getSupportedCuisineTypes();
  }

  String formatCuisineType(String type) {
    return _placesService.formatCuisineType(type);
  }

  void clearResults() {
    _restaurants = [];
    _filteredRestaurants = [];
    _routeRestaurants = [];
    _currentFilters = null;
    _nextPageToken = null;
    _removedRestaurantIds.clear(); // Clear removed restaurants when clearing results
    _clearError();
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}

enum RestaurantSortOption {
  rating,
  name,
  priceAscending,
  priceDescending,
  distance,
}