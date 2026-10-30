import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/bag_provider.dart';
import '../../theme/app_theme.dart';

class ScaffoldWithNavBar extends ConsumerWidget {
  final Widget child;
  const ScaffoldWithNavBar({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final index = _indexForLocation(location);
    final bagCount =
        ref.watch(bagProvider).fold<int>(0, (s, x) => s + x.quantity);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (i) => _onTap(context, i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          showUnselectedLabels: true,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 22),
              activeIcon: Icon(Icons.home, size: 22),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined, size: 22),
              activeIcon: Icon(Icons.grid_view, size: 22),
              label: 'Categories',
            ),
            BottomNavigationBarItem(
              icon: _BagIcon(
                count: bagCount,
                filled: false,
              ),
              activeIcon: _BagIcon(
                count: bagCount,
                filled: true,
              ),
              label: 'Bag',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 22),
              activeIcon: Icon(Icons.person, size: 22),
              label: 'Account',
            ),
          ],
        ),
      ),
    );
  }

  void _onTap(BuildContext context, int i) {
    switch (i) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/categories');
        break;
      case 2:
        context.go('/bag');
        break;
      case 3:
        context.go('/account');
        break;
    }
  }

  int _indexForLocation(String path) {
    if (path == '/') return 0;
    if (path.startsWith('/categories')) return 1;
    if (path.startsWith('/bag')) return 2;
    if (path.startsWith('/account')) return 3;
    // Any other shell route (shouldn't happen with minimal shell)
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bag icon with optional badge
// ─────────────────────────────────────────────────────────────────────────────
class _BagIcon extends StatelessWidget {
  final int count;
  final bool filled;
  const _BagIcon({required this.count, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          filled ? Icons.shopping_bag : Icons.shopping_bag_outlined,
          size: 22,
        ),
        if (count > 0)
          Positioned(
            right: -6,
            top: -4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppTheme.danger,
                borderRadius: BorderRadius.circular(AppTheme.rPill),
              ),
              child: Text(
                count > 99 ? '99+' : '$count',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}