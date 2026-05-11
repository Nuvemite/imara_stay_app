import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// SavedRepository - Persists favourites and wishlist to local storage
/// Uses SharedPreferences for persistence
class SavedRepository {
  static const String _favouritesKey = 'saved_favourites';
  static const String _wishlistKey = 'saved_wishlist';

  /// Get favourite property IDs
  Future<List<String>> getFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_favouritesKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Get wishlist property IDs
  Future<List<String>> getWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_wishlistKey);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  /// Add or remove from favourites
  Future<void> toggleFavourite(String propertyId) async {
    final ids = await getFavourites();
    if (ids.contains(propertyId)) {
      ids.remove(propertyId);
    } else {
      ids.add(propertyId);
    }
    await _saveFavourites(ids);
  }

  /// Add or remove from wishlist
  Future<void> toggleWishlist(String propertyId) async {
    final ids = await getWishlist();
    if (ids.contains(propertyId)) {
      ids.remove(propertyId);
    } else {
      ids.add(propertyId);
    }
    await _saveWishlist(ids);
  }

  /// Check if property is favourited
  Future<bool> isFavourite(String propertyId) async {
    final ids = await getFavourites();
    return ids.contains(propertyId);
  }

  /// Check if property is wishlisted
  Future<bool> isWishlisted(String propertyId) async {
    final ids = await getWishlist();
    return ids.contains(propertyId);
  }

  Future<void> _saveFavourites(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favouritesKey, jsonEncode(ids));
  }

  Future<void> _saveWishlist(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_wishlistKey, jsonEncode(ids));
  }

  /// Remove from favourites
  Future<void> removeFavourite(String propertyId) async {
    final ids = await getFavourites();
    ids.remove(propertyId);
    await _saveFavourites(ids);
  }

  /// Remove from wishlist
  Future<void> removeWishlist(String propertyId) async {
    final ids = await getWishlist();
    ids.remove(propertyId);
    await _saveWishlist(ids);
  }
}
