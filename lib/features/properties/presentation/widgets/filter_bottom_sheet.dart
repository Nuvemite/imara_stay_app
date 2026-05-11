import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/models/property_filters.dart';

/// Filter bottom sheet - Price, amenities, location filters
class FilterBottomSheet extends StatefulWidget {
  final PropertyFilters initialFilters;
  final double minPriceRange;
  final double maxPriceRange;
  final void Function(PropertyFilters filters) onApply;
  final VoidCallback? onClear;

  const FilterBottomSheet({
    super.key,
    required this.initialFilters,
    this.minPriceRange = 0,
    this.maxPriceRange = 50000,
    required this.onApply,
    this.onClear,
  });

  static Future<void> show(
    BuildContext context, {
    required PropertyFilters initialFilters,
    required double minPriceRange,
    required double maxPriceRange,
    required void Function(PropertyFilters filters) onApply,
    VoidCallback? onClear,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialFilters: initialFilters,
        minPriceRange: minPriceRange,
        maxPriceRange: maxPriceRange,
        onApply: onApply,
        onClear: onClear,
      ),
    );
  }

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _minPrice;
  late double _maxPrice;
  late Set<String> _amenities;
  late Set<String> _locations;
  late double? _minRating;

  @override
  void initState() {
    super.initState();
    _minPrice = widget.initialFilters.minPrice ?? widget.minPriceRange;
    _maxPrice = widget.initialFilters.maxPrice ?? widget.maxPriceRange;
    _amenities = Set.from(widget.initialFilters.amenities);
    _locations = Set.from(widget.initialFilters.locations);
    _minRating = widget.initialFilters.minRating;
  }

  void _apply() {
    widget.onApply(PropertyFilters(
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      amenities: _amenities,
      locations: _locations,
      minRating: _minRating,
    ));
    Navigator.of(context).pop();
  }

  void _clear() {
    setState(() {
      _minPrice = widget.minPriceRange;
      _maxPrice = widget.maxPriceRange;
      _amenities = {};
      _locations = {};
      _minRating = null;
    });
    widget.onApply(const PropertyFilters());
    widget.onClear?.call();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: _clear,
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  children: [
                    // Price range
                    _buildSectionTitle('Price per night (KES)'),
                    RangeSlider(
                      values: RangeValues(_minPrice, _maxPrice),
                      min: widget.minPriceRange,
                      max: widget.maxPriceRange,
                      divisions: 50,
                      activeColor: AppTheme.primaryRed,
                      labels: RangeLabels(
                        _minPrice.toInt().toString(),
                        _maxPrice.toInt().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _minPrice = values.start;
                          _maxPrice = values.end;
                        });
                      },
                    ),
                    Text(
                      'KES ${_minPrice.toInt()} - KES ${_maxPrice.toInt()}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.greyText,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Min rating
                    _buildSectionTitle('Minimum rating'),
                    Slider(
                      value: _minRating ?? 0,
                      min: 0,
                      max: 5,
                      divisions: 10,
                      activeColor: AppTheme.primaryRed,
                      label: _minRating != null
                          ? _minRating!.toStringAsFixed(1)
                          : 'Any',
                      onChanged: (value) {
                        setState(() {
                          _minRating = value > 0 ? value : null;
                        });
                      },
                    ),
                    Text(
                      _minRating != null
                          ? '${_minRating!.toStringAsFixed(1)} stars & up'
                          : 'Any rating',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.greyText,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Amenities
                    _buildSectionTitle('Amenities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filterAmenityOptions.map((amenity) {
                        final isSelected = _amenities.contains(amenity);
                        return FilterChip(
                          label: Text(amenity),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _amenities.add(amenity);
                              } else {
                                _amenities.remove(amenity);
                              }
                            });
                          },
                          selectedColor:
                              AppTheme.primaryRed.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryRed,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Location
                    _buildSectionTitle('Location'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: filterLocationOptions.map((location) {
                        final isSelected = _locations.contains(location);
                        return FilterChip(
                          label: Text(location),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _locations.add(location);
                              } else {
                                _locations.remove(location);
                              }
                            });
                          },
                          selectedColor:
                              AppTheme.primaryRed.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryRed,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
              // Apply button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: const Text('Apply filters'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
