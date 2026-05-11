import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/api/api_client.dart';
import 'package:imara_stay/core/api/api_config.dart';
import 'package:imara_stay/features/properties/models/property_filters.dart';
import 'package:imara_stay/features/properties/models/property_model.dart';

/// PropertyState - State for the property listings
class PropertyState {
  final List<Property> properties;
  final List<Property> filteredProperties;
  final PropertyCategory selectedCategory;
  final bool isLoading;
  final String? searchQuery;
  final PropertyFilters filters;

  // Pagination
  final int currentPage;
  final int itemsPerPage;
  final int totalPages;

  const PropertyState({
    required this.properties,
    required this.filteredProperties,
    required this.selectedCategory,
    this.isLoading = false,
    this.searchQuery,
    this.filters = const PropertyFilters(),
    this.currentPage = 0,
    this.itemsPerPage = 3,
    this.totalPages = 0,
  });

  PropertyState copyWith({
    List<Property>? properties,
    List<Property>? filteredProperties,
    PropertyCategory? selectedCategory,
    bool? isLoading,
    String? searchQuery,
    PropertyFilters? filters,
    int? currentPage,
    int? itemsPerPage,
    int? totalPages,
  }) {
    return PropertyState(
      properties: properties ?? this.properties,
      filteredProperties: filteredProperties ?? this.filteredProperties,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      filters: filters ?? this.filters,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  /// Get paginated properties for current page
  List<Property> get paginatedProperties {
    final startIndex = currentPage * itemsPerPage;
    final endIndex = (startIndex + itemsPerPage).clamp(0, filteredProperties.length);
    if (startIndex >= filteredProperties.length) {
      return [];
    }
    return filteredProperties.sublist(startIndex, endIndex);
  }

  /// Check if there's a next page
  bool get hasNextPage => totalPages > 0 && currentPage < totalPages - 1;

  /// Check if there's a previous page
  bool get hasPreviousPage => currentPage > 0;
}

/// PropertyController - Manages listings fetching and filtering
class PropertyController extends StateNotifier<PropertyState> {
  PropertyController()
    : super(
        const PropertyState(
          properties: [],
          filteredProperties: [],
          selectedCategory: PropertyCategory.apartments,
          isLoading: true,
        ),
      ) {
    if (ApiConfig.useApi) {
      _loadFromApi();
    } else {
      _initMockData();
    }
  }

  /// Load properties from Laravel API
  Future<void> _loadFromApi() async {
    state = state.copyWith(isLoading: true);
    try {
      final client = ApiClient();
      final response = await client.get('/properties', queryParams: {
        'category': state.selectedCategory.name,
        if (state.filters.minPrice != null)
          'min_price': state.filters.minPrice.toString(),
        if (state.filters.maxPrice != null)
          'max_price': state.filters.maxPrice.toString(),
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = data is List ? data : (data['data'] ?? data['properties'] ?? []);
        final properties = (list as List)
            .map((j) => Property.fromJson(j as Map<String, dynamic>))
            .toList();
        state = state.copyWith(
          properties: properties,
          isLoading: false,
        );
        _applyFilters();
      } else {
        state = state.copyWith(isLoading: false);
        throw Exception('Failed to load: ${response.statusCode}');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      rethrow;
    }
  }

  void _initMockData() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    final mockData = [
      Property(
        id: '1',
        title: 'Modern Westlands Apartment',
        description: 'A stylish 2BR apartment in the heart of Westlands.',
        imageUrls: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        ],
        pricePerNight: 8500,
        location: 'Westlands, Nairobi',
        rating: 4.8,
        reviewsCount: 124,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['Pool', 'Gym', 'Fast WiFi', 'Parking'],
      ),
      Property(
        id: '2',
        title: 'Lavington Garden Suite',
        description:
            'Serene environment with lush gardens and maximum security.',
        imageUrls: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        pricePerNight: 12000,
        location: 'Lavington, Nairobi',
        rating: 4.9,
        reviewsCount: 45,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['Garden', 'Security', 'Netflix'],
      ),
      Property(
        id: '3',
        title: 'Coastal Paradise Villa',
        description: 'Luxury 4BR villa with direct beach access in Nyali.',
        imageUrls: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        ],
        pricePerNight: 45000,
        location: 'Nyali, Mombasa',
        rating: 4.7,
        reviewsCount: 89,
        category: PropertyCategory.villas,
        isVerified: true,
        amenities: ['Beach view', 'Pool', 'Chef included', 'AC'],
      ),
      Property(
        id: '4',
        title: 'Naivasha Lakeview Lodge',
        description:
            'Spectacular views of Lake Naivasha with wildlife roaming around.',
        imageUrls: [
          'https://images.unsplash.com/photo-1449156001431-3147895e626e',
        ],
        pricePerNight: 18000,
        location: 'Moi South Lake Rd, Naivasha',
        rating: 4.6,
        reviewsCount: 62,
        category: PropertyCategory.lodges,
        isVerified: true,
        amenities: ['Lake view', 'Safari tours', 'Breakfast included'],
      ),
      Property(
        id: '5',
        title: 'Kilifi Beachfront Cottage',
        description:
            'Cozy and rustic charm right on the white sands of Kilifi.',
        imageUrls: [
          'https://images.unsplash.com/photo-1499793983690-e29da59ef1c2',
        ],
        pricePerNight: 7500,
        location: 'Bofa Beach, Kilifi',
        rating: 4.9,
        reviewsCount: 31,
        category: PropertyCategory.cottages,
        isVerified: false,
        amenities: ['Eco-friendly', 'Solar power', 'Beach access'],
      ),
      // More apartments for pagination demo
      Property(
        id: '6',
        title: 'Karen Executive Apartment',
        description: 'Spacious 3BR apartment in serene Karen neighborhood.',
        imageUrls: [
          'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267',
        ],
        pricePerNight: 15000,
        location: 'Karen, Nairobi',
        rating: 4.7,
        reviewsCount: 78,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['Garden', 'Security', 'WiFi', 'Parking'],
      ),
      Property(
        id: '7',
        title: 'Runda Luxury Apartment',
        description: 'Modern 2BR with stunning city views.',
        imageUrls: [
          'https://images.unsplash.com/photo-1502672260266-1c1ef2d93688',
        ],
        pricePerNight: 18000,
        location: 'Runda, Nairobi',
        rating: 4.9,
        reviewsCount: 92,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['City view', 'Gym', 'Pool', 'AC', 'WiFi'],
      ),
      Property(
        id: '8',
        title: 'Kilimani Studio Apartment',
        description: 'Cozy studio perfect for solo travelers.',
        imageUrls: [
          'https://images.unsplash.com/photo-1613490493576-7fde63acd811',
        ],
        pricePerNight: 6000,
        location: 'Kilimani, Nairobi',
        rating: 4.6,
        reviewsCount: 45,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['WiFi', 'Kitchen', 'TV'],
      ),
      Property(
        id: '9',
        title: 'Westlands Business Apartment',
        description: 'Perfect for business travelers, walking distance to offices.',
        imageUrls: [
          'https://images.unsplash.com/photo-1449156001431-3147895e626e',
        ],
        pricePerNight: 9500,
        location: 'Westlands, Nairobi',
        rating: 4.8,
        reviewsCount: 112,
        category: PropertyCategory.apartments,
        isVerified: true,
        amenities: ['WiFi', 'Workspace', 'Parking', 'AC'],
      ),
    ];

    state = state.copyWith(
      properties: mockData,
      isLoading: false,
    );
    _applyFilters();
  }

  void selectCategory(PropertyCategory category) {
    state = state.copyWith(selectedCategory: category);
    _applyFilters();
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  /// Apply filters (price, amenities, location, rating)
  void applyFilters(PropertyFilters filters) {
    state = state.copyWith(filters: filters, currentPage: 0);
    _applyFilters();
  }

  /// Clear all filters
  void clearFilters() {
    state = state.copyWith(
      filters: const PropertyFilters(),
      currentPage: 0,
    );
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = state.properties.where((p) {
      // Category
      if (p.category != state.selectedCategory) return false;

      // Search
      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
        final q = state.searchQuery!.toLowerCase();
        if (!p.title.toLowerCase().contains(q) &&
            !p.location.toLowerCase().contains(q)) {
          return false;
        }
      }

      // Price range
      if (state.filters.minPrice != null &&
          p.pricePerNight < state.filters.minPrice!) {
        return false;
      }
      if (state.filters.maxPrice != null &&
          p.pricePerNight > state.filters.maxPrice!) {
        return false;
      }

      // Min rating
      if (state.filters.minRating != null &&
          p.rating < state.filters.minRating!) {
        return false;
      }

      // Amenities - property must have ALL selected amenities
      for (final amenity in state.filters.amenities) {
        final hasAmenity = p.amenities.any((a) =>
            a.toLowerCase().contains(amenity.toLowerCase()));
        if (!hasAmenity) return false;
      }

      // Location - property location must match ANY selected location
      if (state.filters.locations.isNotEmpty) {
        final matches = state.filters.locations.any((loc) =>
            p.location.toLowerCase().contains(loc.toLowerCase()));
        if (!matches) return false;
      }

      return true;
    }).toList();

    final totalPages = filtered.isEmpty
        ? 0
        : ((filtered.length + state.itemsPerPage - 1) ~/ state.itemsPerPage);

    state = state.copyWith(
      filteredProperties: filtered,
      currentPage: 0,
      totalPages: totalPages,
    );
  }

  /// Go to next page
  void nextPage() {
    if (state.hasNextPage) {
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  /// Go to previous page
  void previousPage() {
    if (state.hasPreviousPage) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Go to specific page
  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      state = state.copyWith(currentPage: page);
    }
  }
}

/// Property Provider
final propertyProvider =
    StateNotifierProvider<PropertyController, PropertyState>((ref) {
      return PropertyController();
    });
