# Kenya BnB - Core Features Implementation Plan

## 🎯 Overview
This document outlines the implementation plan for core features of the Kenya BnB mobile app. We're building screens first (UI-only), with API integration points clearly marked for when the Laravel/PHP backend is ready.

---

## 📋 Feature List & Priority

### Phase 1: Core Discovery & Booking (Week 1)
1. ✅ **Dashboard/Home Screen** - Complete
2. ✅ **Property Listings** - Complete  
3. ✅ **Property Details Screen** - Complete (with image zoom)
4. ✅ **Virtual Tours** - Complete (360° viewer)
5. 🔄 **Places Near Me** - Pending
6. 🔄 **Price Sliders/Filters** - Pending

### Phase 2: User Engagement (Week 1-2)
7. 🔄 **Wishlist** - Pending
8. 🔄 **Favourites** - Pending
9. 🔄 **Reviews System** - Pending
10. 🔄 **Map & Route Navigation** - Pending

### Phase 3: Communication & Payments (Week 2)
11. 🔄 **In-App Messaging** - Pending
12. 🔄 **In-App Notifications** - Pending
13. 🔄 **Payment Screens (M-Pesa & Card)** - Pending

---

## 🏗️ Architecture Decisions

### State Management: Riverpod
- **Why**: Type-safe, testable, scales well
- **Pattern**: StateNotifier for complex state, Provider for simple values
- **Location**: `features/[feature]/state/[feature]_controller.dart`

### Navigation: GoRouter (Recommended)
- **Why**: Declarative routing, deep linking support, type-safe
- **Alternative**: Navigator 2.0 (built-in, more verbose)
- **Package**: `go_router: ^14.0.0`

### Folder Structure
```
lib/
├── main.dart
├── app_entry_point.dart
├── core/
│   ├── theme/
│   ├── router/          # Navigation setup
│   ├── services/        # API clients, storage, etc.
│   └── utils/           # Helpers, extensions
└── features/
    ├── properties/      # Listings, details, virtual tours
    ├── places/          # Places near me
    ├── wishlist/        # Wishlist feature
    ├── favourites/      # Favourites feature
    ├── reviews/         # Reviews system
    ├── map/             # Map & navigation
    ├── messaging/       # In-app messages
    ├── notifications/   # Push notifications
    └── payments/        # Payment screens
```

---

## 📱 Feature Specifications

### 1. Property Details Screen

**Purpose**: Show full property information, images, amenities, host info, virtual tour, reviews, booking CTA

**Key Components**:
- Image carousel with zoom
- Property info (title, location, rating, price)
- Host profile card
- Amenities grid
- Virtual tour button/embed
- Reviews section (preview)
- "Places Near Me" preview
- Price negotiation button (unique feature!)
- Book Now button
- Share button

**Flutter Implementation**:
- `flutter_image_carousel` or custom PageView
- `photo_view` for zoom functionality
- `cached_network_image` for image caching
- Custom scrollable layout with SliverAppBar

**API Endpoints** (Future):
- `GET /api/properties/{id}` - Property details
- `GET /api/properties/{id}/reviews` - Reviews list
- `GET /api/properties/{id}/nearby-places` - Nearby places

---

### 2. Virtual Tours

**Purpose**: Allow users to view 360° tours of rooms/properties

**Implementation Options**:

**Option A: 360° Image Viewer** (Simpler, faster to implement)
- Use `photo_view` with 360° images
- Swipe/pan to rotate view
- Works offline, fast loading
- **Package**: `photo_view: ^0.14.0`

**Option B: WebView Integration** (More immersive)
- Embed Matterport/Google Street View iframe
- Requires internet, more complex
- **Package**: `webview_flutter: ^4.4.0`

**Option C: Custom 360° Viewer** (Best UX, most work)
- Use `flutter_panorama` or similar
- Native feel, smooth performance
- **Package**: `flutter_panorama: ^0.2.0`

**Recommendation**: Start with Option A (360° images), upgrade to Option C later

**UI Components**:
- Full-screen viewer
- Navigation controls (rotate, zoom)
- Room selector (if multiple rooms)
- Exit button

**API Endpoints** (Future):
- `GET /api/properties/{id}/virtual-tour` - Tour data/images

---

### 3. Places Near Me

**Purpose**: Show nearby restaurants, bars, supermarkets, attractions, etc.

**Categories**:
- 🍽️ Restaurants
- 🍺 Bars & Clubs
- 🛒 Supermarkets
- ⛽ Gas Stations
- 🏞️ Parks & Attractions
- 🏥 Hospitals/Clinics
- 🏦 Banks/ATMs
- 🚕 Transport (Uber, matatu stops)

**Implementation**:
- Use Google Places API (via backend)
- Show on map view
- List view with categories
- Distance calculation
- Filter by category
- Search functionality

**Flutter Packages**:
- `google_maps_flutter: ^2.5.0` - Map display
- `geolocator: ^10.1.0` - User location
- `geocoding: ^2.1.1` - Address conversion

**UI Components**:
- Map view with markers
- Category filter chips
- List view with distance
- Place detail card (name, rating, distance, hours)

**API Endpoints** (Future):
- `GET /api/places/nearby?lat={lat}&lng={lng}&category={category}` - Nearby places
- `GET /api/places/{id}` - Place details

---

### 4. Wishlist & Favourites

**Purpose**: Allow users to save properties for later

**Difference**:
- **Wishlist**: Temporary, for trip planning (can have multiple lists)
- **Favourites**: Permanent, quick access to loved properties

**Implementation**:
- Local storage (SharedPreferences) for offline access
- Sync with backend when available
- Heart icon on property cards
- Dedicated screens for both

**State Management**:
- Separate providers: `wishlistProvider`, `favouritesProvider`
- Methods: `addToWishlist()`, `removeFromWishlist()`, `addToFavourites()`, etc.

**UI Components**:
- Wishlist screen (grid/list view)
- Favourites screen
- Empty states
- Share wishlist functionality

**API Endpoints** (Future):
- `POST /api/wishlist/add` - Add to wishlist
- `GET /api/wishlist` - Get wishlist
- `POST /api/favourites/add` - Add to favourites
- `GET /api/favourites` - Get favourites

---

### 5. Price Sliders & Filters

**Purpose**: Filter properties by price range, amenities, location, etc.

**Filters**:
- Price range (slider)
- Location (search/select)
- Property type (category)
- Amenities (checkboxes)
- Rating (minimum)
- Instant booking (toggle)
- Verified hosts only (toggle)

**Implementation**:
- Custom slider widget for price
- Filter bottom sheet/modal
- Apply/Clear buttons
- Active filters indicator

**Flutter Packages**:
- `flutter_range_slider: ^1.5.0` or custom slider
- Custom filter sheet widget

**UI Components**:
- Filter button (shows count of active filters)
- Filter modal/bottom sheet
- Price range slider
- Checkbox lists for amenities
- Location search field

**State Management**:
- `PropertyFilterState` in property controller
- Methods: `applyFilters()`, `clearFilters()`, `updatePriceRange()`

---

### 6. Reviews System

**Purpose**: Show and allow users to leave reviews

**Components**:
- Review list (on property details)
- Review card (avatar, name, rating, text, date, photos)
- Add review screen
- Review summary (average rating, breakdown by stars)
- Photo upload for reviews

**Implementation**:
- Image picker for photos
- Rating widget (stars)
- Rich text editor (optional)
- Pagination for review list

**Flutter Packages**:
- `image_picker: ^1.0.4` - Photo selection
- `flutter_rating_bar: ^4.0.1` - Star ratings
- `cached_network_image: ^3.3.0` - Review images

**UI Components**:
- Review card widget
- Review form screen
- Rating breakdown chart
- Photo gallery in reviews

**API Endpoints** (Future):
- `GET /api/properties/{id}/reviews` - Get reviews
- `POST /api/reviews` - Create review
- `POST /api/reviews/{id}/photos` - Upload review photos

---

### 7. Map & Route Navigation

**Purpose**: Show property location on map, get directions

**Features**:
- Map view with property markers
- User location
- Route calculation
- Navigation integration (Google Maps, Apple Maps)
- Multiple properties on map

**Implementation**:
- Google Maps integration
- Marker clustering for multiple properties
- Custom markers with property images
- Route polyline display

**Flutter Packages**:
- `google_maps_flutter: ^2.5.0` - Map display
- `google_maps_flutter_platform_interface: ^2.3.0`
- `geolocator: ^10.1.0` - Location services
- `url_launcher: ^6.2.1` - Open external maps

**UI Components**:
- Map screen
- Property marker (custom icon with image)
- Route preview
- "Open in Maps" button
- Distance/duration display

**API Endpoints** (Future):
- Backend can provide coordinates, or use Google Maps API directly from Flutter

---

### 8. In-App Messaging

**Purpose**: Allow guests and hosts to communicate

**Features**:
- Chat list (conversations)
- Chat screen (messages)
- Send text messages
- Send images
- Read receipts
- Typing indicators
- Message status (sent, delivered, read)

**Implementation**:
- Real-time updates (WebSocket via backend)
- Local message storage
- Image picker for photos
- Push notifications for new messages

**Flutter Packages**:
- `flutter_chat_ui: ^1.6.0` - Pre-built chat UI (recommended)
- OR custom chat UI with `ListView` + `TextField`
- `image_picker: ^1.0.4` - Image selection
- `socket_io_client: ^2.0.3` - WebSocket (when backend ready)

**UI Components**:
- Chat list screen
- Chat screen
- Message bubble widget
- Image message widget
- Input field with send button

**API Endpoints** (Future):
- `GET /api/conversations` - Get chat list
- `GET /api/conversations/{id}/messages` - Get messages
- `POST /api/messages` - Send message
- `WebSocket /ws` - Real-time updates

---

### 9. In-App Notifications

**Purpose**: Show app notifications (booking updates, messages, etc.)

**Types**:
- Booking confirmations
- Booking updates
- New messages
- Review requests
- Price negotiation updates
- Promotional offers

**Implementation**:
- Local notifications (for in-app)
- Push notifications (via FCM when backend ready)
- Notification center/bell icon
- Badge count
- Notification list screen

**Flutter Packages**:
- `flutter_local_notifications: ^16.3.0` - Local notifications
- `firebase_messaging: ^14.7.0` - Push notifications (when backend ready)
- `badges: ^3.1.2` - Badge on icon

**UI Components**:
- Notification bell icon (with badge)
- Notification list screen
- Notification card (type, message, time, action)
- Empty state

**State Management**:
- `NotificationState` with list of notifications
- Methods: `markAsRead()`, `clearAll()`, `getUnreadCount()`

**API Endpoints** (Future):
- `GET /api/notifications` - Get notifications
- `PUT /api/notifications/{id}/read` - Mark as read
- `DELETE /api/notifications/{id}` - Delete notification

---

### 10. Payment Screens (M-Pesa & Card)

**Purpose**: Handle payment UI (actual processing via backend)

**Payment Methods**:
1. **M-Pesa** (Primary for Kenya)
   - Phone number input
   - Amount display
   - STK Push initiation
   - Payment status tracking

2. **Card Payment**
   - Card details form
   - CVV, expiry
   - Card type detection
   - Secure input (masked)

**Implementation**:
- Payment method selector
- M-Pesa screen (phone input, amount, confirm)
- Card payment screen (form)
- Payment status screen (loading, success, failure)
- Payment history

**Flutter Packages**:
- `flutter_paystack: ^1.0.7` - Card payments (Paystack integration)
- OR `stripe_payment: ^1.1.4` - Stripe integration
- Custom M-Pesa UI (backend handles actual M-Pesa API)

**UI Components**:
- Payment method selector
- M-Pesa payment screen
- Card payment form
- Payment status screen
- Receipt screen

**Security Notes**:
- Never store card details locally
- All payment processing via backend
- Use secure input fields
- Show payment confirmation

**API Endpoints** (Future):
- `POST /api/payments/mpesa/initiate` - Initiate M-Pesa payment
- `POST /api/payments/card/initiate` - Initiate card payment
- `GET /api/payments/{id}/status` - Check payment status
- `GET /api/payments/history` - Payment history

---

## 🗓️ 2-Week Implementation Timeline

### Week 1: Core Features

**Day 1-2: Property Details & Virtual Tours**
- [ ] Property details screen
- [ ] Image carousel with zoom
- [ ] Virtual tour viewer (360° images)
- [ ] Host profile section
- [ ] Amenities display

**Day 3: Places Near Me**
- [ ] Places model and state
- [ ] Map integration setup
- [ ] Places list screen
- [ ] Category filters
- [ ] Place detail card

**Day 4: Wishlist & Favourites**
- [ ] Wishlist state management
- [ ] Favourites state management
- [ ] Wishlist screen
- [ ] Favourites screen
- [ ] Add/remove functionality

**Day 5: Filters & Price Slider**
- [ ] Filter state model
- [ ] Price range slider
- [ ] Filter bottom sheet
- [ ] Apply filters logic
- [ ] Active filters indicator

### Week 2: Engagement & Payments

**Day 6-7: Reviews System**
- [ ] Review model
- [ ] Review list display
- [ ] Review card widget
- [ ] Add review screen
- [ ] Rating widget
- [ ] Photo upload

**Day 8: Map & Navigation**
- [ ] Map screen
- [ ] Property markers
- [ ] Route calculation UI
- [ ] "Open in Maps" integration
- [ ] Distance display

**Day 9: Messaging**
- [ ] Chat list screen
- [ ] Chat screen UI
- [ ] Message bubble widget
- [ ] Input field
- [ ] Image picker integration

**Day 10: Notifications**
- [ ] Notification model
- [ ] Notification list screen
- [ ] Notification card
- [ ] Badge on bell icon
- [ ] Mark as read functionality

**Day 11-12: Payment Screens**
- [ ] Payment method selector
- [ ] M-Pesa payment screen
- [ ] Card payment form
- [ ] Payment status screens
- [ ] Payment history (optional)

**Day 13-14: Polish & Testing**
- [ ] Navigation between screens
- [ ] Empty states
- [ ] Loading states
- [ ] Error handling UI
- [ ] Final testing

---

## 📦 Required Dependencies

Add these to `pubspec.yaml`:

```yaml
dependencies:
  # Existing
  flutter_riverpod: ^2.4.9
  shared_preferences: ^2.2.2
  
  # Navigation
  go_router: ^14.0.0  # Or use Navigator 2.0
  
  # Images & Media
  cached_network_image: ^3.3.0
  photo_view: ^0.14.0
  image_picker: ^1.0.4
  
  # Maps & Location
  google_maps_flutter: ^2.5.0
  geolocator: ^10.1.0
  geocoding: ^2.1.1
  
  # UI Components
  flutter_rating_bar: ^4.0.1
  flutter_range_slider: ^1.5.0  # Or custom slider
  badges: ^3.1.2
  
  # Chat (optional - can build custom)
  flutter_chat_ui: ^1.6.0
  
  # Notifications
  flutter_local_notifications: ^16.3.0
  
  # Payments (when backend ready)
  # flutter_paystack: ^1.0.7
  # OR
  # stripe_payment: ^1.1.4
  
  # Utilities
  url_launcher: ^6.2.1
  intl: ^0.19.0  # Date formatting
```

---

## 🎨 Design Guidelines

### Colors (Already defined in `app_theme.dart`)
- Primary Red: `#E63946`
- Secondary Green: `#006B3D`
- Accent Orange: `#F77F00`

### Typography
- Use theme text styles
- Swahili greetings: "Habari" (Hello), "Asante" (Thank you)

### Icons
- Material Icons (built-in)
- Consider `flutter_svg` for custom icons later

### Spacing
- Use `AppSpacing` constants
- Consistent padding/margins

---

## 🔌 API Integration Points

All API calls will be made through a service layer:

```dart
// lib/core/services/api_service.dart
class ApiService {
  static const String baseUrl = 'https://your-backend.com/api';
  
  // Properties
  Future<List<Property>> getProperties();
  Future<Property> getPropertyDetails(String id);
  
  // Places
  Future<List<Place>> getNearbyPlaces(double lat, double lng);
  
  // Reviews
  Future<List<Review>> getReviews(String propertyId);
  Future<void> createReview(Review review);
  
  // ... etc
}
```

**For now**: Use mock data in controllers. When backend is ready, replace mock data with API calls.

---

## ✅ Next Steps

1. ✅ Update `app_entry_point.dart` to skip auth
2. ✅ Create this feature plan
3. 🔄 Update `pubspec.yaml` with dependencies
4. 🔄 Start building Property Details Screen
5. Continue with other features in order

---

## 📝 Notes

- All screens are UI-only for now
- Mock data in controllers
- API integration points clearly marked
- Follow existing architecture patterns
- Keep code clean and commented
- Test each feature as you build

---

**Last Updated**: Today
**Status**: In Progress
**Next Feature**: Property Details Screen
