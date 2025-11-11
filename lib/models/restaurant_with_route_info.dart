import 'restaurant.dart';

/// Restaurant with additional route-specific information
class RestaurantWithRouteInfo {
  final Restaurant restaurant;
  final double distanceFromRouteMeters; // Detour distance
  final double positionAlongRoute; // 0.0 to 1.0
  final double distanceAlongRouteMeters; // How far along the journey

  RestaurantWithRouteInfo({
    required this.restaurant,
    required this.distanceFromRouteMeters,
    required this.positionAlongRoute,
    required this.distanceAlongRouteMeters,
  });

  double get detourMiles => distanceFromRouteMeters / 1609.34;
  double get distanceAlongRouteMiles => distanceAlongRouteMeters / 1609.34;

  /// Estimated detour time in minutes (assuming 30 mph average for detour)
  double get estimatedDetourMinutes {
    final detourMiles = this.detourMiles;
    return (detourMiles / 30.0) * 60.0 * 2; // Round trip
  }
}
