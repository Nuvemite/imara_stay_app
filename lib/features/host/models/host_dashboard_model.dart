/// Host dashboard data - parsed from GET /api/host/dashboard
class HostDashboardModel {
  const HostDashboardModel({
    required this.userName,
    required this.financial,
    required this.bookings,
    required this.rating,
    this.alerts = const [],
    this.recentBookings = const [],
    this.recentReviews = const [],
    this.charts,
    this.listingPerformance,
    this.calendarBookings,
  });

  final String userName;
  final HostFinancial financial;
  final HostBookingStats bookings;
  final HostRating rating;
  final List<HostAlert> alerts;
  final List<RecentBooking> recentBookings;
  final List<RecentReview> recentReviews;
  final HostCharts? charts;
  final List<ListingPerformance>? listingPerformance;
  final List<CalendarBooking>? calendarBookings;

  factory HostDashboardModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final financial = json['financial'] as Map<String, dynamic>? ?? {};
    final bookings = json['bookings'] as Map<String, dynamic>? ?? {};
    final rating = json['rating'] as Map<String, dynamic>? ?? {};
    final charts = json['charts'] as Map<String, dynamic>?;
    final alertsRaw = json['alerts'] as List? ?? [];
    final recentBookingsRaw = json['recent_bookings'] as List? ?? [];
    final recentReviewsRaw = json['recent_reviews'] as List? ?? [];
    final listingPerfRaw = json['listing_performance'] as List? ?? [];
    final calendarRaw = json['calendar_bookings'] as List? ?? [];

    return HostDashboardModel(
      userName: user['name']?.toString() ?? 'Host',
      financial: HostFinancial.fromJson(financial),
      bookings: HostBookingStats.fromJson(bookings),
      rating: HostRating.fromJson(rating),
      alerts: alertsRaw
          .map((e) => HostAlert.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      recentBookings: recentBookingsRaw
          .map((e) => RecentBooking.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      recentReviews: recentReviewsRaw
          .map((e) => RecentReview.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      charts: charts != null ? HostCharts.fromJson(charts) : null,
      listingPerformance: listingPerfRaw.isNotEmpty
          ? listingPerfRaw
              .map((e) =>
                  ListingPerformance.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
      calendarBookings: calendarRaw.isNotEmpty
          ? calendarRaw
              .map((e) =>
                  CalendarBooking.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : null,
    );
  }
}

class HostFinancial {
  const HostFinancial({
    required this.grossEarnings,
    required this.netEarnings,
    required this.earningsChange,
    required this.occupancyRate,
  });

  final String grossEarnings;
  final String netEarnings;
  final int earningsChange;
  final int occupancyRate;

  factory HostFinancial.fromJson(Map<String, dynamic> json) {
    return HostFinancial(
      grossEarnings: json['gross_earnings']?.toString() ?? '0',
      netEarnings: json['net_earnings']?.toString() ?? '0',
      earningsChange: (json['earnings_change'] ?? 0) as int,
      occupancyRate: (json['occupancy_rate'] ?? 0) as int,
    );
  }
}

class HostBookingStats {
  const HostBookingStats({
    required this.total,
    required this.upcoming,
    required this.inStay,
    required this.completed,
    required this.cancelled,
  });

  final int total;
  final int upcoming;
  final int inStay;
  final int completed;
  final int cancelled;

  factory HostBookingStats.fromJson(Map<String, dynamic> json) {
    return HostBookingStats(
      total: (json['total'] ?? 0) as int,
      upcoming: (json['upcoming'] ?? 0) as int,
      inStay: (json['in_stay'] ?? 0) as int,
      completed: (json['completed'] ?? 0) as int,
      cancelled: (json['cancelled'] ?? 0) as int,
    );
  }
}

class HostRating {
  const HostRating({
    required this.average,
    required this.totalReviews,
  });

  final String average;
  final int totalReviews;

  factory HostRating.fromJson(Map<String, dynamic> json) {
    return HostRating(
      average: json['average']?.toString() ?? '0',
      totalReviews: (json['total_reviews'] ?? 0) as int,
    );
  }
}

class HostAlert {
  const HostAlert({
    required this.type,
    required this.icon,
    required this.title,
    required this.desc,
  });

  final String type;
  final String icon;
  final String title;
  final String desc;

  factory HostAlert.fromJson(Map<String, dynamic> json) {
    return HostAlert(
      type: json['type']?.toString() ?? 'info',
      icon: json['icon']?.toString() ?? 'info',
      title: json['title']?.toString() ?? '',
      desc: json['desc']?.toString() ?? '',
    );
  }
}

class RecentBooking {
  const RecentBooking({
    required this.id,
    required this.guestName,
    required this.propertyName,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    required this.amount,
  });

  final String id;
  final String guestName;
  final String propertyName;
  final String checkIn;
  final String checkOut;
  final String status;
  final String amount;

  factory RecentBooking.fromJson(Map<String, dynamic> json) {
    return RecentBooking(
      id: json['id']?.toString() ?? '',
      guestName: json['guest_name']?.toString() ?? 'Guest',
      propertyName: json['property_name']?.toString() ?? '',
      checkIn: json['check_in']?.toString() ?? '',
      checkOut: json['check_out']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      amount: json['amount']?.toString() ?? '',
    );
  }
}

class RecentReview {
  const RecentReview({
    required this.id,
    required this.guest,
    required this.date,
    required this.rating,
    required this.comment,
  });

  final int id;
  final String guest;
  final String date;
  final double rating;
  final String comment;

  factory RecentReview.fromJson(Map<String, dynamic> json) {
    return RecentReview(
      id: (json['id'] ?? 0) as int,
      guest: json['guest']?.toString() ?? 'Guest',
      date: json['date']?.toString() ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      comment: json['comment']?.toString() ?? '',
    );
  }
}

class HostCharts {
  const HostCharts({
    this.weeklyEarnings = const [],
    this.bookingStatus = const [],
  });

  final List<WeeklyEarning> weeklyEarnings;
  final List<BookingStatusItem> bookingStatus;

  factory HostCharts.fromJson(Map<String, dynamic> json) {
    final weeklyRaw = json['weekly_earnings'] as List? ?? [];
    final statusRaw = json['booking_status'] as List? ?? [];
    return HostCharts(
      weeklyEarnings: weeklyRaw
          .map((e) =>
              WeeklyEarning.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      bookingStatus: statusRaw
          .map((e) =>
              BookingStatusItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class WeeklyEarning {
  const WeeklyEarning({
    required this.name,
    required this.earnings,
    required this.bookings,
  });

  final String name;
  final int earnings;
  final int bookings;

  factory WeeklyEarning.fromJson(Map<String, dynamic> json) {
    return WeeklyEarning(
      name: json['name']?.toString() ?? '',
      earnings: (json['earnings'] ?? 0) as int,
      bookings: (json['bookings'] ?? 0) as int,
    );
  }
}

class BookingStatusItem {
  const BookingStatusItem({
    required this.name,
    required this.value,
    required this.color,
  });

  final String name;
  final int value;
  final String color;

  factory BookingStatusItem.fromJson(Map<String, dynamic> json) {
    return BookingStatusItem(
      name: json['name']?.toString() ?? '',
      value: (json['value'] ?? 0) as int,
      color: json['color']?.toString() ?? '#666',
    );
  }
}

class ListingPerformance {
  const ListingPerformance({
    required this.id,
    required this.name,
    required this.image,
    required this.revenue,
    required this.occupancy,
    required this.rating,
    required this.reviews,
  });

  final int id;
  final String name;
  final String image;
  final int revenue;
  final int occupancy;
  final double rating;
  final int reviews;

  factory ListingPerformance.fromJson(Map<String, dynamic> json) {
    return ListingPerformance(
      id: (json['id'] ?? 0) as int,
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      revenue: (json['revenue'] ?? 0) as int,
      occupancy: (json['occupancy'] ?? 0) as int,
      rating: (json['rating'] ?? 0).toDouble(),
      reviews: (json['reviews'] ?? 0) as int,
    );
  }
}

class CalendarBooking {
  const CalendarBooking({
    required this.startDate,
    required this.endDate,
    required this.guest,
    required this.listing,
    required this.price,
  });

  final String startDate;
  final String endDate;
  final String guest;
  final String listing;
  final String price;

  factory CalendarBooking.fromJson(Map<String, dynamic> json) {
    return CalendarBooking(
      startDate: json['start_date']?.toString() ?? '',
      endDate: json['end_date']?.toString() ?? '',
      guest: json['guest']?.toString() ?? 'Guest',
      listing: json['listing']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }
}