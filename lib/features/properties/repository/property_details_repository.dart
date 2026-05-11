import 'package:imara_stay/features/properties/models/property_details_model.dart';
import 'package:imara_stay/features/properties/models/property_model.dart';
import 'package:imara_stay/features/saved/repository/saved_repository.dart';

/// PropertyDetailsRepository - Data source for property details
/// In production, this would make API calls to Laravel/PHP backend
/// For now, it returns mock data and uses SavedRepository for favourites/wishlist
class PropertyDetailsRepository {
  final SavedRepository _savedRepository;

  PropertyDetailsRepository([SavedRepository? savedRepository])
      : _savedRepository = savedRepository ?? SavedRepository();
  /// Fetch property details by ID
  /// In production: Future[PropertyDetails] fetchPropertyDetails(String id) async {
  ///   final response = await http.get('$baseUrl/properties/$id');
  ///   return PropertyDetails.fromJson(response.data);
  /// }
  Future<PropertyDetails> fetchPropertyDetails(String propertyId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Mock data - Replace with API call when backend is ready
    return PropertyDetails(
      id: propertyId,
      title: 'Modern Westlands Apartment',
      description:
          'A stylish 2BR apartment in the heart of Westlands. Perfect for business travelers and families. Features modern amenities, secure parking, and walking distance to restaurants and shopping centers.',
      imageUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
      ],
      pricePerNight: 8500,
      location: 'Westlands, Nairobi',
      latitude: -1.2620,
      longitude: 36.8020,
      rating: 4.8,
      reviewsCount: 124,
      category: PropertyCategory.apartments,
      isVerified: true,
      amenities: [
        'Pool',
        'Gym',
        'Fast WiFi',
        'Parking',
        'Air Conditioning',
        'Kitchen',
        'Washing Machine',
        'TV',
      ],
      bedrooms: 2,
      bathrooms: 2,
      guests: 4,
      beds: 2,
      checkInTime: '3:00 PM',
      checkOutTime: '11:00 AM',
      cancellationPolicy: 'Free cancellation for 48 hours',
      host: const HostInfo(
        id: '1',
        name: 'John Kamau',
        avatarUrl: null,
        bio: 'Experienced host with 5+ years. Love sharing Kenyan hospitality!',
        rating: 4.9,
        totalReviews: 45,
        isVerified: true,
        joinedDate: 'Joined in 2020',
        responseTime: 'Responds within 1 hour',
      ),
      hasVirtualTour: true,
      virtualTourUrls: [
        'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
      ],
      allowsNegotiation: true,
      minimumPrice: 7500,
    );
  }

  /// Toggle favourite status - uses SavedRepository for persistence
  Future<bool> toggleFavourite(String propertyId) async {
    await _savedRepository.toggleFavourite(propertyId);
    return true;
  }

  /// Toggle wishlist status - uses SavedRepository for persistence
  Future<bool> toggleWishlist(String propertyId) async {
    await _savedRepository.toggleWishlist(propertyId);
    return true;
  }

  /// Check if property is favourited
  Future<bool> isFavourite(String propertyId) async {
    return _savedRepository.isFavourite(propertyId);
  }

  /// Check if property is wishlisted
  Future<bool> isWishlisted(String propertyId) async {
    return _savedRepository.isWishlisted(propertyId);
  }
}
