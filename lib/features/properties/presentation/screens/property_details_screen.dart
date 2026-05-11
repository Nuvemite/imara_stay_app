import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/presentation/widgets/image_carousel.dart';
import 'package:imara_stay/features/properties/presentation/widgets/host_card.dart';
import 'package:imara_stay/features/properties/presentation/widgets/amenities_grid.dart';
import 'package:imara_stay/features/properties/presentation/widgets/virtual_tour_button.dart';
import 'package:imara_stay/features/properties/presentation/widgets/price_negotiation_button.dart';
import 'package:imara_stay/features/properties/presentation/widgets/reviews_preview.dart';
import 'package:imara_stay/features/properties/presentation/widgets/places_nearby_preview.dart';
import 'package:imara_stay/features/properties/presentation/screens/virtual_tour_screen.dart';
import 'package:imara_stay/features/places/presentation/screens/places_near_me_screen.dart';
import 'package:imara_stay/features/properties/state/property_details_controller.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';

/// Property Details Screen
/// Shows comprehensive information about a property
/// This is a "smart" widget - it reads state and dispatches actions
///
/// In React terms: const PropertyDetailsScreen = ({ propertyId }) => {
///   const dispatch = useDispatch();
///   const state = useSelector(...);
///   ...
/// }
class PropertyDetailsScreen extends ConsumerWidget {
  final String propertyId;

  const PropertyDetailsScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the property details state
    final state = ref.watch(propertyDetailsControllerProvider(propertyId));
    final controller = ref.read(propertyDetailsControllerProvider(propertyId).notifier);
    final favouriteIds = ref.watch(favouritesProvider);
    final favouritesController = ref.read(favouritesProvider.notifier);

    // Show loading state
    if (state.isLoading && state.property == null) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          backgroundColor: AppTheme.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show error state
    if (state.hasError && state.property == null) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          backgroundColor: AppTheme.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading property: ${state.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show empty state (shouldn't happen, but handle it)
    if (state.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.white,
        appBar: AppBar(
          backgroundColor: AppTheme.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(
          child: Text('Property not found'),
        ),
      );
    }

    // Show property details
    final property = state.property!;

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              favouriteIds.contains(propertyId) ? Icons.favorite : Icons.favorite_border,
              color: favouriteIds.contains(propertyId) ? AppTheme.primaryRed : AppTheme.darkText,
            ),
            onPressed: () => favouritesController.toggle(propertyId),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: AppTheme.darkText),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share functionality coming soon!')),
              );
            },
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Image Carousel Section
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: ImageCarousel(images: property.imageUrls),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and Location
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              property.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: AppTheme.greyText,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    property.location,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: AppTheme.greyText),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${property.rating}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${property.reviewsCount})',
                              style: const TextStyle(
                                color: AppTheme.greyText,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Property Info Cards
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.bed,
                          label: '${property.bedrooms} Bedrooms',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.bathtub,
                          label: '${property.bathrooms} Bathrooms',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          icon: Icons.people,
                          label: '${property.guests} Guests',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Price Section
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                property.formattedPrice,
                                style: Theme.of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      color: AppTheme.primaryRed,
                                      fontSize: 28,
                                    ),
                              ),
                              Text(
                                'per night',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppTheme.greyText),
                              ),
                            ],
                          ),
                        ),
                        if (property.allowsNegotiation)
                          Flexible(
                            fit: FlexFit.loose,
                            child: Padding(
                              padding: const EdgeInsets.only(left: AppSpacing.md),
                              child: PriceNegotiationButton(
                                property: property,
                                onTap: () {
                                  // TODO: Navigate to negotiation screen
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Price negotiation coming soon!'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Virtual Tour Button
                  if (property.hasVirtualTour)
                    VirtualTourButton(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => VirtualTourScreen(
                              tourUrls: property.virtualTourUrls ?? [],
                            ),
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: AppSpacing.xl),

                  // Description
                  Text(
                    'About this place',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    property.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Amenities
                  Text(
                    'What this place offers',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AmenitiesGrid(amenities: property.amenities),

                  const SizedBox(height: AppSpacing.xl),

                  // Check-in/Check-out
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.lightGrey),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildCheckInfo(
                          context,
                          label: 'Check-in',
                          time: property.checkInTime,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.lightGrey,
                        ),
                        _buildCheckInfo(
                          context,
                          label: 'Check-out',
                          time: property.checkOutTime,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Host Card
                  HostCard(host: property.host),

                  const SizedBox(height: AppSpacing.xl),

                  // Reviews Preview
                  ReviewsPreview(
                    propertyId: property.id,
                    rating: property.rating,
                    reviewsCount: property.reviewsCount,
                    onViewAll: () {
                      // TODO: Navigate to full reviews screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reviews screen coming soon!')),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Places Nearby Preview
                  PlacesNearbyPreview(
                    propertyId: property.id,
                    latitude: property.latitude,
                    longitude: property.longitude,
                    onViewAll: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PlacesNearMeScreen(
                            initialLatitude: property.latitude,
                            initialLongitude: property.longitude,
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Book Now Button
                  ElevatedButton(
                    onPressed: () {
                      // TODO: Navigate to booking screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Booking screen coming soon!'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: const Text('Book Now'),
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryRed, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInfo(BuildContext context, {required String label, required String time}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: AppTheme.greyText),
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
