import 'property_model.dart';

/// Extended property details model
/// Contains additional information shown on property details screen
class PropertyDetails {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final double pricePerNight;
  final String location;
  final double latitude;
  final double longitude;
  final double rating;
  final int reviewsCount;
  final PropertyCategory category;
  final bool isVerified;
  final List<String> amenities;
  
  // Additional details
  final int bedrooms;
  final int bathrooms;
  final int guests;
  final int beds;
  final String checkInTime;
  final String checkOutTime;
  final String cancellationPolicy;
  
  // Host information
  final HostInfo host;
  
  // Virtual tour
  final bool hasVirtualTour;
  final List<String>? virtualTourUrls; // 360° images or Matterport URLs
  
  // Price negotiation
  final bool allowsNegotiation;
  final double? minimumPrice; // Minimum negotiable price
  
  const PropertyDetails({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.pricePerNight,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    this.isVerified = false,
    this.amenities = const [],
    required this.bedrooms,
    required this.bathrooms,
    required this.guests,
    required this.beds,
    required this.checkInTime,
    required this.checkOutTime,
    required this.cancellationPolicy,
    required this.host,
    this.hasVirtualTour = false,
    this.virtualTourUrls,
    this.allowsNegotiation = false,
    this.minimumPrice,
  });

  /// Formatted price for Kenyan context
  String get formattedPrice => 'KES ${pricePerNight.toStringAsFixed(0)}';
  
  /// Formatted minimum price if negotiation allowed
  String? get formattedMinimumPrice => 
      minimumPrice != null ? 'KES ${minimumPrice!.toStringAsFixed(0)}' : null;
}

/// Host information
class HostInfo {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final double rating;
  final int totalReviews;
  final bool isVerified;
  final String joinedDate; // e.g., "Joined in 2023"
  final String responseTime; // e.g., "Responds within 1 hour"
  
  const HostInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    required this.rating,
    required this.totalReviews,
    this.isVerified = false,
    required this.joinedDate,
    required this.responseTime,
  });
}
