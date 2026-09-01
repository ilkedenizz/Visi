import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: BottomNavigationBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => _onTap(context, index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: isDark ? AppColors.cherryAccentDark : AppColors.cherryAccent,
              unselectedItemColor: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined, size: 22),
                  activeIcon: Icon(Icons.grid_view_rounded, size: 22),
                  label: 'Ana Sayfa',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.favorite_outline_rounded, size: 22),
                  activeIcon: Icon(Icons.favorite_rounded, size: 22),
                  label: 'Wishlist',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.style_outlined, size: 22),
                  activeIcon: Icon(Icons.style_rounded, size: 22),
                  label: 'Koleksiyonlar',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline_rounded, size: 22),
                  activeIcon: Icon(Icons.person_rounded, size: 22),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-item'),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
