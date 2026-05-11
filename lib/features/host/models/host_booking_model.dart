/// Host booking - from GET /api/host/bookings
class HostBooking {
  const HostBooking({
    required this.id,
    required this.listing,
    required this.guest,
    required this.checkIn,
    required this.checkOut,
    required this.startDate,
    required this.endDate,
    required this.nights,
    required this.guests,
    required this.status,
    required this.totalPrice,
    required this.paymentStatus,
    required this.canApprove,
    required this.canReject,
    required this.canCancel,
    required this.isUpcoming,
    required this.isPast,
    this.confirmationCode,
    this.timeSlot,
    this.serviceOffering,
  });

  final int id;
  final HostBookingListing listing;
  final HostBookingGuest guest;
  final String checkIn;
  final String checkOut;
  final String startDate;
  final String endDate;
  final int nights;
  final HostBookingGuests guests;
  final String status;
  final double totalPrice;
  final String? paymentStatus;
  final bool canApprove;
  final bool canReject;
  final bool canCancel;
  final bool isUpcoming;
  final bool isPast;
  final String? confirmationCode;
  final HostBookingTimeSlot? timeSlot;
  final HostBookingServiceOffering? serviceOffering;

  factory HostBooking.fromJson(Map<String, dynamic> json) {
    final listingRaw = json['listing'] as Map<String, dynamic>? ?? {};
    final guestRaw = json['guest'] as Map<String, dynamic>? ?? {};
    final guestsRaw = json['guests'] as Map<String, dynamic>? ?? {};
    final timeSlotRaw = json['time_slot'] as Map<String, dynamic>?;
    final serviceRaw = json['service_offering'] as Map<String, dynamic>?;

    return HostBooking(
      id: (json['id'] ?? 0) as int,
      listing: HostBookingListing.fromJson(listingRaw),
      guest: HostBookingGuest.fromJson(guestRaw),
      checkIn: json['check_in']?.toString() ?? '',
      checkOut: json['check_out']?.toString() ?? '',
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      nights: (json['nights'] ?? 0) as int,
      guests: HostBookingGuests.fromJson(guestsRaw),
      status: json['status']?.toString() ?? 'pending',
      totalPrice: (json['total_price'] ?? 0).toDouble(),
      paymentStatus: json['payment_status']?.toString(),
      canApprove: (json['can_approve'] ?? false) as bool,
      canReject: (json['can_reject'] ?? false) as bool,
      canCancel: (json['can_cancel'] ?? false) as bool,
      isUpcoming: (json['is_upcoming'] ?? false) as bool,
      isPast: (json['is_past'] ?? false) as bool,
      confirmationCode: json['confirmation_code']?.toString(),
      timeSlot: timeSlotRaw != null ? HostBookingTimeSlot.fromJson(timeSlotRaw) : null,
      serviceOffering: serviceRaw != null ? HostBookingServiceOffering.fromJson(serviceRaw) : null,
    );
  }
}

class HostBookingListing {
  const HostBookingListing({
    required this.id,
    required this.title,
    required this.location,
    this.address,
    this.imageUrl,
    this.listingTypeId,
  });

  final int id;
  final String title;
  final String location;
  final String? address;
  final String? imageUrl;
  final int? listingTypeId;

  factory HostBookingListing.fromJson(Map<String, dynamic> json) {
    return HostBookingListing(
      id: (json['id'] ?? 0) as int,
      title: json['title']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      address: json['address']?.toString(),
      imageUrl: json['image']?.toString(),
      listingTypeId: json['listing_type_id'] as int?,
    );
  }
}

class HostBookingGuest {
  const HostBookingGuest({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
  });

  final int id;
  final String name;
  final String? email;
  final String? avatarUrl;

  factory HostBookingGuest.fromJson(Map<String, dynamic> json) {
    return HostBookingGuest(
      id: (json['id'] ?? 0) as int,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString(),
    );
  }
}

class HostBookingGuests {
  const HostBookingGuests({
    required this.adults,
    required this.children,
    required this.infants,
    required this.pets,
    required this.total,
  });

  final int adults;
  final int children;
  final int infants;
  final int pets;
  final int total;

  factory HostBookingGuests.fromJson(Map<String, dynamic> json) {
    return HostBookingGuests(
      adults: (json['adults'] ?? 0) as int,
      children: (json['children'] ?? 0) as int,
      infants: (json['infants'] ?? 0) as int,
      pets: (json['pets'] ?? 0) as int,
      total: (json['total'] ?? 0) as int,
    );
  }
}

class HostBookingTimeSlot {
  const HostBookingTimeSlot({
    required this.startTime,
    required this.endTime,
  });

  final String startTime;
  final String endTime;

  factory HostBookingTimeSlot.fromJson(Map<String, dynamic> json) {
    return HostBookingTimeSlot(
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
    );
  }
}

class HostBookingServiceOffering {
  const HostBookingServiceOffering({
    required this.name,
    this.basePrice,
  });

  final String name;
  final double? basePrice;

  factory HostBookingServiceOffering.fromJson(Map<String, dynamic> json) {
    return HostBookingServiceOffering(
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      basePrice: (json['base_price'] as num?)?.toDouble(),
    );
  }
}

/// Response from GET /api/host/bookings
class HostBookingsResponse {
  const HostBookingsResponse({
    required this.bookings,
    required this.pagination,
  });

  final List<HostBooking> bookings;
  final HostBookingsPagination pagination;

  factory HostBookingsResponse.fromJson(Map<String, dynamic> json) {
    final bookingsRaw = json['bookings'] as List? ?? [];
    final pagRaw = json['pagination'] as Map<String, dynamic>? ?? {};

    return HostBookingsResponse(
      bookings: bookingsRaw
          .map((e) => HostBooking.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      pagination: HostBookingsPagination.fromJson(pagRaw),
    );
  }
}

class HostBookingsPagination {
  const HostBookingsPagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  factory HostBookingsPagination.fromJson(Map<String, dynamic> json) {
    return HostBookingsPagination(
      currentPage: (json['current_page'] ?? 1) as int,
      perPage: (json['per_page'] ?? 12) as int,
      total: (json['total'] ?? 0) as int,
      lastPage: (json['last_page'] ?? 1) as int,
    );
  }
}
