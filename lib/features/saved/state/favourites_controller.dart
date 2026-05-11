import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/features/saved/repository/saved_repository.dart';

/// FavouritesController - Manages favourite property IDs
class FavouritesController extends StateNotifier<List<String>> {
  final SavedRepository _repository;

  FavouritesController(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.getFavourites();
  }

  Future<void> toggle(String propertyId) async {
    await _repository.toggleFavourite(propertyId);
    state = await _repository.getFavourites();
  }

  Future<void> remove(String propertyId) async {
    await _repository.removeFavourite(propertyId);
    state = await _repository.getFavourites();
  }

  bool contains(String propertyId) => state.contains(propertyId);
}

/// WishlistController - Manages wishlist property IDs
class WishlistController extends StateNotifier<List<String>> {
  final SavedRepository _repository;

  WishlistController(this._repository) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _repository.getWishlist();
  }

  Future<void> toggle(String propertyId) async {
    await _repository.toggleWishlist(propertyId);
    state = await _repository.getWishlist();
  }

  Future<void> remove(String propertyId) async {
    await _repository.removeWishlist(propertyId);
    state = await _repository.getWishlist();
  }

  bool contains(String propertyId) => state.contains(propertyId);
}

final savedRepositoryProvider =
    Provider<SavedRepository>((ref) => SavedRepository());

final favouritesProvider =
    StateNotifierProvider<FavouritesController, List<String>>((ref) {
  return FavouritesController(ref.watch(savedRepositoryProvider));
});

final wishlistProvider =
    StateNotifierProvider<WishlistController, List<String>>((ref) {
  return WishlistController(ref.watch(savedRepositoryProvider));
});
