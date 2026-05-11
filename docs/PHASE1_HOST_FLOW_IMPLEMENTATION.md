# Phase 1: Host Flow Implementation Plan

Concrete tasks and file structure for Host Dashboard, My Listings, and Host Account/Profile.

---

## Overview

| Feature | API | Priority |
|---------|-----|----------|
| Host Dashboard | `GET /api/host/dashboard` | 1 |
| My Listings | `GET /api/host/listings`, `PUT /api/host/listings/{id}/status`, `DELETE /api/listings/{id}` | 2 |
| Host Account/Profile | `GET /api/user`, `PUT /api/user`, `POST /api/user/avatar` | 3 |

---

## Architecture Pattern (Existing)

```
lib/features/[feature]/
├── models/           # Data classes
├── repository/       # API calls (uses ApiClient with token)
├── state/            # Riverpod StateNotifier + provider
└── presentation/
    ├── screens/      # Full screens
    └── widgets/      # Reusable UI components
```

---

## Task 1: Host Dashboard

### 1.1 Models

**File:** `lib/features/host/models/host_dashboard_model.dart`

```dart
// HostDashboardData - parsed from GET /api/host/dashboard
class HostDashboardData {
  final String userName;
  final HostFinancial financial;
  final HostBookingsStats bookings;
  final HostRating rating;
  final List<HostAlert> alerts;
  final List<RecentBooking> recentBookings;
  final List<RecentReview> recentReviews;
  final HostCharts? charts;
  final List<ListingPerformance>? listingPerformance;
  final List<CalendarBooking>? calendarBookings;
}

class HostFinancial {
  final String grossEarnings;
  final String netEarnings;
  final int earningsChange;  // % vs last month
  final int occupancyRate;
}

class HostBookingsStats {
  final int total;
  final int upcoming;
  final int inStay;
  final int completed;
  final int cancelled;
}

class HostAlert {
  final String type;   // 'urgent' | 'warning'
  final String icon;
  final String title;
  final String desc;
}

class RecentBooking {
  final String id;
  final String guestName;
  final String propertyName;
  final String checkIn;
  final String checkOut;
  final String status;
  final String amount;
}

class RecentReview { ... }
class HostCharts { ... }
class ListingPerformance { ... }
class CalendarBooking { ... }
```

### 1.2 Repository

**File:** `lib/features/host/repository/host_dashboard_repository.dart`

```dart
class HostDashboardRepository {
  HostDashboardRepository(this._getToken);

  final Future<String?> Function() _getToken;

  Future<HostDashboardData?> fetchDashboard() async {
    final token = await _getToken();
    if (token == null) return null;
    final client = ApiClient(token: token);
    final response = await client.get('/host/dashboard');
    if (response.statusCode != 200) return null;
    return HostDashboardData.fromJson(jsonDecode(response.body));
  }
}

final hostDashboardRepositoryProvider = Provider<HostDashboardRepository>((ref) {
  return HostDashboardRepository(() => AuthController.getStoredToken());
});
```

### 1.3 State

**File:** `lib/features/host/state/host_dashboard_controller.dart`

```dart
class HostDashboardState {
  final HostDashboardData? data;
  final bool isLoading;
  final String? error;
}

class HostDashboardController extends StateNotifier<HostDashboardState> {
  HostDashboardController(this._repository)
      : super(HostDashboardState(data: null, isLoading: true));

  final HostDashboardRepository _repository;

  Future<void> loadDashboard() async { ... }
  void refetch() => loadDashboard();
}

final hostDashboardProvider = StateNotifierProvider<HostDashboardController, HostDashboardState>(...);
```

### 1.4 Presentation

**File:** `lib/features/host/presentation/screens/host_dashboard_screen.dart` (replace existing)

- Welcome header: "Karibu, {userName}!"
- Action alerts section (urgent + warning cards)
- Financial stats row (earnings, occupancy, change %)
- Recent bookings list (tap → booking detail)
- Recent reviews list
- Optional: Simple bar chart for weekly earnings (use `fl_chart` if added)

**File:** `lib/features/host/presentation/widgets/host_alert_card.dart`

- Card with icon, title, desc, colored by type (urgent=red, warning=amber)

**File:** `lib/features/host/presentation/widgets/host_stat_card.dart`

- Reusable stat card (label, value, optional change %)

**File:** `lib/features/host/presentation/widgets/recent_booking_tile.dart`

- Row: guest name, property, dates, status, amount

---

## Task 2: My Listings (CRUD + Status)

### 2.1 Models

**File:** `lib/features/host/models/host_listing_model.dart`

```dart
class HostListing {
  final int id;
  final int listingTypeId;
  final String title;
  final String location;
  final double rating;
  final int reviewsCount;
  final String? imageUrl;
  final String status;      // 'Draft' | 'Live' | 'Pending' | 'Archived'
  final int views;
  final String? nextGuest;  // "Mar 15" or null
  final String lastEdited;
  final double pricePerNight;
  final int bedrooms;
  final int beds;
  final int bathrooms;
}

class HostListingsResponse {
  final List<HostListing> listings;
  final Map<String, int> countsByStatus;
  final Map<String, int> countsByType;
  final PaginationInfo pagination;
}
```

### 2.2 Repository

**File:** `lib/features/host/repository/host_listings_repository.dart`

```dart
class HostListingsRepository {
  Future<HostListingsResponse> fetchListings({
    String? status,      // 'live' | 'draft' | 'pending' | 'archived'
    int? listingTypeId,
    int page = 1,
    int perPage = 12,
  }) async { ... }

  Future<void> updateStatus(int listingId, String statusSlug) async {
    // PUT /api/host/listings/{id}/status  body: { status: 'live' | 'draft' | ... }
  }

  Future<void> deleteListing(int listingId) async {
    // DELETE /api/listings/{id}
  }
}
```

### 2.3 State

**File:** `lib/features/host/state/host_listings_controller.dart`

```dart
class HostListingsState {
  final List<HostListing> listings;
  final Map<String, int> countsByStatus;
  final bool isLoading;
  final String? error;
  final String selectedStatus;  // 'all' | 'live' | 'draft' | 'pending' | 'archived'
}

class HostListingsController extends StateNotifier<HostListingsState> {
  Future<void> loadListings() async { ... }
  void setStatusFilter(String status) { ... }
  Future<void> changeListingStatus(int id, String status) async { ... }
  Future<void> deleteListing(int id) async { ... }
}
```

### 2.4 Presentation

**File:** `lib/features/host/presentation/screens/host_listings_screen.dart`

- App bar: "My Listings"
- Status filter chips: All | Live | Draft | Pending | Archived
- Grid/List of listing cards
- Each card: image, title, location, status badge, rating, price
- Card actions: Edit (navigate to listing wizard or edit), Change status (bottom sheet), Delete (confirm dialog)
- FAB or button: "Add Listing" → `ListingTypeSelectionScreen`

**File:** `lib/features/host/presentation/widgets/host_listing_card.dart`

- Card with image, title, location, status chip, rating, price
- Long-press or menu: Change status, Delete

**File:** `lib/features/host/presentation/widgets/listing_status_bottom_sheet.dart`

- Bottom sheet with options: Make live, Save as draft, Archive

---

## Task 3: Host Account / Profile

### 3.1 Current State

- `ProfileScreen` and `EditProfileScreen` already exist
- `AuthController.updateProfile()` and `uploadAvatar()` call API
- Backend: `GET /api/user`, `PUT /api/user`
- **Note:** Backend may need `POST /api/user/avatar` if not present (Flutter uses this)

### 3.2 Tasks

1. **Verify backend avatar endpoint**
   - Check if `POST /api/user/avatar` exists; add route if missing
   - Backend AuthController should handle multipart `avatar` upload

2. **Ensure Profile works for Host**
   - Host flow should include Profile in navigation
   - ProfileScreen is shared (guest + host) – no changes needed if already accessible

3. **Host navigation structure**
   - Host needs bottom nav or drawer: Dashboard | Listings | Profile (and later Bookings, Messages)
   - Create `HostShellScreen` (like HomeScreen for guests) with bottom nav

---

## Task 4: Host Shell & Navigation

### 4.1 New Structure

**Current:** Host logs in → `HostDashboardScreen` (single screen, no nav)

**Target:** Host logs in → `HostShellScreen` with bottom nav:
- Dashboard (tab 0)
- Listings (tab 1)
- Profile (tab 2)

### 4.2 Files

**File:** `lib/features/host/presentation/screens/host_shell_screen.dart`

```dart
class HostShellScreen extends ConsumerStatefulWidget {
  // Bottom nav with 3 items: Dashboard, Listings, Profile
  // IndexedStack or PageView for tab content
  // Initial tab: 0 (Dashboard)
}
```

**File:** `lib/app_entry_point.dart` (update)

- Change: `role == UserRole.host` → `HostShellScreen` instead of `HostDashboardScreen`

---

## File Structure Summary

```
lib/features/host/
├── models/
│   ├── host_dashboard_model.dart      # NEW
│   └── host_listing_model.dart       # NEW
├── repository/
│   ├── host_dashboard_repository.dart # NEW
│   └── host_listings_repository.dart  # NEW
├── state/
│   ├── host_dashboard_controller.dart # NEW
│   └── host_listings_controller.dart  # NEW
└── presentation/
    ├── screens/
    │   ├── host_shell_screen.dart     # NEW (replaces direct HostDashboardScreen)
    │   ├── host_dashboard_screen.dart # REPLACE (full dashboard UI)
    │   └── host_listings_screen.dart  # NEW
    └── widgets/
        ├── host_alert_card.dart       # NEW
        ├── host_stat_card.dart        # NEW
        ├── recent_booking_tile.dart   # NEW
        ├── host_listing_card.dart     # NEW
        └── listing_status_bottom_sheet.dart # NEW
```

---

## Implementation Order

1. **Host Dashboard**
   - Models → Repository → State → Screen + widgets
   - Test with `GET /api/host/dashboard`

2. **Host Listings**
   - Models → Repository → State → Screen + widgets
   - Test with `GET /api/host/listings?status=live`

3. **Host Shell**
   - Create HostShellScreen with bottom nav
   - Wire Dashboard, Listings, Profile tabs
   - Update AppEntryPoint

4. **Profile**
   - Verify backend avatar endpoint
   - Profile already works; ensure it's in Host nav

---

## Dependencies

- `fl_chart` (optional, for charts): `flutter pub add fl_chart`
- Existing: `http`, `flutter_riverpod`, `cached_network_image`, `shared_preferences`

---

## API Reference (Backend)

| Endpoint | Method | Auth | Description |
|----------|--------|------|-------------|
| `/api/host/dashboard` | GET | Yes | Dashboard stats, alerts, recent bookings/reviews |
| `/api/host/listings` | GET | Yes | Host's listings, ?status=live\|draft\|pending\|archived |
| `/api/host/listings/{id}/status` | PUT | Yes | body: `{ "status": "live" \| "draft" \| "archived" }` |
| `/api/listings/{id}` | DELETE | Yes | Delete listing |
| `/api/user` | GET | Yes | Current user profile |
| `/api/user` | PUT | Yes | Update name, phone, bio |
| `/api/user/avatar` | POST | Yes | Multipart, field: `avatar` |

---

## Backend Checklist

- [ ] `POST /api/user/avatar` route exists (add if missing)
- [ ] `listing_statuses` table seeded (Draft, Live, Pending, Archived)
- [ ] Host role users can access `/api/host/*` routes
