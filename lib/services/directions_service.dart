import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class DirectionsService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions';
  static const String _apiKey = 'AIzaSyCgoC5_2Ap1P1qJptgZvq8vKaa3JEgBVqc'; // Same API key

  /// Get route from origin to destination
  Future<RouteInfo?> getRoute(
    double originLat,
    double originLng,
    String destination,
  ) async {
    try {
      final params = {
        'origin': '$originLat,$originLng',
        'destination': destination,
        'key': _apiKey,
      };

      final url = Uri.parse('$_baseUrl/json').replace(queryParameters: params);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'] as String;

          // Decode polyline to get coordinates
          final PolylinePoints polylinePointsDecoder = PolylinePoints();
          final List<PointLatLng> decodedPoints = polylinePointsDecoder.decodePolyline(polylinePoints);

          // Convert to our coordinate format
          final List<RoutePoint> routePoints = decodedPoints
              .map((point) => RoutePoint(lat: point.latitude, lng: point.longitude))
              .toList();

          final leg = route['legs'][0];
          final distanceMeters = leg['distance']['value'];
          final durationSeconds = leg['duration']['value'];

          return RouteInfo(
            points: routePoints,
            distanceMeters: distanceMeters,
            durationSeconds: durationSeconds,
            polyline: polylinePoints,
          );
        }
      }
      return null;
    } catch (e) {
      print('Error getting route: $e');
      return null;
    }
  }

  /// Sample points along the route at regular intervals
  /// Returns points spaced approximately [intervalMeters] apart
  List<RoutePoint> sampleRoutePoints(List<RoutePoint> route, double intervalMeters) {
    if (route.isEmpty) return [];

    final List<RoutePoint> sampledPoints = [route.first]; // Always include start
    double accumulatedDistance = 0;
    double targetDistance = intervalMeters;

    for (int i = 1; i < route.length; i++) {
      final prev = route[i - 1];
      final current = route[i];

      final segmentDistance = _calculateDistance(
        prev.lat, prev.lng,
        current.lat, current.lng,
      );

      accumulatedDistance += segmentDistance;

      if (accumulatedDistance >= targetDistance) {
        sampledPoints.add(current);
        targetDistance += intervalMeters;
      }
    }

    // Always include the end point
    if (sampledPoints.last != route.last) {
      sampledPoints.add(route.last);
    }

    return sampledPoints;
  }

  /// Calculate distance from a point to the nearest point on the route
  /// Returns the minimum distance in meters
  double distanceFromRoute(double lat, double lng, List<RoutePoint> route) {
    if (route.isEmpty) return double.infinity;

    double minDistance = double.infinity;

    for (int i = 0; i < route.length - 1; i++) {
      final point1 = route[i];
      final point2 = route[i + 1];

      final distance = _distanceToLineSegment(
        lat, lng,
        point1.lat, point1.lng,
        point2.lat, point2.lng,
      );

      if (distance < minDistance) {
        minDistance = distance;
      }
    }

    return minDistance;
  }

  /// Calculate distance from a point to a line segment
  /// Uses approximation suitable for short distances
  double _distanceToLineSegment(
    double px, double py, // Point (lat, lon)
    double x1, double y1, // Line segment start (lat, lon)
    double x2, double y2, // Line segment end (lat, lon)
  ) {
    // If line segment is actually a point
    final segmentLength = _calculateDistance(x1, y1, x2, y2);
    if (segmentLength < 1) { // Less than 1 meter
      return _calculateDistance(px, py, x1, y1);
    }

    // Convert to radians for calculations
    final lat1 = _toRadians(x1);
    final lon1 = _toRadians(y1);
    final lat2 = _toRadians(x2);
    final lon2 = _toRadians(y2);
    final latP = _toRadians(px);
    final lonP = _toRadians(py);

    // Use simple Cartesian approximation for short distances
    // Convert to meters using average latitude
    final avgLat = (x1 + x2) / 2;
    final metersPerDegreeLat = 111320.0;
    final metersPerDegreeLon = 111320.0 * cos(_toRadians(avgLat));

    // Convert to local Cartesian coordinates (meters)
    final p1x = 0.0;
    final p1y = 0.0;
    final p2x = (y2 - y1) * metersPerDegreeLon;
    final p2y = (x2 - x1) * metersPerDegreeLat;
    final ppx = (py - y1) * metersPerDegreeLon;
    final ppy = (px - x1) * metersPerDegreeLat;

    // Calculate projection parameter
    final lengthSquared = p2x * p2x + p2y * p2y;
    final t = max(0.0, min(1.0, (ppx * p2x + ppy * p2y) / lengthSquared));

    // Calculate closest point on line segment
    final projectionX = p1x + t * p2x;
    final projectionY = p1y + t * p2y;

    // Calculate distance from point to projection
    final dx = ppx - projectionX;
    final dy = ppy - projectionY;
    return sqrt(dx * dx + dy * dy);
  }

  /// Haversine formula for distance calculation
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

  /// Find the position of a restaurant along the route
  /// Returns a value between 0.0 (start) and 1.0 (end)
  double getPositionAlongRoute(
    double restaurantLat,
    double restaurantLng,
    List<RoutePoint> route,
  ) {
    if (route.isEmpty) return 0.0;

    double minDistance = double.infinity;
    int closestSegmentIndex = 0;

    // Find the closest segment
    for (int i = 0; i < route.length - 1; i++) {
      final distance = _distanceToLineSegment(
        restaurantLat, restaurantLng,
        route[i].lat, route[i].lng,
        route[i + 1].lat, route[i + 1].lng,
      );

      if (distance < minDistance) {
        minDistance = distance;
        closestSegmentIndex = i;
      }
    }

    // Calculate accumulated distance to the closest segment
    double totalDistance = 0;
    double distanceToSegment = 0;

    for (int i = 0; i < route.length - 1; i++) {
      final segmentDist = _calculateDistance(
        route[i].lat, route[i].lng,
        route[i + 1].lat, route[i + 1].lng,
      );

      if (i < closestSegmentIndex) {
        distanceToSegment += segmentDist;
      }

      totalDistance += segmentDist;
    }

    if (totalDistance == 0) return 0.0;
    return distanceToSegment / totalDistance;
  }
}

class RouteInfo {
  final List<RoutePoint> points;
  final int distanceMeters;
  final int durationSeconds;
  final String polyline;

  RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polyline,
  });

  double get distanceMiles => distanceMeters / 1609.34;
  double get durationHours => durationSeconds / 3600.0;
}

class RoutePoint {
  final double lat;
  final double lng;

  RoutePoint({required this.lat, required this.lng});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutePoint &&
          runtimeType == other.runtimeType &&
          lat == other.lat &&
          lng == other.lng;

  @override
  int get hashCode => lat.hashCode ^ lng.hashCode;
}
