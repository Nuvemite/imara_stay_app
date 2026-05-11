import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:imara_stay/core/theme/app_theme.dart';
import 'package:imara_stay/features/onboarding/models/onboarding_content.dart';
import 'package:imara_stay/features/onboarding/state/onboarding_controller.dart';
import 'package:imara_stay/features/onboarding/presentation/widgets/onboarding_page_widget.dart';
import 'package:imara_stay/features/onboarding/presentation/widgets/page_indicator.dart';
import 'role_selection_screen.dart';

/// OnboardingScreen - The carousel that users swipe through
/// This is a "smart" widget - it reads state and dispatches actions
///
/// In React terms: const OnboardingScreen = () => {
///   const dispatch = useDispatch();
///   const state = useSelector(...);
///   ...
/// }
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

/// Why ConsumerStatefulWidget?
/// - We need a PageController (stateful)
/// - We need access to Riverpod providers (Consumer)
///
/// This is like combining useState + useSelector in React
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // PageController manages the PageView
  // It's like a ref to a scrollable view
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    // CRITICAL: Always dispose controllers to prevent memory leaks
    // Flutter doesn't have automatic cleanup like React useEffect
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read state from provider
    // Like: const state = useSelector(state => state.onboarding)
    final state = ref.watch(onboardingProvider);

    // Get the controller to dispatch actions
    // Like: const dispatch = useDispatch()
    final controller = ref.read(onboardingProvider.notifier);

    return Scaffold(
      body: Stack(
        children: [
          // PageView - swipeable carousel
          // Like a horizontal ScrollView in React Native
          PageView.builder(
            controller: _pageController,
            itemCount: OnboardingContent.pageCount,
            onPageChanged: (index) {
              // Update state when user swipes
              controller.goToPage(index);
            },
            itemBuilder: (context, index) {
              final page = OnboardingContent.getPage(index);
              return OnboardingPageWidget(page: page);
            },
          ),

          // Skip button (top right)
          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.md,
            right: AppSpacing.md,
            child: TextButton(
              onPressed: () {
                _navigateToRoleSelection();
              },
              child: const Text(
                'Skip',
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: AppSpacing.xl,
                right: AppSpacing.xl,
                bottom: MediaQuery.of(context).padding.bottom + AppSpacing.lg,
                top: AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator dots
                  PageIndicator(
                    currentPage: state.currentPage,
                    totalPages: OnboardingContent.pageCount,
                    activeColor: AppTheme.white,
                    inactiveColor: AppTheme.white.withOpacity(0.3),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (hidden on first page)
                      if (state.currentPage > 0)
                        IconButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: AppTheme.white,
                            size: 28,
                          ),
                        )
                      else
                        const SizedBox(width: 48), // Spacer for alignment
                      // Next/Get Started button
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              if (state.isLastPage) {
                                _navigateToRoleSelection();
                              } else {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.white,
                              foregroundColor: OnboardingContent.getPage(
                                state.currentPage,
                              ).backgroundColor,
                            ),
                            child: Text(
                              state.isLastPage ? 'Get Started' : 'Next',
                            ),
                          ),
                        ),
                      ),

                      // Forward button (hidden on last page)
                      if (!state.isLastPage)
                        IconButton(
                          onPressed: () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_forward,
                            color: AppTheme.white,
                            size: 28,
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRoleSelection() {
    // Push (not replace) so AppEntryPoint stays in stack for auth routing
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }
}
