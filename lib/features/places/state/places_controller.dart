import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/features/places/models/place_model.dart';
import 'package:imara_stay/features/places/models/places_state.dart';
import 'package:imara_stay/features/places/repository/places_repository.dart';

/// PlacesController - Manages Places Near Me state
class PlacesController extends StateNotifier<PlacesNearMeState> {
  final PlacesRepository _repository;

  PlacesController(this._repository) : super(const PlacesNearMeState());

  /// Load places for a location (e.g. from property details)
  Future<void> loadPlacesForLocation({
    required double latitude,
    required double longitude,
  }) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      centerLatitude: latitude,
      centerLongitude: longitude,
    );

    try {
      final places = await _repository.fetchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        category: state.selectedCategory,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load places using user's current location
  Future<void> loadPlacesFromUserLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final position = await _repository.getCurrentLocation();

      if (position == null) {
        // Fallback to Nairobi center if permission denied
        await loadPlacesForLocation(
          latitude: -1.2620,
          longitude: 36.8020,
        );
        return;
      }

      state = state.copyWith(
        userLatitude: position.latitude,
        userLongitude: position.longitude,
        centerLatitude: position.latitude,
        centerLongitude: position.longitude,
      );

      final places = await _repository.fetchNearbyPlaces(
        latitude: position.latitude,
        longitude: position.longitude,
        category: state.selectedCategory,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
      );

      state = state.copyWith(
        places: places,
        isLoading: false,
      );
    } catch (e) {
      // Fallback to Nairobi center
      await loadPlacesForLocation(
        latitude: -1.2620,
        longitude: 36.8020,
      );
    }
  }

  /// Select a category filter
  void selectCategory(PlaceCategory? category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Update search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Refresh places with current filters
  Future<void> refresh() async {
    final lat = state.centerLatitude ?? state.userLatitude ?? -1.2620;
    final lng = state.centerLongitude ?? state.userLongitude ?? 36.8020;
    await loadPlacesForLocation(latitude: lat, longitude: lng);
  }
}

final placesRepositoryProvider =
    Provider<PlacesRepository>((ref) => PlacesRepository());

final placesControllerProvider =
    StateNotifierProvider<PlacesController, PlacesNearMeState>((ref) {
  return PlacesController(ref.watch(placesRepositoryProvider));
});
