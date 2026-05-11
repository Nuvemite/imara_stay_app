import 'package:flutter/material.dart';

/// OnboardingPage - represents one slide in the carousel
/// This is pure data - no UI logic
class OnboardingPage {
  final String title;
  final String description;
  final IconData icon; // In production, use images/lottie animations
  final Color backgroundColor;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}

/// Onboarding content
/// This is like your static data or CMS content
/// Change text here without touching UI code
class OnboardingContent {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Discover Authentic Stays',
      description:
          'Find unique accommodations across Kenya, from cozy Nairobi apartments to beachfront Mombasa villas. Experience genuine Kenyan hospitality.',
      icon: Icons.home_rounded,
      backgroundColor: Color(0xFFE63946), // Primary Red
    ),
    OnboardingPage(
      title: 'Book with Confidence',
      description:
          'Verified hosts, secure payments via M-Pesa, and real reviews from fellow travelers. Your safety is our priority.',
      icon: Icons.verified_user_rounded,
      backgroundColor: Color(0xFF006B3D), // Secondary Green
    ),
    OnboardingPage(
      title: 'Negotiate Your Price',
      description:
          'Unlike other platforms, you can negotiate directly with hosts to find the perfect price for your stay. Fair pricing for everyone.',
      icon: Icons.handshake_rounded,
      backgroundColor: Color(0xFFF77F00), // Accent Orange
    ),
  ];

  /// Get page by index safely
  static OnboardingPage getPage(int index) {
    if (index < 0 || index >= pages.length) {
      return pages[0];
    }
    return pages[index];
  }

  /// Total number of pages
  static int get pageCount => pages.length;
}