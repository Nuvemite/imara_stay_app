import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/auth/models/auth_state.dart';
import 'package:imara_stay/features/auth/presentation/widgets/auth_dialogs.dart';
import 'package:imara_stay/features/properties/presentation/widgets/category_selector.dart';
import 'package:imara_stay/features/properties/presentation/widgets/filter_bottom_sheet.dart';
import 'package:imara_stay/features/properties/presentation/widgets/property_card.dart';
import 'package:imara_stay/features/properties/presentation/screens/property_details_screen.dart';
import 'package:imara_stay/features/properties/presentation/widgets/search_header_pill.dart';
import 'package:imara_stay/features/properties/state/property_controller.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final propertyState = ref.watch(propertyProvider);
    final propertyController = ref.read(propertyProvider.notifier);
    final favouriteIds = ref.watch(favouritesProvider);
    final favouritesController = ref.read(favouritesProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Big Search Pill
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: SearchHeaderPill(
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
                ),
              ),
            ),

            // Top Level Categories (Homes, Experiences, Services)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    _buildTopCategoryTab('Homes', true),
                    const SizedBox(width: 16),
                    _buildTopCategoryTab('Experiences', false),
                    const SizedBox(width: 16),
                    _buildTopCategoryTab('Services', false),
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
                      onFavouriteTap: () {
                        final authState = ref.read(authProvider);
                        if (authState.status != AuthStatus.authenticated) {
                          AuthDialogs.showLoginPrompt(
                            context,
                            'Log in to save to Wishlist',
                            'You need an account to save properties.',
                          );
                        } else {
                          favouritesController.toggle(property.id);
                        }
                      },
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
    );
  }

  Widget _buildTopCategoryTab(String label, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.darkText : AppTheme.greyText,
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            height: 2,
            width: 24,
            color: AppTheme.darkText,
          )
        else
          const SizedBox(height: 6),
      ],
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
