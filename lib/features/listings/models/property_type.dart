import 'package:flutter/material.dart';

/// Property type for Home listings (apartment, house, villa, etc.)
enum PropertyType {
  apartment('Apartment', Icons.apartment),
  house('House', Icons.house),
  villa('Villa', Icons.villa),
  lodge('Lodge', Icons.nature_people),
  cottage('Cottage', Icons.cottage),
  mansion('Mansion', Icons.castle);

  final String label;
  final IconData icon;
  const PropertyType(this.label, this.icon);
}
