enum PropertyCategory {
  apartments('Apartments'),
  villas('Villas'),
  cottages('Cottages'),
  lodges('Lodges'),
  mansions('Mansions');

  final String label;
  const PropertyCategory(this.label);
}

/// Property - Represents a listing in the system
class Property {
  final String id;
  final String title;
  final String description;
  final List<String> imageUrls;
  final double pricePerNight;
  final String location;
  final double rating;
  final int reviewsCount;
  final PropertyCategory category;
  final bool isVerified;
  final List<String> amenities;

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrls,
    required this.pricePerNight,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    required this.category,
    this.isVerified = false,
    this.amenities = const [],
  });

  /// Parse from Laravel API response
  /// Handles: category as object {id, name, slug}, images as [{image_url}] or [url]
  factory Property.fromJson(Map<String, dynamic> json) {
    final imagesRaw = json['images'] ?? json['image_urls'] ?? [];
    final imageList = <String>[];
    if (imagesRaw is List) {
      for (final e in imagesRaw) {
        if (e is Map && e['image_url'] != null) {
          imageList.add(e['image_url'].toString());
        } else if (e is String && e.isNotEmpty) {
          imageList.add(e);
        }
      }
    }

    final categoryRaw = json['category'];
    final categoryStr = categoryRaw is Map
        ? (categoryRaw['slug'] ?? categoryRaw['name'] ?? '').toString()
        : categoryRaw?.toString();

    return Property(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrls: imageList,
      pricePerNight: _parseDouble(json['price_per_night'] ?? json['price']),
      location: json['location'] ?? json['address'] ?? '',
      rating: _parseDouble(json['rating']),
      reviewsCount: json['reviews_count'] ?? 0,
      category: _parseCategory(categoryStr),
      isVerified: json['is_verified'] ?? false,
      amenities: List<String>.from(json['amenities'] ?? []),
    );
  }

  static PropertyCategory _parseCategory(dynamic value) {
    if (value == null || value.toString().isEmpty) {
      return PropertyCategory.apartments;
    }
    final s = value.toString().toLowerCase();
    return PropertyCategory.values.firstWhere(
      (c) => c.name == s || c.label.toLowerCase() == s || (c.name == 'apartments' && s.contains('apartment')),
      orElse: () => PropertyCategory.apartments,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Formatted price for Kenyan context
  String get formattedPrice => 'KES ${pricePerNight.toStringAsFixed(0)}';

  @override
  String toString() => 'Property($title, $location)';
}
