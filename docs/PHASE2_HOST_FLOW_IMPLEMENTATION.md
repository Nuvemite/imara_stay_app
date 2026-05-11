# Phase 2: Host Flow Implementation Plan

Continues from Phase 1. Focus: Host Profile, Host Bookings.

---

## Overview

| Feature | API | Priority |
|---------|-----|----------|
| Host Profile | `GET /api/user`, `PUT /api/user`, `POST /api/user/avatar` | 1 |
| Host Bookings | `GET /api/host/bookings`, `POST /api/host/bookings/{id}/approve`, `POST /api/host/bookings/{id}/reject`, `POST /api/host/bookings/{id}/cancel` | 2 |

---

## Task 1: Host Profile

### 1.1 Current State

- `ProfileScreen` and `EditProfileScreen` exist
- AuthController has `updateProfile()` and `uploadAvatar()`
- Host shell has placeholder for Profile tab

### 1.2 Task

- Replace `_HostProfilePlaceholder` in `HostShellScreen` with `ProfileScreen`
- ProfileScreen already has: avatar, name, email, phone, bio, role badge, logout
- No code changes to ProfileScreen needed – it works for both guest and host

---

## Task 2: Host Bookings

### 2.1 API

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/host/bookings` | GET | List host's bookings. Query: `?status=upcoming|past|canceled|pending|all&page=1&per_page=12` |
| `/api/host/bookings/{id}` | GET | Booking detail |
| `/api/host/bookings/{id}/approve` | POST | Approve pending booking |
| `/api/host/bookings/{id}/reject` | POST | Reject pending booking |
| `/api/host/bookings/{id}/cancel` | POST | Cancel confirmed upcoming booking |

### 2.2 Response (hostIndex)

```json
{
  "bookings": [
    {
      "id": 1,
      "listing": { "id", "title", "location", "address", "image", "listing_type_id" },
      "guest": { "id", "name", "email", "avatar_url" },
      "check_in": "Mar 15, 2025",
      "check_out": "Mar 18, 2025",
      "start_date": "2025-03-15",
      "end_date": "2025-03-18",
      "nights": 3,
      "guests": { "adults", "children", "infants", "pets", "total" },
      "status": "pending" | "confirmed" | "canceled",
      "total_price": 15000,
      "payment_status": "paid" | "pending",
      "can_approve": true,
      "can_reject": true,
      "can_cancel": false,
      "is_upcoming": true,
      "is_past": false,
      "time_slot": null,
      "service_offering": null
    }
  ],
  "pagination": { "current_page", "per_page", "total", "last_page" }
}
```

### 2.3 Files

```
lib/features/host/
├── models/
│   └── host_booking_model.dart      # NEW
├── repository/
│   └── host_bookings_repository.dart # NEW
├── state/
│   └── host_bookings_controller.dart # NEW
└── presentation/
    ├── screens/
    │   └── host_bookings_screen.dart  # NEW
    └── widgets/
        └── host_booking_card.dart     # NEW
```

### 2.4 Host Shell Update

- Add Bookings tab: Dashboard | Listings | Bookings | Profile (4 tabs)
- Or: Dashboard | Listings | Profile, with Bookings accessible from Dashboard

**Decision:** Add Bookings as 4th tab for direct access.

---

## Implementation Order

1. Replace Profile placeholder with ProfileScreen
2. Host Bookings: models → repository → state → screen + card
3. Add Bookings tab to HostShellScreen
