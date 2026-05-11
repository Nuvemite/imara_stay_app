/// Host listing - from GET /api/host/listings
class HostListing {
  const HostListing({
    required this.id,
    required this.listingTypeId,
    required this.title,
    required this.location,
    required this.rating,
    required this.reviewsCount,
    this.imageUrl,
    required this.status,
    required this.views,
    this.nextGuest,
    required this.lastEdited,
    required this.pricePerNight,
    required this.bedrooms,
    required this.beds,
    required this.bathrooms,
  });

  final int id;
  final int listingTypeId;
  final String title;
  final String location;
  final double rating;
  final int reviewsCount;
  final String? imageUrl;
  final String status;
  final int views;
  final String? nextGuest;
  final String lastEdited;
  final double pricePerNight;
  final int bedrooms;
  final int beds;
  final int bathrooms;

  factory HostListing.fromJson(Map<String, dynamic> json) {
    return HostListing(
      id: (json['id'] ?? 0) as int,
      listingTypeId: (json['listing_type_id'] ?? 0) as int,
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toString().isNotEmpty
          ? double.tryParse(json['rating'].toString()) ?? 0
          : 0,
      reviewsCount: (json['reviews_count'] ?? 0) as int,
      imageUrl: json['image']?.toString(),
      status: json['status']?.toString() ?? 'Draft',
      views: (json['views'] ?? 0) as int,
      nextGuest: json['next_guest']?.toString(),
      lastEdited: json['last_edited']?.toString() ?? '',
      pricePerNight: (json['price_per_night'] ?? 0).toDouble(),
      bedrooms: (json['bedrooms'] ?? 0) as int,
      beds: (json['beds'] ?? 0) as int,
      bathrooms: (json['bathrooms'] ?? 0) as int,
    );
  }
}

/// Response from GET /api/host/listings
class HostListingsResponse {
  const HostListingsResponse({
    required this.listings,
    required this.countsByStatus,
    required this.countsByType,
    required this.pagination,
  });

  final List<HostListing> listings;
  final Map<String, int> countsByStatus;
  final Map<String, int> countsByType;
  final HostListingsPagination pagination;

  factory HostListingsResponse.fromJson(Map<String, dynamic> json) {
    final listingsRaw = json['listings'] as List? ?? [];
    final countsRaw = json['counts_by_status'] as Map<String, dynamic>? ?? {};
    final countsTypeRaw = json['counts_by_type'] as Map<String, dynamic>? ?? {};
    final pagRaw = json['pagination'] as Map<String, dynamic>? ?? {};

    return HostListingsResponse(
      listings: listingsRaw
          .map((e) => HostListing.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      countsByStatus: countsRaw.map((k, v) => MapEntry(k, (v ?? 0) as int)),
      countsByType: countsTypeRaw.map((k, v) => MapEntry(k, (v ?? 0) as int)),
      pagination: HostListingsPagination.fromJson(pagRaw),
    );
  }
}

class HostListingsPagination {
  const HostListingsPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory HostListingsPagination.fromJson(Map<String, dynamic> json) {
    return HostListingsPagination(
      currentPage: (json['current_page'] ?? 1) as int,
      perPage: (json['per_page'] ?? 12) as int,
      total: (json['total'] ?? 0) as int,
      lastPage: (json['last_page'] ?? 1) as int,
    );
  }
}
