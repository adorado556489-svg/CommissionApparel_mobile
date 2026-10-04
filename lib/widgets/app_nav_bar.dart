import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  const _NavItem(this.label, this.icon, this.route);
}

class AppNavBar extends StatelessWidget {
  final int currentIndex;

  const AppNavBar({super.key, required this.currentIndex});

  static List<_NavItem> _itemsForRole(AuthService auth) {
    if (!auth.isAuthenticated) return [];
    if (auth.isAdmin) {
      return const [
        _NavItem('Home', Icons.home_outlined, '/home'),
        _NavItem('Dashboard', Icons.dashboard_outlined, '/admin/dashboard'),
        _NavItem('Account', Icons.person_outline, '/account'),
      ];
    }
    return [
      const _NavItem('Home', Icons.home_outlined, '/home'),
      if (auth.currentRole == UserRole.coach)
        const _NavItem('My Store', Icons.storefront_outlined, '/coach/dashboard'),
      const _NavItem('Stores', Icons.explore_outlined, '/store/search'),
      const _NavItem('Orders', Icons.receipt_long_outlined, '/orders'),
      const _NavItem('Account', Icons.person_outline, '/account'),
    ];
  }

  static int itemCount(AuthService auth) => _itemsForRole(auth).length;

  static String routeForIndex(int index, AuthService auth) {
    final items = _itemsForRole(auth);
    if (index >= 0 && index < items.length) return items[index].route;
    return '/home';
  }

  static int indexForRoute(String? route, AuthService auth) {
    if (route == null) return -1;
    final items = _itemsForRole(auth);
    int idx = items.indexWhere((i) => i.route == route);
    if (idx < 0) {
      if (route.startsWith('/catalog')) {
        idx = items.indexWhere((i) => i.route == '/catalog');
      } else if (route.startsWith('/store')) {
        idx = items.indexWhere((i) => i.route == '/store/search');
      } else if (route.startsWith('/coach')) {
        idx = items.indexWhere((i) => i.route == '/coach/dashboard');
      } else if (route.startsWith('/admin')) {
        idx = items.indexWhere((i) => i.route == '/admin/dashboard');
      } else if (route.startsWith('/orders')) {
        idx = items.indexWhere((i) => i.route == '/orders');
      }
    }
    return idx;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final items = _itemsForRole(auth);
    if (items.isEmpty) return const SizedBox.shrink();

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: (idx) {
        if (idx == currentIndex) return;
        Navigator.of(context).pushReplacementNamed(items[idx].route);
      },
      items: items
          .map((i) => BottomNavigationBarItem(icon: Icon(i.icon), label: i.label))
          .toList(),
    );
  }
}
