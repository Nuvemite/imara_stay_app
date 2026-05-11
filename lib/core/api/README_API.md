# API Integration - How to Connect Repositories

## Example: Property Listings

Your Laravel API might have:
- `GET /api/properties` - List properties (with query params for filters)
- `GET /api/properties/{id}` - Property details

### In PropertyController (or a new PropertyApiRepository):

```dart
import 'package:imara_stay/core/api/api_client.dart';

// Replace _initMockData() with:
Future<void> _loadFromApi() async {
  state = state.copyWith(isLoading: true);
  
  try {
    final client = ApiClient(); // Add token from auth when ready
    final response = await client.get('/properties', queryParams: {
      'category': state.selectedCategory.name,
      if (state.filters.minPrice != null) 'min_price': state.filters.minPrice.toString(),
      if (state.filters.maxPrice != null) 'max_price': state.filters.maxPrice.toString(),
    });
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final properties = (data['data'] as List)
          .map((j) => Property.fromJson(j as Map<String, dynamic>))
          .toList();
      state = state.copyWith(
        properties: properties,
        filteredProperties: properties,
        isLoading: false,
      );
    } else {
      throw Exception('Failed to load: ${response.statusCode}');
    }
  } catch (e) {
    state = state.copyWith(isLoading: false);
    rethrow;
  }
}
```

### Add fromJson to Property model:

```dart
factory Property.fromJson(Map<String, dynamic> json) {
  return Property(
    id: json['id'].toString(),
    title: json['title'],
    description: json['description'] ?? '',
    imageUrls: List<String>.from(json['images'] ?? [json['image'] ?? []]),
    pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
    location: json['location'] ?? '',
    rating: (json['rating'] ?? 0).toDouble(),
    reviewsCount: json['reviews_count'] ?? 0,
    category: PropertyCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => PropertyCategory.apartments,
    ),
    isVerified: json['is_verified'] ?? false,
    amenities: List<String>.from(json['amenities'] ?? []),
  );
}
```

## Run with custom base URL

```bash
# For physical device (replace with your IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api

# For iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api
```
