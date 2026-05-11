import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/properties/presentation/screens/home_screen.dart';
import 'package:imara_stay/features/saved/presentation/screens/wishlist_screen.dart';
import 'package:imara_stay/features/profile/presentation/screens/profile_screen.dart';
import 'package:imara_stay/features/saved/state/favourites_controller.dart';
import 'package:imara_stay/features/auth/state/auth_controller.dart';
import 'package:imara_stay/features/auth/models/auth_state.dart';
import 'package:imara_stay/features/auth/presentation/widgets/auth_dialogs.dart';

class GuestShellScreen extends ConsumerStatefulWidget {
  const GuestShellScreen({super.key});

  @override
  ConsumerState<GuestShellScreen> createState() => _GuestShellScreenState();
}

class _GuestShellScreenState extends ConsumerState<GuestShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const WishlistScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    // If tapping wishlists or profile, check auth
    if (index == 1 || index == 2) {
      final authState = ref.read(authProvider);
      if (authState.status != AuthStatus.authenticated) {
        // Prompt login for protected tabs
        AuthDialogs.showLoginPrompt(
          context,
          index == 1 ? 'Log in to view wishlists' : 'Log in to view profile',
          'You need an account to access this feature.',
        );
        return;
      }
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final favouriteIds = ref.watch(favouritesProvider);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.explore, 'Explore', 0),
            _buildNavItem(Icons.favorite_border, 'Wishlists', 1, badgeCount: favouriteIds.length),
            _buildNavItem(Icons.person_outline, 'Profile', 2),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {int? badgeCount}) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color: isActive ? AppTheme.primaryRed : AppTheme.greyText,
                ),
                if (badgeCount != null && badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: const TextStyle(
                          color: AppTheme.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppTheme.primaryRed : AppTheme.greyText,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
