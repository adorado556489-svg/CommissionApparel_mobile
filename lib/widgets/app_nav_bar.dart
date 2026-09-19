import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../app/theme.dart';

/// Describes a single bottom navigation item.
class _NavItem {
  final String label;
  final IconData icon;
  final String route;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

/// Role-aware bottom navigation bar.
///
/// Adapts its items based on authentication state:
/// - **Guest (unauthenticated):** Home, Catalog, Stores, Quote, Sign In
/// - **Parent:** Home, Catalog, Stores, Account
/// - **Coach:** Home, Dashboard, Catalog, Account
/// - **Admin:** Home, Dashboard, Catalog, Account
class AppNavBar extends StatelessWidget {
  final int currentIndex;

  const AppNavBar({super.key, required this.currentIndex});

  /// Returns the navigation items for the current auth state.
  static List<_NavItem> _itemsForRole(AuthService auth) {
    if (!auth.isAuthenticated) {
      // Guest / unauthenticated
      return const [
        _NavItem(label: 'Home', icon: Icons.home_outlined, route: '/'),
        _NavItem(
          label: 'Catalog',
          icon: Icons.grid_view_outlined,
          route: '/catalog',
        ),
        _NavItem(
          label: 'Stores',
          icon: Icons.store_outlined,
          route: '/store/search',
        ),
        _NavItem(
          label: 'Quote',
          icon: Icons.request_quote_outlined,
          route: '/quote',
        ),
        _NavItem(
          label: 'Sign In',
          icon: Icons.login_outlined,
          route: '/login',
        ),
      ];
    }

    if (auth.isParent) {
      return const [
        _NavItem(label: 'Home', icon: Icons.home_outlined, route: '/'),
        _NavItem(
          label: 'Catalog',
          icon: Icons.grid_view_outlined,
          route: '/catalog',
        ),
        _NavItem(
          label: 'Stores',
          icon: Icons.store_outlined,
          route: '/store/search',
        ),
        _NavItem(
          label: 'Account',
          icon: Icons.person_outline,
          route: '/account',
        ),
      ];
    }

    // Coach or Admin — both get a Dashboard tab
    final dashboardRoute = auth.dashboardRoute;
    final dashboardIcon =
        auth.isAdmin
            ? Icons.admin_panel_settings_outlined
            : Icons.dashboard_outlined;

    return [
      const _NavItem(label: 'Home', icon: Icons.home_outlined, route: '/'),
      _NavItem(label: 'Dashboard', icon: dashboardIcon, route: dashboardRoute),
      const _NavItem(
        label: 'Catalog',
        icon: Icons.grid_view_outlined,
        route: '/catalog',
      ),
      const _NavItem(
        label: 'Account',
        icon: Icons.person_outline,
        route: '/account',
      ),
    ];
  }

  /// Returns the number of nav items for the current auth state.
  static int itemCount(AuthService auth) => _itemsForRole(auth).length;

  /// Returns the route for a given nav index based on the current auth state.
  static String routeForIndex(int index, AuthService auth) {
    final items = _itemsForRole(auth);
    if (index >= 0 && index < items.length) return items[index].route;
    return '/';
  }

  /// Returns the nav index that corresponds to a given route.
  static int indexForRoute(String route, AuthService auth) {
    final items = _itemsForRole(auth);
    for (int i = 0; i < items.length; i++) {
      if (items[i].route == route) return i;
    }
    return 0; // Default to Home
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final items = _itemsForRole(auth);
    final safeIndex = currentIndex.clamp(0, items.length - 1);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AppTheme.borderNav),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (index) => _onItemTapped(context, index, auth),
        items:
            items
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon),
                    label: item.label,
                  ),
                )
                .toList(),
      ),
    );
  }

  void _onItemTapped(BuildContext context, int index, AuthService auth) {
    final route = routeForIndex(index, auth);

    // "Account" is not a screen yet — show account dialog
    if (route == '/account') {
      _showAccountDialog(context, auth);
      return;
    }

    // Don't navigate if already on this route
    if (index == currentIndex) return;

    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showAccountDialog(BuildContext context, AuthService auth) {
    final user = auth.currentUser;
    if (user == null) return;

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(user.fullName),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.email, style: Theme.of(ctx).textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(
                  'Role: ${user.role.name.toUpperCase()}',
                  style: Theme.of(ctx).textTheme.bodySmall,
                ),
                if (user.organization != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Organization: ${user.organization}',
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  auth.logout();
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.secondary,
                ),
              ),
            ],
          ),
    );
  }
}
