/// Lookup data from backend API for resolving slugs to IDs
class ListingLookups {
  const ListingLookups({
    this.listingTypes = const [],
    this.roomTypes = const [],
    this.propertyTypes = const [],
    this.amenities = const [],
  });

  final List<LookupItem> listingTypes;
  final List<LookupItem> roomTypes;
  final List<LookupItem> propertyTypes;
  final List<LookupItem> amenities;

  int? listingTypeIdBySlug(String slug) =>
      _findId(listingTypes, _listingTypeSlugMap[slug] ?? slug);

  int? roomTypeIdBySlug(String slug) =>
      _findId(roomTypes, _roomTypeSlugMap[slug] ?? slug);

  int? propertyTypeIdBySlug(String slug) =>
      _findId(propertyTypes, slug);

  List<int> amenityIdsBySlugs(List<String> slugs) {
    return slugs
        .map((s) {
          final name = _amenitySlugToName[s.toLowerCase()];
          if (name == null) return null;
          return _findIdByName(amenities, name);
        })
        .whereType<int>()
        .toList();
  }

  int? _findIdByName(List<LookupItem> items, String name) {
    final nameLower = name.toLowerCase();
    for (final item in items) {
      final itemName = (item.name ?? '').toLowerCase();
      if (itemName == nameLower) return item.id;
    }
    return null;
  }

  int? _findId(List<LookupItem> items, String slug) {
    final slugLower = slug.toLowerCase().replaceAll('_', '');
    for (final item in items) {
      final itemSlug = (item.slug ?? item.name ?? '')
          .toString()
          .toLowerCase()
          .replaceAll('_', '');
      if (itemSlug == slugLower || itemSlug.contains(slugLower) || slugLower.contains(itemSlug)) {
        return item.id;
      }
    }
    return null;
  }

  /// Backend uses singular slugs: home, experience, service
  static const _listingTypeSlugMap = {
    'home': 'home',
    'experience': 'experience',
    'service': 'service',
  };
  static const _roomTypeSlugMap = {
    'entireplace': 'entire_place',
    'privateroom': 'private_room',
    'sharedroom': 'shared_room',
  };
  /// Backend amenities have no slug - match by exact name
  static const _amenitySlugToName = {
    'wifi': 'Wifi',
    'pool': 'Pool',
    'kitchen': 'Kitchen',
    'parking': 'Free parking',
    'ac': 'Air conditioning',
    'washer': 'Washer',
    'tv': 'TV',
    'gym': 'Gym',
    'garden': 'Garden',
    // dryer, elevator, security - no backend equivalent, skipped
  };
}

class LookupItem {
  const LookupItem({
    required this.id,
    this.name,
    this.slug,
  });

  final int id;
  final String? name;
  final String? slug;

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    return LookupItem(
      id: idRaw is int ? idRaw : (idRaw is num ? idRaw.toInt() : 0),
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
    );
  }
}
