import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_entry_point.dart';
import 'core/maps/map_initializer.dart';
import 'core/theme/app_theme.dart';

/// Entry point - where Flutter starts
void main() async {
  // Ensure Flutter bindings are initialized before any async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Maps renderer before any map widgets are created.
  // Required for Android - the renderer can only be initialized once per app.
  await ensureMapRendererInitialized();

  // Wrap the entire app in ProviderScope
  // This is like Redux Provider or Context Provider
  // It makes all providers available to the widget tree
  runApp(const ProviderScope(child: KenyaBnBApp()));
}

/// Root app widget
/// This is clean, focused, does one thing:
/// Sets up MaterialApp with theme and entry point
class KenyaBnBApp extends StatelessWidget {
  const KenyaBnBApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // App metadata
      title: 'Kenya BnB',
      debugShowCheckedModeBanner: false, // Remove debug banner
      // Theme
      theme: AppTheme.light,

      // Entry point - let it decide where to go
      home: const AppEntryPoint(),
    );
  }
}
