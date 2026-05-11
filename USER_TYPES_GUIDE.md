# User Types Guide - Kenya BnB App

## Overview
The app supports multiple user types, each with different needs and access levels. This guide explains how user types are handled throughout the app.

---

## User Types

### 1. **Guest** (Default)
**Purpose**: Book and stay at properties

**Features**:
- Browse property listings
- View property details
- Book properties
- Leave reviews
- Manage bookings
- Use wishlist/favourites
- Message hosts
- View places nearby

**Dashboard/Home Screen**:
- Shows available properties for booking
- Search and filter properties
- View 3 listings per page with pagination
- Category filters (Apartments, Villas, etc.)

**Navigation**:
- Explore (Home)
- Wishlist
- Bookings
- Profile

---

### 2. **Host**
**Purpose**: List and manage properties

**Features**:
- List properties
- Manage property listings
- View bookings
- Respond to messages
- Manage pricing (including negotiation)
- View analytics/earnings
- Upload virtual tours
- Manage availability calendar

**Dashboard/Home Screen** (Future):
- Shows their own properties
- Quick stats (bookings, earnings, views)
- Recent bookings
- Messages from guests
- Property performance metrics

**Navigation** (Future):
- Dashboard
- My Properties
- Bookings
- Messages
- Earnings
- Profile

---

### 3. **Corporate/Govt Organizations** (Future)
**Purpose**: Bulk bookings for employees/officials

**Features**:
- Bulk booking interface
- Invoice generation
- Multiple property selection
- Approval workflows
- Expense tracking

---

### 4. **Hotels and Lodges** (Future)
**Purpose**: Professional accommodation providers

**Features**:
- Multiple property management
- Calendar sync
- Channel management
- Professional analytics
- Staff management

---

### 5. **Tour Companies** (Future)
**Purpose**: Book properties for tour groups

**Features**:
- Group bookings
- Multiple property selection
- Itinerary integration
- Bulk pricing

---

### 6. **Cleaners** (Future)
**Purpose**: Manage cleaning schedules

**Features**:
- View assigned properties
- Mark cleaning as complete
- Report issues
- Schedule management

---

## Current Implementation

### User Role Detection
User roles are stored in:
- `UserRole` enum (`lib/features/onboarding/models/onboarding_state.dart`)
- `AuthUser.role` field (`lib/features/auth/models/user_model.dart`)

### Role-Based UI (Future)
Currently, all users see the same Guest interface. When auth is implemented:

```dart
// Example: Role-based dashboard
Widget buildDashboard(UserRole role) {
  switch (role) {
    case UserRole.host:
      return HostDashboard();
    case UserRole.guest:
      return GuestDashboard();
    // ... other roles
  }
}
```

---

## Dashboard Differences

### Guest Dashboard (Current)
- **Shows**: Available properties for booking
- **Layout**: Property cards in grid/list
- **Pagination**: 3 properties per page
- **Filters**: Category, price, location
- **Actions**: View details, add to wishlist, book

### Host Dashboard (Future)
- **Shows**: Own properties, bookings, stats
- **Layout**: Stats cards + property list
- **Metrics**: Views, bookings, earnings
- **Quick Actions**: Add property, view bookings, respond to messages

---

## Implementation Notes

### Current State
- ✅ User role enum defined
- ✅ Auth user model includes role
- ✅ Onboarding captures role selection
- ⏳ Role-based UI (pending auth implementation)
- ⏳ Host dashboard (future feature)

### When Auth is Implemented
1. Check user role from `authProvider`
2. Show appropriate dashboard based on role
3. Filter properties (Hosts see their own, Guests see all available)
4. Show role-specific navigation items
5. Enable/disable features based on role

### Example Code (Future)
```dart
// In home_screen.dart
final userRole = ref.watch(authProvider).user?.role ?? UserRole.guest;

if (userRole == UserRole.host) {
  return HostHomeScreen();
} else {
  return GuestHomeScreen(); // Current implementation
}
```

---

## Pagination Implementation

### Current Behavior
- **Items per page**: 3 properties
- **Pagination controls**: Previous/Next buttons + page indicators
- **Reset on**: Category change, search
- **Shows**: "Page X of Y" indicator

### How It Works
1. `PropertyState` tracks `currentPage` and `itemsPerPage`
2. `paginatedProperties` getter returns current page items
3. Pagination controls update `currentPage`
4. UI automatically rebuilds with new page

---

## Testing Different User Types

### For Now (Without Auth)
Since auth is skipped, you can test different views by:
1. Manually changing role in mock data
2. Creating separate screens for testing
3. Using a debug toggle (future)

### When Auth is Ready
1. Login as different user types
2. Verify correct dashboard loads
3. Test role-specific features
4. Verify permissions/access control

---

## Future Enhancements

1. **Role Switching**: Allow users to have multiple roles
2. **Role-Specific Features**: Unlock features based on role
3. **Permissions**: Fine-grained access control
4. **Analytics**: Track behavior by user type
5. **Onboarding**: Role-specific onboarding flows

---

**Last Updated**: Today
**Status**: Guest dashboard implemented, Host dashboard pending
