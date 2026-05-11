import 'package:imara_stay/features/properties/models/property_details_model.dart';

/// PropertyDetailsState - State for property details screen
/// This is immutable - every change creates a new instance
/// (Like Redux state, but enforced by the language)
class PropertyDetailsState {
  final PropertyDetails? property;
  final bool isLoading;
  final String? error;
  final bool isFavourite;
  final bool isWishlisted;

  const PropertyDetailsState({
    this.property,
    this.isLoading = false,
    this.error,
    this.isFavourite = false,
    this.isWishlisted = false,
  });

  /// copyWith pattern - this is how you "update" immutable objects
  /// In React/Redux, you'd do { ...state, isLoading: true }
  /// In Dart, we do state.copyWith(isLoading: true)
  PropertyDetailsState copyWith({
    PropertyDetails? property,
    bool? isLoading,
    String? error,
    bool? isFavourite,
    bool? isWishlisted,
  }) {
    return PropertyDetailsState(
      property: property ?? this.property,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isFavourite: isFavourite ?? this.isFavourite,
      isWishlisted: isWishlisted ?? this.isWishlisted,
    );
  }

  /// Helper getters for UI logic
  bool get hasProperty => property != null;
  bool get hasError => error != null;
  bool get isEmpty => property == null && !isLoading && error == null;

  @override
  String toString() {
    return 'PropertyDetailsState(property: ${property?.id}, loading: $isLoading, error: $error, favourite: $isFavourite)';
  }
}
