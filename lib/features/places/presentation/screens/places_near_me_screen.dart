import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/places/models/place_model.dart';
import 'package:imara_stay/features/places/models/places_state.dart';
import 'package:imara_stay/features/places/state/places_controller.dart';
import 'package:imara_stay/features/places/presentation/widgets/place_card.dart';

/// Places Near Me Screen
/// Full screen with map, category filters, search, and place list
class PlacesNearMeScreen extends ConsumerStatefulWidget {
  /// Optional: Center map on this location (e.g. from property details)
  final double? initialLatitude;
  final double? initialLongitude;

  const PlacesNearMeScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  ConsumerState<PlacesNearMeScreen> createState() =>
      _PlacesNearMeScreenState();
}

class _PlacesNearMeScreenState extends ConsumerState<PlacesNearMeScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlaces());
  }

  void _loadPlaces() {
    final controller = ref.read(placesControllerProvider.notifier);

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      controller.loadPlacesForLocation(
        latitude: widget.initialLatitude!,
        longitude: widget.initialLongitude!,
      );
    } else {
      controller.loadPlacesFromUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(placesControllerProvider);
    final controller = ref.read(placesControllerProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.darkText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Places Near Me',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.darkText,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search restaurants, shops, gas stations...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.greyText),
                suffixIcon: state.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppTheme.greyText),
                        onPressed: () => controller.setSearchQuery(''),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Category filters
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              children: [
                _buildCategoryChip(
                  context,
                  label: 'All',
                  isSelected: state.selectedCategory == null,
                  onTap: () => controller.selectCategory(null),
                ),
                ...PlaceCategory.values.map((cat) => _buildCategoryChip(
                      context,
                      label: cat.label,
                      isSelected: state.selectedCategory == cat,
                      onTap: () => controller.selectCategory(cat),
                    )),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Map - fixed height
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                height: 200,
                child: _buildMap(state),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Places list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${state.filteredPlaces.length} places nearby',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: state.isLoading ? null : () => controller.refresh(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Places list
          Expanded(
            child: _buildPlacesList(context, state, controller),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.sm),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppTheme.primaryRed.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryRed,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryRed : AppTheme.darkText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildMap(PlacesNearMeState state) {
    final lat = state.centerLatitude ?? state.userLatitude ?? -1.2620;
    final lng = state.centerLongitude ?? state.userLongitude ?? 36.8020;

    final markers = <Marker>{};
    for (final place in state.places) {
      markers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          infoWindow: InfoWindow(title: place.name),
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(lat, lng),
        zoom: 15,
      ),
      markers: markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
      onMapCreated: (_) {},
    );
  }

  Widget _buildPlacesList(
    BuildContext context,
    PlacesNearMeState state,
    PlacesController controller,
  ) {
    if (state.isLoading && state.places.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.greyText),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Could not load places',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            ElevatedButton(
              onPressed: _loadPlaces,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final places = state.filteredPlaces;

    if (places.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppTheme.greyText.withOpacity(0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No places found',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.greyText,
                  ),
            ),
            Text(
              'Try a different category or search',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        itemCount: places.length,
        itemBuilder: (context, index) {
          final place = places[index];
          return PlaceCard(
            place: place,
            onTap: () {
              // TODO: Open in maps or show place details
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${place.name} - ${place.distance} away'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
