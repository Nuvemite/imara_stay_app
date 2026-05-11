# Connecting Flutter App to Laravel Backend (Localhost)

## Important: Localhost Addresses

**Your app runs on a device/emulator, not on your computer.** So `localhost` or `127.0.0.1` in the app points to the **device itself**, not your Laravel server.

| Where app runs | Use this URL to reach your computer |
|----------------|--------------------------------------|
| **Android Emulator** | `http://10.0.2.2:8000` |
| **iOS Simulator** | `http://localhost:8000` or `http://127.0.0.1:8000` |
| **Physical device** (phone/tablet) | `http://YOUR_PC_IP:8000` (e.g. `http://192.168.1.5:8000`) |

### Get your PC's IP address
```bash
# Linux/Mac
hostname -I | awk '{print $1}'
# or
ifconfig | grep "inet "
# Windows
ipconfig
```

---

## Step 1: Start Your Laravel Backend

```bash
cd /path/to/your/laravel/project
php artisan serve
# Laravel runs at http://127.0.0.1:80004
```

---
192.168.8.224

## Step 2: Configure Flutter API Base URL

The base URL defaults to `http://10.0.2.2:8000/api` (Android emulator). Override at run time:

```bash
# Physical device (replace with your PC IP)
flutter run --dart-define=API_BASE_URL=http://192.168.1.5:8000/api --dart-define=USE_API=true

# iOS Simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api --dart-define=USE_API=true

# Android Emulator (default)
flutter run --dart-define=USE_API=true
```

**Without `USE_API=true`**, the app uses mock data. Set it to connect to your Laravel backend.

---

## Step 3: Laravel CORS (Required for Flutter)

Your Laravel app must allow requests from the Flutter app. In `config/cors.php`:

```php
'allowed_origins' => ['*'],  // For development only
// Or specify: ['http://10.0.2.2:8000', 'http://192.168.1.5:8000']
```

For Laravel 11+, check `bootstrap/app.php` for CORS middleware.

---

## Step 4: Android Cleartext Traffic (HTTP)

Android blocks plain HTTP by default. In `android/app/src/main/AndroidManifest.xml`:

```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

---

## Laravel API Shape Expected

The app expects `GET /api/properties` to return JSON like:

```json
{
  "data": [
    {
      "id": 1,
      "title": "Modern Westlands Apartment",
      "description": "...",
      "images": ["https://..."],
      "price_per_night": 8500,
      "location": "Westlands, Nairobi",
      "rating": 4.8,
      "reviews_count": 124,
      "category": "apartments",
      "is_verified": true,
      "amenities": ["Pool", "Gym"]
    }
  ]
}
```

Or a plain array. See `Property.fromJson` in `property_model.dart` for field mappings.

---

## Auth (Login / Register)

The app uses **email/password** auth with Laravel Sanctum.

### How login works (backend flow)

1. **Request:** Flutter sends `POST {API_BASE_URL}/login` with JSON body:
   ```json
   { "email": "user@example.com", "password": "secret" }
   ```
2. **Credentials:** Only **user credentials** are used — the **email** and **password** the user types on the login screen. There are no app-level API keys or separate “backend credentials” for login; the backend looks up the user in the `users` table by `email` and verifies the password (e.g. with Laravel’s `Hash::check()`).
3. **Backend:** Your Laravel API should:
   - Accept `email` and `password` from the request body.
   - Find the user: `User::where('email', $request->input('email'))->first()` (use the **string** `email` from the request, not user id or any other field).
   - Verify password and issue a Sanctum token; return `access_token` and `user` in the JSON response.
4. **Response:** The app expects HTTP 200 with JSON like:
   ```json
   { "access_token": "...", "token_type": "Bearer", "user": { "id", "name", "email", "phone", "role" } }
   ```
   The app then stores the token and user and uses the token in the `Authorization: Bearer ...` header for later API calls.

| Endpoint | Method | Body |
|----------|--------|------|
| `/api/login` | POST | `email`, `password` |
| `/api/register` | POST | `name`, `email`, `password`, `password_confirmation`, `role` (guest/host), `phone` (optional) |

**Response** (both): `{ "access_token": "...", "token_type": "Bearer", "user": { "id", "name", "email", "phone", "role" } }`

**Role-based routing:**
- `role: guest` → HomeScreen (browse properties)
- `role: host` → HostDashboardScreen

**Backend note:** Ensure the `users` table has a `role` column and that register sets it (e.g. `$user->update(['role' => $role])` after `assignRole`). For host registration, create `host_profiles` with `status: pending` and no KYC.

---

## Listing Creation (Host)

The app creates listings via `POST /api/listings`. The backend expects **IDs** for `listing_type_id`, `room_type_id`, `property_type_id`, and `amenities` (array of amenity IDs).

### Lookup Endpoints (Recommended)

Add these **GET** endpoints so the app can resolve slugs to IDs:

| Endpoint | Returns |
|----------|---------|
| `GET /api/listing-types` | `{ "data": [{ "id": 1, "name": "Homes", "slug": "homes" }, ...] }` |
| `GET /api/room-types` | `{ "data": [{ "id": 1, "name": "Entire place", "slug": "entire_place" }, ...] }` |
| `GET /api/property-types` | `{ "data": [{ "id": 1, "name": "Apartment", "slug": "apartment" }, ...] }` |
| `GET /api/amenities` | `{ "data": [{ "id": 1, "name": "WiFi", "slug": "wifi" }, ...] }` |

If these endpoints return 200 with data, the app will use the IDs. Otherwise it falls back to index-based IDs (which may not match your DB).

### POST /api/listings

**Body:** `listing_type_id`, `status_id`, `title`, `description`, `address_line_1`, `location`, `city`, `country`, `price_per_night`, `property_type_id`, `room_type_id`, `bedrooms`, `bathrooms`, `beds`, `max_guests`, `amenities` (array of int), `cleaning_fee` (optional).

---

## Quick Test

1. Start Laravel: `php artisan serve`
2. Run app with API: `flutter run --dart-define=USE_API=true`
3. For physical device, add: `--dart-define=API_BASE_URL=http://YOUR_IP:8000/api`
4. If you get connection errors, verify:
   - Laravel is running
   - You're using the correct URL for your setup
   - Firewall allows port 8000

---

## Troubleshooting: Login / Database Errors

### Error: `Access denied for user "root"@"loacalhost"` (SQLSTATE 1698)

**1. Fix the typo in Laravel `.env`**

Your database host is misspelled. In your **Laravel backend** project (where your API runs), edit `.env`:

```env
# Wrong (typo)
DB_HOST=loacalhost

# Correct
DB_HOST=localhost
```

Or use `127.0.0.1` if you prefer:

```env
DB_HOST=127.0.0.1
```

Then run `php artisan config:clear` and try again.

**2. Fix MySQL 1698 (root auth)**

On Linux, MySQL often uses `auth_socket` for `root`, so password-based connections fail. Two options:

- **Option A – Use a dedicated DB user (recommended)**  
  In MySQL, create a user with password auth and grant access to `imara_stay`:

  ```sql
  CREATE USER 'imara_stay'@'localhost' IDENTIFIED BY 'your_secure_password';
  GRANT ALL ON imara_stay.* TO 'imara_stay'@'localhost';
  FLUSH PRIVILEGES;
  ```

  Then in Laravel `.env`:

  ```env
  DB_USERNAME=imara_stay
  DB_PASSWORD=your_secure_password
  ```

- **Option B – Switch root to password auth**  
  In MySQL: `ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'your_root_password';`  
  Then set `DB_PASSWORD` in `.env` to that password.

**3. Fix wrong email in query (`1.kamauernest@gmail.com`)**

If the SQL shows `email = 1.kamauernest@gmail.com`, the backend is likely binding the wrong value (e.g. user id `1` instead of the email string). In your Laravel login code:

- Use the **request email** for the lookup, not the user id or any integer.
- Use parameter binding. For example with Laravel’s Auth / User model:

  ```php
  $user = User::where('email', $request->input('email'))->first();
  ```

  Ensure the login request sends `email` as a string in the JSON body (this app sends `email` and `password` in the POST body). If you use a custom login controller, avoid passing `$request->user()->id` or any numeric field into the `where('email', ...)` call.
