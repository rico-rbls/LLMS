/// lib/screens/main_layout.dart
/// Post-login shell: IndexedStack body + 5-tab BottomNavigationBar.
/// The Scan tab (index 2) renders as a raised purple FAB-style button.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/colors.dart';
import '../config/theme.dart';
import '../providers/nav_provider.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'qr_scan_screen.dart';
import 'borrowed_screen.dart';
import 'profile_screen.dart';

class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  static const _screens = [
    HomeScreen(),
    SearchScreen(),
    QrScanScreen(),
    BorrowedScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _LibLogBottomNav(
        currentIndex: currentIndex,
        onTap: (i) {
          // Tapping Scan (index 2) navigates directly to QR screen
          ref.read(navIndexProvider.notifier).state = i;
        },
      ),
    );
  }
}

class _LibLogBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _LibLogBottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: AppTheme.bottomNavShadow,
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded,      label: 'Home',     index: 0, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.search_rounded,    label: 'Search',   index: 1, current: currentIndex, onTap: onTap),
              _ScanButton(isActive: currentIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.book_rounded,      label: 'Borrowed', index: 3, current: currentIndex, onTap: onTap),
              _NavItem(icon: Icons.person_rounded,    label: 'Profile',  index: 4, current: currentIndex, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.current, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.libPurple : AppColors.mutedForeground,
              size: 24,
            )
              .animate(target: isActive ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15),
                     duration: 200.ms, curve: Curves.easeOut),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.libPurple : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: 2),
            // Active dot indicator
            AnimatedContainer(
              duration: 200.ms,
              width: isActive ? 16 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.libPurple,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Centre QR Scan button: raised purple circle overlapping the nav bar.
class _ScanButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;

  const _ScanButton({required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.libPurpleLight, AppColors.libPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: AppTheme.qrScanShadow,
              ),
              child: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 26),
            )
              .animate(target: isActive ? 1 : 0)
              .scale(begin: const Offset(1, 1), end: const Offset(1.08, 1.08),
                     duration: 200.ms),
            const SizedBox(height: 2),
            Text(
              'Scan',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.libPurple : AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
