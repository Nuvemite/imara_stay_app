import 'package:flutter/material.dart';

/// Listing types supported by the wizard
/// Maps to backend listing_types (homes, experiences, services)
enum ListingType {
  home('Home', 'Rent out your property', Icons.home_rounded),
  experience('Experience', 'Host activities & tours', Icons.explore_rounded),
  service('Service', 'Offer services (tours, transport)', Icons.build_rounded);

  final String label;
  final String description;
  final IconData icon;
  const ListingType(this.label, this.description, this.icon);
}
