import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/preferences_provider.dart';
import '../../widgets/visi_cherry_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() async {
    HapticFeedback.mediumImpact();
    await ref.read(preferencesProvider.notifier).completeOnboarding();
    if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const VisiCherryLogo(size: 24, color: AppColors.cherryAccent),
                      const SizedBox(width: 8),
                      Text(
                        'VISI',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.deepPlum,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < 2)
                    TextButton(
                      onPressed: _onFinish,
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      child: const Text(
                        'Atla',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    )
                  else
                    const SizedBox(height: 48),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildScreen1(theme, isDark),
                  _buildScreen2(theme, isDark),
                  _buildScreen3(theme, isDark),
                ],
              ),
            ),

            // Bottom Navigation Area (Indicators + Action Button)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.cherryAccent
                              : (isDark ? AppColors.darkCardBorder : AppColors.blushPink),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),

                  // Main Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _onFinish();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.cherryAccent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? 'Visi\'yi Keşfet ✨' : 'Devam Et',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScreen1(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.blushPink,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.cherryAccent.withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: VisiCherryLogo(size: 56, color: AppColors.cherryAccent),
            ),
          ),
          const SizedBox(height: 40),

          Text(
            'Dileklerini unutma.',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Bir gün yapmak, öğrenmek veya görmek istediğin şeyleri Visi\'de biriktir.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen2(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.blushPink,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🎸', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Küçük veya büyük fark etmez.',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Bir gitar öğrenmek de bir dilektir. Japonya\'ya gitmek de.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen3(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.blushPink,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: VisiCherryLogo(
                size: 48,
                color: AppColors.cherryAccent,
              ),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Bir gün, gerçek olur. ✨',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),

          Text(
            'Dileklerini sakla, zamanı geldiğinde onlara geri dön.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 15,
              height: 1.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
