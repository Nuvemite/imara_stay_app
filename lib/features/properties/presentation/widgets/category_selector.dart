import 'package:flutter/material.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/models/property_model.dart';

class CategorySelector extends StatelessWidget {
  final PropertyCategory selectedCategory;
  final Function(PropertyCategory) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: PropertyCategory.values.map((category) {
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () => onCategorySelected(category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: AppSpacing.md),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryRed : AppTheme.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? AppTheme.primaryRed : AppTheme.lightGrey,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryRed.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForCategory(category),
                    size: 18,
                    color: isSelected ? AppTheme.white : AppTheme.greyText,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category.label,
                    style: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.darkText,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForCategory(PropertyCategory category) {
    switch (category) {
      case PropertyCategory.apartments:
        return Icons.apartment_rounded;
      case PropertyCategory.villas:
        return Icons.holiday_village_rounded;
      case PropertyCategory.cottages:
        return Icons.cabin_rounded;
      case PropertyCategory.lodges:
        return Icons.nature_rounded;
      case PropertyCategory.mansions:
        return Icons.castle_rounded;
    }
  }
}
