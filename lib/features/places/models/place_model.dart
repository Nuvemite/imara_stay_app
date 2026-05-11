/// Place category - types of nearby places
enum PlaceCategory {
  restaurant('Restaurant', 'restaurant'),
  bar('Bar & Club', 'bar'),
  supermarket('Supermarket', 'supermarket'),
  gasStation('Gas Station', 'gas_station'),
  park('Park & Attraction', 'park'),
  hospital('Hospital & Clinic', 'hospital'),
  bank('Bank & ATM', 'bank'),
  transport('Transport', 'transport'),
  shopping('Shopping', 'shopping'),
  other('Other', 'other');

  final String label;
  final String value;
  const PlaceCategory(this.label, this.value);
}

/// Place model - represents a nearby place (restaurant, gas station, etc.)
class Place {
  final String id;
  final String name;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final String? address;
  final String distance; // e.g. "0.5 km"
  final double distanceMeters;
  final String? rating; // e.g. "4.5"
  final int? reviewCount;
  final bool isOpen;

  const Place({
    required this.id,
    required this.name,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    required this.distance,
    required this.distanceMeters,
    this.rating,
    this.reviewCount,
    this.isOpen = true,
  });
}
