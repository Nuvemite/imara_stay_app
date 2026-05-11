import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/listings/models/listing_amenities.dart';
import 'package:imara_stay/features/listings/models/listing_type.dart';
import 'package:imara_stay/features/listings/models/listing_wizard_state.dart';
import 'package:imara_stay/features/listings/models/property_type.dart';
import 'package:imara_stay/features/listings/models/room_type.dart';
import 'package:imara_stay/features/listings/state/listing_wizard_controller.dart';

/// Full listing wizard: 5 wizards × 2 steps = 10 steps
class ListingWizardScreen extends ConsumerStatefulWidget {
  const ListingWizardScreen({super.key, required this.initialType});

  final ListingType initialType;

  @override
  ConsumerState<ListingWizardScreen> createState() => _ListingWizardScreenState();
}

class _ListingWizardScreenState extends ConsumerState<ListingWizardScreen> {
  final _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(listingWizardProvider.notifier);
      controller.selectType(widget.initialType);
      controller.goToStep(1); // Skip step 0 - type already selected
      _pageController.jumpToPage(1);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(listingWizardProvider);
    final controller = ref.read(listingWizardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('List ${state.listingType.label}'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _handleClose(context, controller, state),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (state.currentStep + 1) / ListingWizardState.totalSteps,
            backgroundColor: AppTheme.lightGrey,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryRed),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                _stepTitle(state.currentStep),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.greyText,
                    ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step0Type(controller: controller, state: state),
                  _Step1PropertyType(controller: controller, state: state),
                  _Step2Location(controller: controller, state: state),
                  _Step3Capacity(controller: controller, state: state),
                  _Step4Amenities(controller: controller, state: state),
                  _Step5Photos(controller: controller),
                  _Step6Title(controller: controller, state: state),
                  _Step7Description(controller: controller, state: state),
                  _Step8Pricing(controller: controller, state: state),
                  _Step9Review(
                    controller: controller,
                    state: state,
                    onSaveDraft: () => _handleSubmit(context, controller, state, ListingStatus.draft),
                    onPublish: () => _handleSubmit(context, controller, state, ListingStatus.published),
                  ),
                ],
              ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Row(
            children: [
              if (state.currentStep > 0)
                OutlinedButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          controller.previousStep();
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                  child: const Text('Back'),
                ),
              if (state.currentStep > 0) const SizedBox(width: AppSpacing.md),
              if (state.isLastStep) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _handleSubmit(context, controller, state, ListingStatus.draft),
                    child: const Text('Save draft'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _handleSubmit(context, controller, state, ListingStatus.published),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Publish'),
                  ),
                ),
              ] else
                Expanded(
                  child: ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => _handleNext(context, controller, state),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Continue'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _stepTitle(int step) {
    const titles = [
      'Choose listing type',
      'Property type & room type',
      'Location',
      'Capacity',
      'Amenities',
      'Photos',
      'Title',
      'Description',
      'Pricing',
      'Review & publish',
    ];
    return titles[step < titles.length ? step : 0];
  }

  void _handleClose(
    BuildContext context,
    ListingWizardController controller,
    ListingWizardState state,
  ) {
    if (state.currentStep > 0) {
      controller.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      controller.reset();
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleNext(
    BuildContext context,
    ListingWizardController controller,
    ListingWizardState state,
  ) async {
    if (!state.canProceedFromCurrentStep()) return;
    controller.nextStep();
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _handleSubmit(
    BuildContext context,
    ListingWizardController controller,
    ListingWizardState state,
    ListingStatus status,
  ) async {
    controller.setStatus(status);
    final success = await controller.submit();
    if (success && context.mounted) {
      controller.reset();
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
}

// Step 0: Type (shown when navigating back from step 1)
class _Step0Type extends StatelessWidget {
  const _Step0Type({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: ListingType.values
            .map((type) => _TypeChip(
                  type: type,
                  isSelected: state.listingType == type,
                  onTap: () => controller.updateTypeAndProperty(
                    listingType: type,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  final ListingType type;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Material(
        color: isSelected
            ? AppTheme.primaryRed.withValues(alpha: 0.1)
            : AppTheme.white,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Icon(type.icon, size: 32, color: AppTheme.primaryRed),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(type.label, style: Theme.of(context).textTheme.titleLarge),
                      Text(type.description, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                if (isSelected) const Icon(Icons.check_circle, color: AppTheme.primaryRed),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Step 1: Property type + room type (Home) or subcategory (Experience/Service)
class _Step1PropertyType extends StatelessWidget {
  const _Step1PropertyType({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    if (state.listingType == ListingType.home) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Property type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: PropertyType.values
                  .map((t) => FilterChip(
                        label: Text(t.label),
                        selected: state.propertyType == t,
                        onSelected: (_) => controller.updateTypeAndProperty(propertyType: t),
                      ))
                  .toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Room type', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            ...RoomType.values.map((t) => RadioListTile<RoomType>(
                  title: Text(t.label),
                  subtitle: Text(t.description, style: Theme.of(context).textTheme.bodySmall),
                  value: t,
                  groupValue: state.roomType,
                  onChanged: (v) => v != null ? controller.updateTypeAndProperty(roomType: v) : null,
                )),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${state.listingType.label} subcategory',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            initialValue: state.subcategory,
            decoration: InputDecoration(
              hintText: state.listingType == ListingType.experience
                  ? 'e.g. Safari tour, Cooking class'
                  : 'e.g. Airport transfer, Guided tour',
            ),
            onChanged: (v) => controller.updateTypeAndProperty(subcategory: v),
          ),
        ],
      ),
    );
  }
}

// Step 2: Location (address, city, country)
class _Step2Location extends StatelessWidget {
  const _Step2Location({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: state.address,
            decoration: const InputDecoration(
              labelText: 'Address',
              hintText: 'Street address, area',
            ),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onChanged: (v) => controller.updateLocation(address: v),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            initialValue: state.city,
            decoration: const InputDecoration(labelText: 'City', hintText: 'e.g. Nairobi'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onChanged: (v) => controller.updateLocation(city: v),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            initialValue: state.country,
            decoration: const InputDecoration(labelText: 'Country', hintText: 'e.g. Kenya'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
            onChanged: (v) => controller.updateLocation(country: v),
          ),
        ],
      ),
    );
  }
}

// Step 3: Capacity (guests, bedrooms, beds, bathrooms)
class _Step3Capacity extends StatelessWidget {
  const _Step3Capacity({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _NumberField(
            label: 'Max guests',
            value: state.maxGuests,
            onChanged: (v) => controller.updateCapacity(maxGuests: v),
            validator: (v) => (v ?? 0) < 1 ? 'Min 1' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _NumberField(
            label: 'Bedrooms',
            value: state.bedrooms,
            onChanged: (v) => controller.updateCapacity(bedrooms: v),
            validator: (v) => (v ?? 0) < 1 ? 'Min 1' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _NumberField(
            label: 'Beds',
            value: state.beds,
            onChanged: (v) => controller.updateCapacity(beds: v),
            validator: (v) => (v ?? 0) < 1 ? 'Min 1' : null,
          ),
          const SizedBox(height: AppSpacing.lg),
          _NumberField(
            label: 'Bathrooms',
            value: state.bathrooms,
            onChanged: (v) => controller.updateCapacity(bathrooms: v),
            validator: (v) => (v ?? 0) < 1 ? 'Min 1' : null,
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.validator,
  });

  final String label;
  final int? value;
  final void Function(int?) onChanged;
  final String? Function(int?) validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value?.toString() ?? '',
      decoration: InputDecoration(labelText: label),
      keyboardType: TextInputType.number,
      validator: (v) => validator(int.tryParse(v ?? '')),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) onChanged(n);
      },
    );
  }
}

// Step 4: Amenities
class _Step4Amenities extends StatelessWidget {
  const _Step4Amenities({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select amenities (optional)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: ListingAmenity.all.map((a) {
              final selected = state.amenities.contains(a.id);
              return FilterChip(
                avatar: Icon(a.icon, size: 18, color: selected ? AppTheme.white : AppTheme.primaryRed),
                label: Text(a.label),
                selected: selected,
                onSelected: (_) => controller.toggleAmenity(a.id),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// Step 5: Photos (min 4)
class _Step5Photos extends ConsumerWidget {
  const _Step5Photos({required this.controller});

  final ListingWizardController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listingWizardProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Add at least 4 photos',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              ...state.imagePaths.map((path) => _ImageThumb(
                    path: path,
                    onRemove: () => controller.removeImage(path),
                  )),
              GestureDetector(
                onTap: () async {
                  final images = await ImagePicker().pickMultiImage();
                  for (final x in images) {
                    controller.addImage(x.path);
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppTheme.lightGrey,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppTheme.greyText.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.add_photo_alternate, size: 32, color: AppTheme.greyText),
                ),
              ),
            ],
          ),
          if (state.imagePaths.length < 4)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                '${4 - state.imagePaths.length} more required',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.red),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          SwitchListTile(
            title: const Text('Add virtual tour'),
            subtitle: const Text('360° virtual tour'),
            value: state.hasVirtualTour,
            onChanged: (v) => controller.setHasVirtualTour(v),
          ),
        ],
      ),
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.path, required this.onRemove});

  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Image.file(File(path), width: 80, height: 80, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.black54,
              child: Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

// Step 6: Title
class _Step6Title extends StatelessWidget {
  const _Step6Title({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: state.title,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'Short, catchy title (min 5 chars)',
            ),
            validator: (v) => v == null || v.trim().length < 5 ? 'Min 5 characters' : null,
            onChanged: (v) => controller.updateTitleAndDescription(title: v),
          ),
        ],
      ),
    );
  }
}

// Step 7: Description
class _Step7Description extends StatelessWidget {
  const _Step7Description({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: state.description,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Describe your listing (min 10 chars)',
              alignLabelWithHint: true,
            ),
            maxLines: 6,
            validator: (v) => v == null || v.trim().length < 10 ? 'Min 10 characters' : null,
            onChanged: (v) => controller.updateTitleAndDescription(description: v),
          ),
        ],
      ),
    );
  }
}

// Step 8: Pricing
class _Step8Pricing extends StatelessWidget {
  const _Step8Pricing({required this.controller, required this.state});

  final ListingWizardController controller;
  final ListingWizardState state;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            initialValue: state.pricePerNight > 0 ? state.pricePerNight.toStringAsFixed(0) : '',
            decoration: const InputDecoration(
              labelText: 'Nightly rate (KES)',
              hintText: 'e.g. 5000',
            ),
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = double.tryParse(v ?? '');
              return n == null || n <= 0 ? 'Enter valid price' : null;
            },
            onChanged: (v) {
              final n = double.tryParse(v);
              if (n != null) controller.updatePricing(pricePerNight: n);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            initialValue: state.cleaningFee?.toStringAsFixed(0) ?? '',
            decoration: const InputDecoration(
              labelText: 'Cleaning fee (KES) - optional',
              hintText: 'e.g. 500',
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) {
              final n = double.tryParse(v);
              controller.updatePricing(cleaningFee: n);
            },
          ),
        ],
      ),
    );
  }
}

// Step 9: Review & publish
class _Step9Review extends StatelessWidget {
  const _Step9Review({
    required this.controller,
    required this.state,
    required this.onSaveDraft,
    required this.onPublish,
  });

  final ListingWizardController controller;
  final ListingWizardState state;
  final VoidCallback onSaveDraft;
  final VoidCallback onPublish;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReviewRow('Type', state.listingType.label),
          _ReviewRow('Property', state.propertyType?.label ?? state.subcategory),
          if (state.roomType != null) _ReviewRow('Room', state.roomType!.label),
          _ReviewRow('Location', state.location),
          _ReviewRow('Guests', '${state.maxGuests ?? 0}'),
          _ReviewRow('Bedrooms', '${state.bedrooms ?? 0}'),
          _ReviewRow('Beds', '${state.beds ?? 0}'),
          _ReviewRow('Bathrooms', '${state.bathrooms ?? 0}'),
          _ReviewRow('Amenities', state.amenities.isEmpty ? 'None' : state.amenities.join(', ')),
          _ReviewRow('Photos', '${state.imagePaths.length}'),
          _ReviewRow('Title', state.title),
          _ReviewRow('Price', 'KES ${state.pricePerNight.toStringAsFixed(0)}/night'),
          if (state.cleaningFee != null && state.cleaningFee! > 0)
            _ReviewRow('Cleaning fee', 'KES ${state.cleaningFee!.toStringAsFixed(0)}'),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.isLoading ? null : onSaveDraft,
                  child: const Text('Save draft'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: state.isLoading ? null : onPublish,
                  child: state.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Publish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
