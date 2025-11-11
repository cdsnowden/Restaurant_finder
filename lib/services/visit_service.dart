import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/restaurant_visit.dart';

// Conditional imports for web-only APIs
import 'visit_service_stub.dart'
    if (dart.library.html) 'visit_service_web.dart' as web_storage;

class VisitService {
  static const String _storageKey = 'restaurant_visits';

  Future<List<RestaurantVisit>> getVisits() async {
    try {
      String? visitsJson;

      if (kIsWeb) {
        // For web, use localStorage directly
        try {
          visitsJson = web_storage.getItem(_storageKey);
        } catch (e) {
          // Error accessing localStorage
        }
      } else {
        // For mobile, use SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        visitsJson = prefs.getString(_storageKey);
      }

      if (visitsJson == null || visitsJson.isEmpty) {
        return [];
      }

      final visitsList = json.decode(visitsJson) as List;
      final visits = visitsList.map((json) => RestaurantVisit.fromJson(json)).toList();
      return visits;
    } catch (e) {
      return [];
    }
  }

  Future<void> saveVisit(RestaurantVisit visit) async {
    try {
      final visits = await getVisits();

      final existingIndex = visits.indexWhere((v) => v.id == visit.id);

      if (existingIndex >= 0) {
        visits[existingIndex] = visit;
      } else {
        visits.add(visit);
      }

      final jsonString = json.encode(visits.map((v) {
        try {
          return v.toJson();
        } catch (e) {
          rethrow;
        }
      }).toList());

      if (kIsWeb) {
        // For web, use localStorage directly
        try {
          web_storage.setItem(_storageKey, jsonString);

          // Verify save
          final verification = web_storage.getItem(_storageKey);

          if (verification == null) {
            throw Exception('Verification failed: Data not saved to localStorage');
          }
        } catch (e) {
          rethrow;
        }
      } else {
        // For mobile, use SharedPreferences
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString(_storageKey, jsonString);

        // Verify save
        final verification = prefs.getString(_storageKey);

        if (verification == null) {
          throw Exception('Verification failed: Data not found after save');
        }
      }
    } catch (e) {
      throw Exception('Failed to save visit: $e');
    }
  }

  Future<void> deleteVisit(String visitId) async {
    try {
      final visits = await getVisits();
      visits.removeWhere((visit) => visit.id == visitId);

      final jsonString = json.encode(visits.map((v) => v.toJson()).toList());

      if (kIsWeb) {
        web_storage.setItem(_storageKey, jsonString);
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, jsonString);
      }
    } catch (e) {
      throw Exception('Failed to delete visit');
    }
  }

  Future<RestaurantVisit?> getVisitByRestaurantId(String restaurantId) async {
    final visits = await getVisits();
    try {
      return visits.firstWhere((visit) => visit.restaurant.placeId == restaurantId);
    } catch (e) {
      return null;
    }
  }
}