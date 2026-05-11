import 'package:flutter/material.dart';

import 'package:imara_stay/features/host/presentation/screens/host_bookings_screen.dart';
import 'package:imara_stay/features/host/presentation/screens/host_dashboard_screen.dart';
import 'package:imara_stay/features/host/presentation/screens/host_listings_screen.dart';
import 'package:imara_stay/features/messages/presentation/screens/host_messages_screen.dart';
import 'package:imara_stay/features/profile/presentation/screens/profile_screen.dart';

/// Host shell with bottom nav: Dashboard | Listings | Bookings | Messages | Profile
class HostShellScreen extends StatefulWidget {
  const HostShellScreen({super.key});

  @override
  State<HostShellScreen> createState() => _HostShellScreenState();
}

class _HostShellScreenState extends State<HostShellScreen> {
  int _currentIndex = 0;

  static const List<({String label, IconData icon})> _tabs = [
    (label: 'Dashboard', icon: Icons.dashboard_outlined),
    (label: 'Listings', icon: Icons.home_work_outlined),
    (label: 'Bookings', icon: Icons.calendar_today),
    (label: 'Messages', icon: Icons.chat_bubble_outline),
    (label: 'Profile', icon: Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HostDashboardScreen(),
          HostListingsScreen(),
          HostBookingsScreen(),
          HostMessagesScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: _tabs
            .map(
              (t) => NavigationDestination(
                icon: Icon(t.icon),
                label: t.label,
              ),
            )
            .toList(),
      ),
    );
  }
}
