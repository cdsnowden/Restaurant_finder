import 'package:flutter/foundation.dart';
import '../models/restaurant_visit.dart';
import '../models/restaurant.dart';
import '../services/visit_service.dart';
import 'package:uuid/uuid.dart';

class VisitsProvider with ChangeNotifier {
  final Uuid _uuid = const Uuid();
  final VisitService _visitService = VisitService();

  List<RestaurantVisit> _visits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RestaurantVisit> get visits => _visits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadUserVisits() async {
    _setLoading(true);
    _clearError();

    try {
      _visits = await _visitService.getVisits();
      print('Loaded ${_visits.length} visits from storage');
      notifyListeners();
    } catch (e) {
      print('Error loading visits: $e');
      _setError('Failed to load visits: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> saveRestaurantVisit({
    required Restaurant restaurant,
    required DateTime visitDate,
    String? orderNotes,
    double? userRating,
    String? userReview,
    List<String>? photosUrls,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      print('VisitsProvider: Creating new visit for ${restaurant.name}');

      final visit = RestaurantVisit(
        id: _uuid.v4(),
        userId: 'local_user',
        restaurant: restaurant,
        visitDate: visitDate,
        orderNotes: orderNotes,
        userRating: userRating,
        userReview: userReview,
        photosUrls: photosUrls ?? [],
      );

      print('VisitsProvider: Visit object created with ID: ${visit.id}');

      // Save to localStorage
      print('VisitsProvider: Calling _visitService.saveVisit()...');
      await _visitService.saveVisit(visit);
      print('VisitsProvider: Visit saved successfully: ${visit.restaurant.name}');

      // Update local memory
      _visits.insert(0, visit);
      print('VisitsProvider: Added to local memory, total visits: ${_visits.length}');

      notifyListeners();
      return true;
    } catch (e, stackTrace) {
      print('VisitsProvider ERROR: $e');
      print('VisitsProvider Stack trace: $stackTrace');
      _setError('Failed to save visit: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateRestaurantVisit(RestaurantVisit visit) async {
    try {
      _clearError();

      print('VisitsProvider: Updating visit ${visit.id} for ${visit.restaurant.name}');
      print('VisitsProvider: Current visits in memory: ${_visits.length}');

      // Save to localStorage
      await _visitService.saveVisit(visit);

      // Update local memory
      final index = _visits.indexWhere((v) => v.id == visit.id);
      print('VisitsProvider: Found visit at index: $index');

      if (index != -1) {
        _visits[index] = visit;
        print('VisitsProvider: Updated visit in memory at index $index');
      } else {
        // If not found, add it (shouldn't happen but just in case)
        _visits.insert(0, visit);
        print('VisitsProvider: Visit not found in memory, added as new');
      }

      notifyListeners();
      print('VisitsProvider: Update complete, total visits: ${_visits.length}');

      return true;
    } catch (e) {
      print('VisitsProvider: ERROR updating visit: $e');
      _setError('Failed to update visit: ${e.toString()}');
      return false;
    }
  }

  Future<bool> deleteRestaurantVisit(String visitId) async {
    try {
      _setLoading(true);
      _clearError();

      // Delete from localStorage
      await _visitService.deleteVisit(visitId);

      // Update local memory
      _visits.removeWhere((visit) => visit.id == visitId);
      notifyListeners();

      return true;
    } catch (e) {
      _setError('Failed to delete visit: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> hasVisitedRestaurant(String placeId) async {
    return _visits.any((visit) => visit.restaurant.placeId == placeId);
  }

  RestaurantVisit? getVisitByPlaceId(String placeId) {
    try {
      return _visits.firstWhere(
        (visit) => visit.restaurant.placeId == placeId,
      );
    } catch (e) {
      return null;
    }
  }

  Future<List<RestaurantVisit>> searchVisits(String searchTerm) async {
    try {
      if (searchTerm.isEmpty) {
        return _visits;
      }

      final searchTermLower = searchTerm.toLowerCase();
      return _visits.where((visit) {
        return visit.restaurant.name.toLowerCase().contains(searchTermLower) ||
               visit.restaurant.address.toLowerCase().contains(searchTermLower) ||
               (visit.orderNotes?.toLowerCase().contains(searchTermLower) ?? false) ||
               (visit.userReview?.toLowerCase().contains(searchTermLower) ?? false);
      }).toList();
    } catch (e) {
      _setError('Failed to search visits: ${e.toString()}');
      return [];
    }
  }

  Future<Map<String, dynamic>> getVisitStats() async {
    try {
      if (_visits.isEmpty) {
        return {
          'totalVisits': 0,
          'averageRating': 0.0,
          'favoritesCuisine': 'None',
        };
      }

      final ratingsWithValues = _visits
          .where((visit) => visit.userRating != null)
          .map((visit) => visit.userRating!)
          .toList();

      final averageRating = ratingsWithValues.isNotEmpty
          ? ratingsWithValues.reduce((a, b) => a + b) / ratingsWithValues.length
          : 0.0;

      final cuisineCount = <String, int>{};
      for (final visit in _visits) {
        for (final cuisine in visit.restaurant.cuisineTypes) {
          cuisineCount[cuisine] = (cuisineCount[cuisine] ?? 0) + 1;
        }
      }

      final favoritesCuisine = cuisineCount.isNotEmpty
          ? cuisineCount.entries
              .reduce((a, b) => a.value > b.value ? a : b)
              .key
          : 'None';

      return {
        'totalVisits': _visits.length,
        'averageRating': averageRating,
        'favoritesCuisine': favoritesCuisine,
      };
    } catch (e) {
      _setError('Failed to get visit stats: ${e.toString()}');
      return {
        'totalVisits': 0,
        'averageRating': 0.0,
        'favoritesCuisine': 'None',
      };
    }
  }

  List<RestaurantVisit> getVisitsByRating(double minRating) {
    return _visits
        .where((visit) => (visit.userRating ?? 0) >= minRating)
        .toList();
  }

  List<RestaurantVisit> getRecentVisits(int count) {
    final sortedVisits = List<RestaurantVisit>.from(_visits);
    sortedVisits.sort((a, b) => b.visitDate.compareTo(a.visitDate));
    return sortedVisits.take(count).toList();
  }

  List<RestaurantVisit> getVisitsByDateRange(DateTime start, DateTime end) {
    return _visits
        .where((visit) =>
            visit.visitDate.isAfter(start) && visit.visitDate.isBefore(end))
        .toList();
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