# How to Get Your Google Maps API Key

This guide explains how to obtain an API key for Google Maps in your Imara Stay app.

---

## Prerequisites

- A Google account
- Your Google Cloud project (e.g. "imara stay") created

---

## Step 1: Open APIs & Services

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project from the dropdown (e.g. **imara stay**)
3. Click **APIs and services** in the Quick access section (or use the hamburger menu → APIs & Services)

---

## Step 2: Enable the Maps SDK

1. In the left sidebar, click **Library**
2. Search for **Maps SDK for Android**
3. Click on **Maps SDK for Android**
4. Click **Enable**

> **Optional**: If you plan to use Places API later, also enable **Places API** and **Geocoding API**.

---

## Step 3: Create an API Key

1. In the left sidebar, click **Credentials**
2. Click **+ CREATE CREDENTIALS** at the top
3. Select **API key**
4. Your API key will be generated and displayed in a dialog
5. Click **Copy** to copy the key
6. Click **Close**

---

## Step 4: (Recommended) Restrict the Key

1. In the Credentials page, find your new API key and click it
2. Under **Application restrictions**, select **Android apps**
3. Click **Add an item**
4. Enter your app’s package name: `com.example.imara_stay`
5. Add your SHA-1 fingerprint (get it with `cd android && ./gradlew signingReport`)
6. Click **Save**

---

## Step 5: Add the Key to Your App

1. Open `android/app/src/main/AndroidManifest.xml`
2. Find the line: `android:value="YOUR_GOOGLE_MAPS_API_KEY"`
3. Replace `YOUR_GOOGLE_MAPS_API_KEY` with your copied API key

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="AIzaSy...your-actual-key-here" />
```

---

## Step 6: Run the App

```bash
flutter pub get
flutter run
```

The map should now load correctly in the Places Near Me screen.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Map shows gray/blank | Ensure Maps SDK for Android is enabled and the key is correct |
| "This page can't load Google Maps correctly" | Check API key restrictions; ensure package name and SHA-1 match |
| Key not working | Wait a few minutes after creating the key; clear app data and reinstall |

---

## Security Notes

- **Do not** commit your API key to public repositories
- Use **restrictions** (Android apps, package name, SHA-1) to limit key usage
- For production, consider using environment variables or a secrets manager

---

## Billing

Google Maps has a free tier. New projects get $200/month in free credit. Monitor usage in **Billing** → **Reports** in the Cloud Console.
