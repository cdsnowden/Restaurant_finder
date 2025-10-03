import 'restaurant.dart';

class RestaurantVisit {
  final String id;
  final String userId;
  final Restaurant restaurant;
  final DateTime visitDate;
  final String? orderNotes;
  final double? userRating;
  final String? userReview;
  final List<String> photosUrls;

  RestaurantVisit({
    required this.id,
    required this.userId,
    required this.restaurant,
    required this.visitDate,
    this.orderNotes,
    this.userRating,
    this.userReview,
    this.photosUrls = const [],
  });

  factory RestaurantVisit.fromJson(Map<String, dynamic> json) {
    return RestaurantVisit(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      restaurant: Restaurant.fromJson(json['restaurant']),
      visitDate: DateTime.parse(json['visit_date']),
      orderNotes: json['order_notes'],
      userRating: json['user_rating']?.toDouble(),
      userReview: json['user_review'],
      photosUrls: List<String>.from(json['photos_urls'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'restaurant': restaurant.toJson(),
      'visit_date': visitDate.toIso8601String(),
      'order_notes': orderNotes,
      'user_rating': userRating,
      'user_review': userReview,
      'photos_urls': photosUrls,
    };
  }

  RestaurantVisit copyWith({
    String? id,
    String? userId,
    Restaurant? restaurant,
    DateTime? visitDate,
    String? orderNotes,
    double? userRating,
    String? userReview,
    List<String>? photosUrls,
  }) {
    return RestaurantVisit(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurant: restaurant ?? this.restaurant,
      visitDate: visitDate ?? this.visitDate,
      orderNotes: orderNotes ?? this.orderNotes,
      userRating: userRating ?? this.userRating,
      userReview: userReview ?? this.userReview,
      photosUrls: photosUrls ?? this.photosUrls,
    );
  }
}