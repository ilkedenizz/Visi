import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/url_capture_provider.dart';
import '../quick_add/quick_add_bottom_sheet.dart';

class MainScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScaffold({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends ConsumerState<MainScaffold> {
  StreamSubscription<String>? _shareSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initShareCapture();
    });
  }

  Future<void> _initShareCapture() async {
    final captureService = ref.read(urlCaptureServiceProvider);

    // 1. Cold Start Check
    final initialUrl = await captureService.getInitialSharedUrl();
    if (initialUrl != null && initialUrl.isNotEmpty && mounted) {
      QuickAddBottomSheet.processSharedUrl(context, ref, initialUrl);
    }

    // 2. Warm Start Stream Listener
    _shareSubscription = captureService.sharedUrlStream.listen((sharedUrl) {
      if (sharedUrl.isNotEmpty && mounted) {
        QuickAddBottomSheet.processSharedUrl(context, ref, sharedUrl);
      }
    });
  }

  @override
  void dispose() {
    _shareSubscription?.cancel();
    super.dispose();
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: widget.navigationShell,
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
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onTap,
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
                  label: 'Dilekler',
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
        onPressed: () => QuickAddBottomSheet.show(context),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
