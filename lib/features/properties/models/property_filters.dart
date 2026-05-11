/// Property filters - applied to listings
class PropertyFilters {
  final double? minPrice;
  final double? maxPrice;
  final Set<String> amenities;
  final Set<String> locations;
  final double? minRating;

  const PropertyFilters({
    this.minPrice,
    this.maxPrice,
    this.amenities = const {},
    this.locations = const {},
    this.minRating,
  });

  PropertyFilters copyWith({
    double? minPrice,
    double? maxPrice,
    Set<String>? amenities,
    Set<String>? locations,
    double? minRating,
  }) {
    return PropertyFilters(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      amenities: amenities ?? this.amenities,
      locations: locations ?? this.locations,
      minRating: minRating ?? this.minRating,
    );
  }

  /// Check if any filter is active
  bool get hasActiveFilters =>
      minPrice != null ||
      maxPrice != null ||
      amenities.isNotEmpty ||
      locations.isNotEmpty ||
      minRating != null;

  /// Count of active filters
  int get activeFilterCount {
    int count = 0;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    count += amenities.length;
    count += locations.length;
    if (minRating != null) count++;
    return count;
  }

  /// Reset all filters
  PropertyFilters clear() => const PropertyFilters();
}

/// Common amenity options for filter chips
const List<String> filterAmenityOptions = [
  'Pool',
  'Gym',
  'WiFi',
  'Parking',
  'Air Conditioning',
  'Kitchen',
  'Garden',
  'Security',
  'Beach view',
  'Breakfast included',
];

/// Common location options (from mock data)
const List<String> filterLocationOptions = [
  'Nairobi',
  'Westlands',
  'Lavington',
  'Karen',
  'Runda',
  'Kilimani',
  'Mombasa',
  'Nyali',
  'Naivasha',
  'Kilifi',
];
