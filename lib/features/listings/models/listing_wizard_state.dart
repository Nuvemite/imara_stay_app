import 'listing_lookups.dart';
import 'listing_type.dart';
import 'property_type.dart';
import 'room_type.dart';

/// State for the listing creation wizard (5 wizards × 2 steps = 10 steps)
class ListingWizardState {
  const ListingWizardState({
    this.listingType = ListingType.home,
    this.currentStep = 0,
    // Wizard 1: Type & property
    this.propertyType,
    this.roomType,
    this.subcategory = '',
    // Wizard 2: Location & capacity
    this.address = '',
    this.city = '',
    this.country = 'Kenya',
    this.latitude,
    this.longitude,
    this.maxGuests,
    this.bedrooms,
    this.beds,
    this.bathrooms,
    // Wizard 3: Amenities & photos
    this.amenities = const [],
    this.imagePaths = const [],
    this.hasVirtualTour = false,
    // Wizard 4: Title & description
    this.title = '',
    this.description = '',
    // Wizard 5: Pricing & publish
    this.pricePerNight = 0,
    this.cleaningFee,
    this.status = ListingStatus.draft,
    // Experience/Service specific
    this.durationHours,
    this.whatsIncluded = '',
    this.serviceDetails = '',
    // Meta
    this.isLoading = false,
    this.error,
  });

  final ListingType listingType;
  final int currentStep;
  final PropertyType? propertyType;
  final RoomType? roomType;
  final String subcategory;
  final String address;
  final String city;
  final String country;
  final double? latitude;
  final double? longitude;
  final int? maxGuests;
  final int? bedrooms;
  final int? beds;
  final int? bathrooms;
  final List<String> amenities;
  final List<String> imagePaths;
  final bool hasVirtualTour;
  final String title;
  final String description;
  final double pricePerNight;
  final double? cleaningFee;
  final ListingStatus status;
  final double? durationHours;
  final String whatsIncluded;
  final String serviceDetails;
  final bool isLoading;
  final String? error;

  static const int totalSteps = 10;

  int get wizardIndex => currentStep ~/ 2;
  int get stepInWizard => currentStep % 2;
  bool get isLastStep => currentStep >= totalSteps - 1;

  bool get canProceedFromStep0 =>
      true; // Type selection - always valid once selected

  bool get canProceedFromStep1 {
    if (listingType == ListingType.home) {
      return propertyType != null && roomType != null;
    }
    return subcategory.trim().isNotEmpty;
  }

  bool get canProceedFromStep2 =>
      address.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      country.trim().isNotEmpty;

  bool get canProceedFromStep3 =>
      (maxGuests ?? 0) > 0 &&
      (bedrooms ?? 0) > 0 &&
      (beds ?? 0) > 0 &&
      (bathrooms ?? 0) > 0;

  bool get canProceedFromStep4 => true; // Amenities optional

  bool get canProceedFromStep5 => imagePaths.length >= 4;

  bool get canProceedFromStep6 => title.trim().length >= 5;

  bool get canProceedFromStep7 => description.trim().length >= 10;

  bool get canProceedFromStep8 => pricePerNight > 0;

  bool get canProceedFromStep9 => true; // Review - always can publish

  bool canProceedFromCurrentStep() {
    switch (currentStep) {
      case 0:
        return canProceedFromStep0;
      case 1:
        return canProceedFromStep1;
      case 2:
        return canProceedFromStep2;
      case 3:
        return canProceedFromStep3;
      case 4:
        return canProceedFromStep4;
      case 5:
        return canProceedFromStep5;
      case 6:
        return canProceedFromStep6;
      case 7:
        return canProceedFromStep7;
      case 8:
        return canProceedFromStep8;
      case 9:
        return canProceedFromStep9;
      default:
        return false;
    }
  }

  String get location => address.isNotEmpty ? '$address, $city, $country' : '';

  ListingWizardState copyWith({
    ListingType? listingType,
    int? currentStep,
    PropertyType? propertyType,
    RoomType? roomType,
    String? subcategory,
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
    List<String>? amenities,
    List<String>? imagePaths,
    bool? hasVirtualTour,
    String? title,
    String? description,
    double? pricePerNight,
    double? cleaningFee,
    ListingStatus? status,
    double? durationHours,
    String? whatsIncluded,
    String? serviceDetails,
    bool? isLoading,
    String? error,
  }) {
    return ListingWizardState(
      listingType: listingType ?? this.listingType,
      currentStep: currentStep ?? this.currentStep,
      propertyType: propertyType ?? this.propertyType,
      roomType: roomType ?? this.roomType,
      subcategory: subcategory ?? this.subcategory,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxGuests: maxGuests ?? this.maxGuests,
      bedrooms: bedrooms ?? this.bedrooms,
      beds: beds ?? this.beds,
      bathrooms: bathrooms ?? this.bathrooms,
      amenities: amenities ?? this.amenities,
      imagePaths: imagePaths ?? this.imagePaths,
      hasVirtualTour: hasVirtualTour ?? this.hasVirtualTour,
      title: title ?? this.title,
      description: description ?? this.description,
      pricePerNight: pricePerNight ?? this.pricePerNight,
      cleaningFee: cleaningFee ?? this.cleaningFee,
      status: status ?? this.status,
      durationHours: durationHours ?? this.durationHours,
      whatsIncluded: whatsIncluded ?? this.whatsIncluded,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Build API payload. Uses [lookups] to resolve slugs to IDs when available.
  Map<String, dynamic> toApiPayload([ListingLookups? lookups]) {
    final listingTypeId = lookups?.listingTypeIdBySlug(listingType.name) ?? _fallbackListingTypeId;
    final propertyTypeId = lookups?.propertyTypeIdBySlug(propertyType?.name ?? '') ?? _fallbackPropertyTypeId;
    final roomTypeId = lookups?.roomTypeIdBySlug((roomType?.name ?? '').toLowerCase()) ?? _fallbackRoomTypeId;
    final amenityIds = lookups != null && lookups.amenities.isNotEmpty
        ? lookups.amenityIdsBySlugs(amenities)
        : <int>[];

    final payload = <String, dynamic>{
      'listing_type_id': listingTypeId,
      'is_active': status == ListingStatus.published,
      'title': title,
      'description': description,
      'address_line_1': address,
      'location': location,
      'city': city,
      'country': country,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'price_per_night': pricePerNight,
      if (cleaningFee != null && cleaningFee! > 0) 'cleaning_fee': cleaningFee,
      'has_virtual_tour': hasVirtualTour,
      'bedrooms': bedrooms ?? 0,
      'bathrooms': bathrooms ?? 0,
      'beds': beds ?? 0,
      'max_guests': maxGuests ?? 0,
    };

    payload['amenities'] = amenityIds.isNotEmpty ? amenityIds : <int>[];

    switch (listingType) {
      case ListingType.home:
        if (propertyTypeId != null) payload['property_type_id'] = propertyTypeId;
        if (roomTypeId != null) payload['room_type_id'] = roomTypeId;
        break;
      case ListingType.experience:
        payload['subcategory'] = subcategory;
        payload['duration_hours'] = durationHours ?? 0;
        payload['whats_included'] = whatsIncluded;
        break;
      case ListingType.service:
        payload['subcategory'] = subcategory;
        payload['service_details'] = serviceDetails;
        break;
    }
    return payload;
  }

  int get _fallbackListingTypeId {
    switch (listingType) {
      case ListingType.home:
        return 1;
      case ListingType.experience:
        return 2;
      case ListingType.service:
        return 3;
    }
  }

  int? get _fallbackPropertyTypeId {
    if (propertyType == null) return null;
    return propertyType!.index + 1;
  }

  int? get _fallbackRoomTypeId {
    if (roomType == null) return null;
    return roomType!.index + 1;
  }
}

enum ListingStatus { draft, published }
