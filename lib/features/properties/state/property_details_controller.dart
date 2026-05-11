import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/features/properties/models/property_details_state.dart';
import 'package:imara_stay/features/properties/repository/property_details_repository.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';

/// PropertyDetailsController - Manages property details state
/// Think of this as your Redux reducer + thunks combined
/// 
/// StateNotifier[PropertyDetailsState] means:
/// - It holds state of type PropertyDetailsState
/// - It can emit new states
/// - Widgets automatically rebuild when state changes
class PropertyDetailsController extends StateNotifier<PropertyDetailsState> {
  final PropertyDetailsRepository _repository;

  PropertyDetailsController(this._repository)
      : super(const PropertyDetailsState()) {
    // Constructor - starts with initial state
  }

  /// Load property details by ID
  /// This is like a Redux thunk - async action that updates state
  Future<void> loadPropertyDetails(String propertyId) async {
    // Show loading state
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch property details from repository
      final property = await _repository.fetchPropertyDetails(propertyId);

      // Check favourite and wishlist status
      final isFav = await _repository.isFavourite(propertyId);
      final isWish = await _repository.isWishlisted(propertyId);

      // Update state with loaded data
      state = state.copyWith(
        property: property,
        isLoading: false,
        isFavourite: isFav,
        isWishlisted: isWish,
      );
    } catch (e) {
      // Error handling - update state with error
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Toggle favourite status
  /// Updates local state immediately (optimistic update)
  /// Then syncs with backend
  Future<void> toggleFavourite() async {
    if (state.property == null) return;

    // Optimistic update - update UI immediately
    state = state.copyWith(isFavourite: !state.isFavourite);

    try {
      // Sync with backend
      await _repository.toggleFavourite(state.property!.id);
    } catch (e) {
      // Revert on error
      state = state.copyWith(isFavourite: !state.isFavourite);
      // In production, show error message to user
      rethrow;
    }
  }

  /// Toggle wishlist status
  /// Updates local state immediately (optimistic update)
  /// Then syncs with backend
  Future<void> toggleWishlist() async {
    if (state.property == null) return;

    // Optimistic update - update UI immediately
    state = state.copyWith(isWishlisted: !state.isWishlisted);

    try {
      // Sync with backend
      await _repository.toggleWishlist(state.property!.id);
    } catch (e) {
      // Revert on error
      state = state.copyWith(isWishlisted: !state.isWishlisted);
      // In production, show error message to user
      rethrow;
    }
  }

  /// Refresh property details
  /// Useful for pull-to-refresh or after updates
  Future<void> refresh() async {
    if (state.property != null) {
      await loadPropertyDetails(state.property!.id);
    }
  }
}

/// Provider for PropertyDetailsRepository
/// This is a singleton - one instance shared across the app
final propertyDetailsRepositoryProvider =
    Provider<PropertyDetailsRepository>((ref) {
  final savedRepo = ref.watch(savedRepositoryProvider);
  return PropertyDetailsRepository(savedRepo);
});

/// Provider for PropertyDetailsController
/// Takes propertyId as a parameter
/// Each property gets its own controller instance
final propertyDetailsControllerProvider =
    StateNotifierProvider.family<PropertyDetailsController, PropertyDetailsState,
        String>(
  (ref, propertyId) {
    final repository = ref.watch(propertyDetailsRepositoryProvider);
    final controller = PropertyDetailsController(repository);
    // Auto-load property details when controller is created
    controller.loadPropertyDetails(propertyId);
    return controller;
  },
);
