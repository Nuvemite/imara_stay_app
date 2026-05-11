import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/core/widgets/imara_stay_logo.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/auth/models/user_model.dart';
import 'package:imara_stay/features/properties/presentation/widgets/category_selector.dart';
import 'package:imara_stay/features/properties/presentation/widgets/filter_bottom_sheet.dart';
import 'package:imara_stay/features/properties/presentation/widgets/property_card.dart';
import 'package:imara_stay/features/properties/presentation/screens/property_details_screen.dart';
import 'package:imara_stay/features/places/presentation/screens/places_near_me_screen.dart';
import 'package:imara_stay/features/saved/presentation/screens/wishlist_screen.dart';
import 'package:imara_stay/features/profile/presentation/screens/profile_screen.dart';
import 'package:imara_stay/features/properties/state/property_controller.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final propertyState = ref.watch(propertyProvider);
    final propertyController = ref.read(propertyProvider.notifier);
    final favouriteIds = ref.watch(favouritesProvider);
    final favouritesController = ref.read(favouritesProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Custom App Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const ImaraStayLogo(
                              size: ImaraStayLogoSize.small,
                              showIcon: true,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Location',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.greyText),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppTheme.primaryRed,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Nairobi, Kenya',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PlacesNearMeScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRed
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.near_me,
                                          color: AppTheme.primaryRed,
                                          size: 14,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Places',
                                          style: TextStyle(
                                            color: AppTheme.primaryRed,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        CircleAvatar(
                          backgroundColor: AppTheme.lightGrey,
                          child: IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.notifications_none,
                              color: AppTheme.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    Text(
                      'Habari, ${_getGreetingName(authState.user)}!',
                      style: Theme.of(
                        context,
                      ).textTheme.displayLarge?.copyWith(fontSize: 24),
                    ),
                    Text(
                      'Find your perfect stay today.',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: AppTheme.greyText),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lightGrey,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: TextField(
                          onChanged: (val) =>
                              propertyController.search(val),
                          decoration: const InputDecoration(
                            hintText: 'Search for properties...',
                            border: InputBorder.none,
                            prefixIcon:
                                Icon(Icons.search, color: AppTheme.greyText),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Material(
                      color: AppTheme.lightGrey,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      child: InkWell(
                        onTap: () {
                          FilterBottomSheet.show(
                            context,
                            initialFilters: propertyState.filters,
                            minPriceRange: 0,
                            maxPriceRange: 50000,
                            onApply: propertyController.applyFilters,
                            onClear: propertyController.clearFilters,
                          );
                        },
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Badge(
                            isLabelVisible:
                                propertyState.filters.hasActiveFilters,
                            label: propertyState.filters.hasActiveFilters
                                ? Text(
                                    '${propertyState.filters.activeFilterCount}',
                                    style: const TextStyle(
                                      color: AppTheme.white,
                                      fontSize: 10,
                                    ),
                                  )
                                : null,
                            child: const Icon(
                              Icons.filter_list,
                              color: AppTheme.primaryRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Active filters indicator
            if (propertyState.filters.hasActiveFilters)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${propertyState.filters.activeFilterCount} filter(s) active',
                              style: const TextStyle(
                                color: AppTheme.primaryRed,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => propertyController.clearFilters(),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: AppTheme.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Category Selector
            SliverToBoxAdapter(
              child: CategorySelector(
                selectedCategory: propertyState.selectedCategory,
                onCategorySelected: (cat) =>
                    propertyController.selectCategory(cat),
              ),
            ),

            // Stays Count
            if (!propertyState.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${propertyState.filteredProperties.length} ${propertyState.selectedCategory.label} found',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (propertyState.totalPages > 1)
                        Text(
                          'Page ${propertyState.currentPage + 1} of ${propertyState.totalPages}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.greyText,
                              ),
                        ),
                    ],
                  ),
                ),
              ),

            // Listings Grid/List (Showing only 3 per page)
            if (propertyState.isLoading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryRed),
                ),
              )
            else if (propertyState.filteredProperties.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppTheme.lightGrey,
                      ),
                      SizedBox(height: 16),
                      Text('No properties found in this category'),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final property = propertyState.paginatedProperties[index];
                    return PropertyCard(
                      property: property,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailsScreen(
                              propertyId: property.id,
                            ),
                          ),
                        );
                      },
                      isFavourite: favouriteIds.contains(property.id),
                      onFavouriteTap: () =>
                          favouritesController.toggle(property.id),
                    );
                  }, childCount: propertyState.paginatedProperties.length),
                ),
              ),

            // Pagination Controls
            if (!propertyState.isLoading &&
                propertyState.filteredProperties.isNotEmpty &&
                propertyState.totalPages > 1)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.lg,
                  ),
                  child: _buildPaginationControls(
                    context,
                    propertyState,
                    propertyController,
                  ),
                ),
              ),

            // Bottom Spacing for Navigation Bar (if any)
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),

      // Bottom Navigation Bar placeholder
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.explore, 'Explore', true, null, null),
            _buildNavItem(
              context,
              Icons.favorite_border,
              'Wishlist',
              false,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WishlistScreen(),
                  ),
                );
              },
              favouriteIds.isEmpty ? null : favouriteIds.length,
            ),
            _buildNavItem(context, Icons.book_online_outlined, 'Bookings', false,
                null, null),
            _buildNavItem(
              context,
              Icons.person_outline,
              'Profile',
              false,
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        const ProfileScreen(),
                  ),
                );
              },
              null,
            ),
          ],
        ),
      ),
    );
  }

  String _getGreetingName(AuthUser? user) {
    if (user == null || user.name.isEmpty) {
      return 'Mgeni';
    }
    final nameParts = user.name.split(' ');
    return nameParts.first;
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    VoidCallback? onTap, [
    int? badgeCount,
  ]) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppTheme.primaryRed : AppTheme.greyText,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryRed : AppTheme.greyText,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    PropertyState state,
    PropertyController controller,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          TextButton.icon(
            onPressed: state.hasPreviousPage
                ? () => controller.previousPage()
                : null,
            icon: const Icon(Icons.chevron_left, size: 20),
            label: const Text('Previous'),
            style: TextButton.styleFrom(
              foregroundColor: state.hasPreviousPage
                  ? AppTheme.primaryRed
                  : AppTheme.greyText,
            ),
          ),

          // Page Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              state.totalPages,
              (index) => GestureDetector(
                onTap: () => controller.goToPage(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: state.currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: state.currentPage == index
                        ? AppTheme.primaryRed
                        : AppTheme.greyText.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

          // Next Button
          TextButton.icon(
            onPressed:
                state.hasNextPage ? () => controller.nextPage() : null,
            icon: const Icon(Icons.chevron_right, size: 20),
            label: const Text('Next'),
            style: TextButton.styleFrom(
              foregroundColor: state.hasNextPage
                  ? AppTheme.primaryRed
                  : AppTheme.greyText,
            ),
          ),
        ],
      ),
    );
  }
}
