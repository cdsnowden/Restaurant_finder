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
          print('Web localStorage check for key "$_storageKey": ${visitsJson != null ? "data found (${visitsJson.length} chars)" : "no data"}');

          // Debug: List all localStorage keys
          final keys = web_storage.getAllKeys();
          print('All localStorage keys: ${keys.join(", ")}');
        } catch (e) {
          print('Error accessing localStorage: $e');
        }
      } else {
        // For mobile, use SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        visitsJson = prefs.getString(_storageKey);
        print('Mobile SharedPreferences: ${visitsJson != null ? "data found" : "no data"}');
      }

      if (visitsJson == null || visitsJson.isEmpty) {
        print('No visits found in storage');
        return [];
      }

      final visitsList = json.decode(visitsJson) as List;
      final visits = visitsList.map((json) => RestaurantVisit.fromJson(json)).toList();
      print('Successfully loaded ${visits.length} visits');
      return visits;
    } catch (e, stackTrace) {
      print('Error loading visits: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> saveVisit(RestaurantVisit visit) async {
    try {
      print('===== VisitService.saveVisit START =====');
      print('Visit ID: ${visit.id}');
      print('Restaurant: ${visit.restaurant.name}');
      print('Platform: ${kIsWeb ? "WEB" : "MOBILE"}');

      final visits = await getVisits();
      print('Current visits count: ${visits.length}');

      final existingIndex = visits.indexWhere((v) => v.id == visit.id);

      if (existingIndex >= 0) {
        visits[existingIndex] = visit;
        print('Updated existing visit at index $existingIndex');
      } else {
        visits.add(visit);
        print('Added new visit, total now: ${visits.length}');
      }

      print('Converting visits to JSON...');
      final jsonString = json.encode(visits.map((v) {
        try {
          return v.toJson();
        } catch (e) {
          print('Error converting visit to JSON: $e');
          rethrow;
        }
      }).toList());

      print('JSON string length: ${jsonString.length}');

      if (kIsWeb) {
        // For web, use localStorage directly
        print('Platform is WEB - using localStorage');
        try {
          print('Attempting localStorage write...');
          web_storage.setItem(_storageKey, jsonString);
          print('localStorage write completed');

          // Verify save
          print('Verifying save...');
          final verification = web_storage.getItem(_storageKey);
          print('Verification result: ${verification != null ? "SUCCESS (${verification.length} chars)" : "FAILED - null returned"}');

          if (verification == null) {
            throw Exception('Verification failed: Data not saved to localStorage');
          }

          print('===== VisitService.saveVisit SUCCESS (WEB) =====');
        } catch (e) {
          print('ERROR in localStorage operations: $e');
          rethrow;
        }
      } else {
        // For mobile, use SharedPreferences
        print('Platform is MOBILE - using SharedPreferences');
        final prefs = await SharedPreferences.getInstance();

        print('Attempting to save to SharedPreferences...');
        final success = await prefs.setString(_storageKey, jsonString);

        print('Save result: ${success ? "SUCCESS" : "FAILED"}');

        // Verify save
        final verification = prefs.getString(_storageKey);
        print('Verification: Data ${verification != null ? "EXISTS (${verification.length} chars)" : "DOES NOT EXIST"} after save');

        if (verification == null) {
          throw Exception('Verification failed: Data not found after save');
        }

        print('===== VisitService.saveVisit SUCCESS (MOBILE) =====');
      }
    } catch (e, stackTrace) {
      print('===== VisitService.saveVisit FAILED =====');
      print('ERROR: $e');
      print('Stack trace: $stackTrace');
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
        print('Deleted visit from web localStorage');
      } else {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_storageKey, jsonString);
        print('Deleted visit from mobile storage');
      }
    } catch (e) {
      print('Error deleting visit: $e');
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