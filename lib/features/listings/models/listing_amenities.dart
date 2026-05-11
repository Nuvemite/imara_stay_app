import 'package:flutter/material.dart';

/// Amenity options for listings
class ListingAmenity {
  const ListingAmenity(this.id, this.label, this.icon);

  final String id;
  final String label;
  final IconData icon;

  static const List<ListingAmenity> all = [
    ListingAmenity('wifi', 'WiFi', Icons.wifi),
    ListingAmenity('pool', 'Pool', Icons.pool),
    ListingAmenity('kitchen', 'Kitchen', Icons.kitchen),
    ListingAmenity('parking', 'Parking', Icons.local_parking),
    ListingAmenity('ac', 'Air conditioning', Icons.ac_unit),
    ListingAmenity('washer', 'Washer', Icons.local_laundry_service),
    ListingAmenity('dryer', 'Dryer', Icons.dry_cleaning),
    ListingAmenity('tv', 'TV', Icons.tv),
    ListingAmenity('gym', 'Gym', Icons.fitness_center),
    ListingAmenity('elevator', 'Elevator', Icons.elevator),
    ListingAmenity('security', 'Security', Icons.security),
    ListingAmenity('garden', 'Garden', Icons.yard),
  ];
}
