import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing_type.dart';
import '../models/listing_wizard_state.dart';
import '../models/property_type.dart';
import '../models/room_type.dart';
import '../repository/listings_repository.dart';

/// Controller for the listing creation wizard (5 wizards × 2 steps)
class ListingWizardController extends StateNotifier<ListingWizardState> {
  ListingWizardController(this._repository)
      : super(const ListingWizardState());

  final ListingsRepository _repository;

  void selectType(ListingType type) {
    state = state.copyWith(
      listingType: type,
      currentStep: 0,
      error: null,
    );
  }

  void nextStep() {
    if (state.currentStep < ListingWizardState.totalSteps - 1) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        error: null,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        error: null,
      );
    }
  }

  void goToStep(int step) {
    if (step >= 0 && step < ListingWizardState.totalSteps) {
      state = state.copyWith(currentStep: step, error: null);
    }
  }

  void updateTypeAndProperty({
    ListingType? listingType,
    PropertyType? propertyType,
    RoomType? roomType,
    String? subcategory,
  }) {
    state = state.copyWith(
      listingType: listingType ?? state.listingType,
      propertyType: propertyType ?? state.propertyType,
      roomType: roomType ?? state.roomType,
      subcategory: subcategory ?? state.subcategory,
      error: null,
    );
  }

  void updateLocation({
    String? address,
    String? city,
    String? country,
    double? latitude,
    double? longitude,
  }) {
    state = state.copyWith(
      address: address ?? state.address,
      city: city ?? state.city,
      country: country ?? state.country,
      latitude: latitude ?? state.latitude,
      longitude: longitude ?? state.longitude,
      error: null,
    );
  }

  void updateCapacity({
    int? maxGuests,
    int? bedrooms,
    int? beds,
    int? bathrooms,
  }) {
    state = state.copyWith(
      maxGuests: maxGuests ?? state.maxGuests,
      bedrooms: bedrooms ?? state.bedrooms,
      beds: beds ?? state.beds,
      bathrooms: bathrooms ?? state.bathrooms,
      error: null,
    );
  }

  void updateAmenities(List<String> amenities) {
    state = state.copyWith(amenities: amenities, error: null);
  }

  void toggleAmenity(String id) {
    final list = List<String>.from(state.amenities);
    if (list.contains(id)) {
      list.remove(id);
    } else {
      list.add(id);
    }
    state = state.copyWith(amenities: list, error: null);
  }

  void setImages(List<String> paths) {
    state = state.copyWith(imagePaths: paths, error: null);
  }

  void addImage(String path) {
    state = state.copyWith(
      imagePaths: [...state.imagePaths, path],
      error: null,
    );
  }

  void removeImage(String path) {
    state = state.copyWith(
      imagePaths: state.imagePaths.where((p) => p != path).toList(),
      error: null,
    );
  }

  void setHasVirtualTour(bool value) {
    state = state.copyWith(hasVirtualTour: value, error: null);
  }

  void updateTitleAndDescription({String? title, String? description}) {
    state = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
      error: null,
    );
  }

  void updatePricing({
    double? pricePerNight,
    double? cleaningFee,
  }) {
    state = state.copyWith(
      pricePerNight: pricePerNight ?? state.pricePerNight,
      cleaningFee: cleaningFee ?? state.cleaningFee,
      error: null,
    );
  }

  void setStatus(ListingStatus status) {
    state = state.copyWith(status: status, error: null);
  }

  void reset() {
    state = const ListingWizardState();
  }

  Future<bool> submit() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.createListing(state);
      if (result != null) {
        state = state.copyWith(isLoading: false);
        return true;
      }
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create listing',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      return false;
    }
  }
}

final listingWizardProvider =
    StateNotifierProvider<ListingWizardController, ListingWizardState>((ref) {
  final repository = ref.watch(listingsRepositoryProvider);
  return ListingWizardController(repository);
});
