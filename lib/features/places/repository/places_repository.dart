import 'package:geolocator/geolocator.dart';
import 'package:imara_stay/features/places/models/place_model.dart';

/// PlacesRepository - Data source for nearby places
/// In production: Use Google Places API via Laravel backend
class PlacesRepository {
  /// Get user's current location
  /// Requires location permissions
  Future<Position?> getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          return null;
        }
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
    } catch (e) {
      return null;
    }
  }

  /// Fetch nearby places for a given location
  /// In production: GET /api/places/nearby?lat=X&lng=Y&category=Z
  Future<List<Place>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    PlaceCategory? category,
    String? searchQuery,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - Westlands, Nairobi area
    final mockPlaces = [
      const Place(
        id: '1',
        name: 'Java House',
        category: PlaceCategory.restaurant,
        latitude: -1.2615,
        longitude: 36.8025,
        address: 'Westlands Mall, Nairobi',
        distance: '0.3 km',
        distanceMeters: 300,
        rating: '4.5',
        reviewCount: 120,
        isOpen: true,
      ),
      const Place(
        id: '2',
        name: 'Westgate Mall',
        category: PlaceCategory.shopping,
        latitude: -1.2625,
        longitude: 36.8015,
        address: 'Mwanzi Road, Westlands',
        distance: '0.5 km',
        distanceMeters: 500,
        rating: '4.7',
        reviewCount: 450,
        isOpen: true,
      ),
      const Place(
        id: '3',
        name: 'Shell Petrol Station',
        category: PlaceCategory.gasStation,
        latitude: -1.2605,
        longitude: 36.8035,
        address: 'Waiyaki Way, Westlands',
        distance: '0.2 km',
        distanceMeters: 200,
        isOpen: true,
      ),
      const Place(
        id: '4',
        name: 'Nakumatt Supermarket',
        category: PlaceCategory.supermarket,
        latitude: -1.2630,
        longitude: 36.8005,
        address: 'Westlands, Nairobi',
        distance: '0.4 km',
        distanceMeters: 400,
        rating: '4.2',
        reviewCount: 89,
        isOpen: true,
      ),
      const Place(
        id: '5',
        name: 'Artcaffe',
        category: PlaceCategory.restaurant,
        latitude: -1.2640,
        longitude: 36.8045,
        address: 'Sarit Centre, Westlands',
        distance: '0.6 km',
        distanceMeters: 600,
        rating: '4.8',
        reviewCount: 230,
        isOpen: true,
      ),
      const Place(
        id: '6',
        name: 'KFC Westlands',
        category: PlaceCategory.restaurant,
        latitude: -1.2610,
        longitude: 36.8010,
        address: 'Westlands Mall',
        distance: '0.35 km',
        distanceMeters: 350,
        rating: '4.1',
        reviewCount: 156,
        isOpen: true,
      ),
      const Place(
        id: '7',
        name: 'Equity Bank ATM',
        category: PlaceCategory.bank,
        latitude: -1.2620,
        longitude: 36.8020,
        address: 'Westlands Branch',
        distance: '0.1 km',
        distanceMeters: 100,
        isOpen: true,
      ),
      const Place(
        id: '8',
        name: 'Uhuru Park',
        category: PlaceCategory.park,
        latitude: -1.2900,
        longitude: 36.8200,
        address: 'City Centre, Nairobi',
        distance: '3.2 km',
        distanceMeters: 3200,
        rating: '4.6',
        reviewCount: 890,
        isOpen: true,
      ),
      const Place(
        id: '9',
        name: 'B-club',
        category: PlaceCategory.bar,
        latitude: -1.2650,
        longitude: 36.8050,
        address: 'Westlands, Nairobi',
        distance: '0.7 km',
        distanceMeters: 700,
        rating: '4.3',
        reviewCount: 78,
        isOpen: false,
      ),
    ];

    var result = mockPlaces;

    if (category != null) {
      result = result.where((p) => p.category == category).toList();
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
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
