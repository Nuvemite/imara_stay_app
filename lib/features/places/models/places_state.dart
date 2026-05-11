import 'package:imara_stay/features/places/models/place_model.dart';

/// PlacesNearMeState - State for Places Near Me screen
class PlacesNearMeState {
  final List<Place> places;
  final PlaceCategory? selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final String? error;
  final double? userLatitude;
  final double? userLongitude;
  final double? centerLatitude;
  final double? centerLongitude;

  const PlacesNearMeState({
    this.places = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.isLoading = false,
    this.error,
    this.userLatitude,
    this.userLongitude,
    this.centerLatitude,
    this.centerLongitude,
  });

  static const _omit = Object();

  PlacesNearMeState copyWith({
    List<Place>? places,
    Object? selectedCategory = _omit,
    String? searchQuery,
    bool? isLoading,
    String? error,
    double? userLatitude,
    double? userLongitude,
    double? centerLatitude,
    double? centerLongitude,
  }) {
    return PlacesNearMeState(
      places: places ?? this.places,
      selectedCategory: selectedCategory == _omit ? this.selectedCategory : selectedCategory as PlaceCategory?,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userLatitude: userLatitude ?? this.userLatitude,
      userLongitude: userLongitude ?? this.userLongitude,
      centerLatitude: centerLatitude ?? this.centerLatitude,
      centerLongitude: centerLongitude ?? this.centerLongitude,
    );
  }

  /// Filtered places based on category and search
  List<Place> get filteredPlaces {
    var result = places;

    if (selectedCategory != null) {
      result = result.where((p) => p.category == selectedCategory).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      result = result
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.label.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }
}
