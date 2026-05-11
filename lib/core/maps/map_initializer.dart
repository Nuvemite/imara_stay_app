import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

/// Initializes the Google Maps renderer for Android.
///
/// The renderer must be requested before creating any GoogleMap instances,
/// as it can be initialized only once per application context.
/// Using [AndroidMapRenderer.latest] enables the new map renderer with
/// improved performance and features.
Future<AndroidMapRenderer?> initializeMapRenderer() async {
  // Access platform implementation via google_maps_flutter
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;

  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    return mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  return null;
}

/// Call this from main() before runApp() to ensure the map renderer
/// is ready before any map widgets are built.
Future<void> ensureMapRendererInitialized() async {
  if (!kIsWeb) {
    await initializeMapRenderer();
  }
}
