import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'app_nav_bar.dart';

/// Common page scaffold providing a consistent layout with:
/// - AppBar with title
/// - Role-aware bottom navigation bar
/// - Optional floating action button
/// - Optional drawer
///
/// Most screens should wrap their body in this widget.
class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final int? currentNavIndex;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final bool showNavBar;
  final bool showAppBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentNavIndex,
    this.actions,
    this.floatingActionButton,
    this.showNavBar = true,
    this.showAppBar = true,
  });

  int _resolveIndex(BuildContext context, AuthService auth) {
    final route = ModalRoute.of(context)?.settings.name;
    final int idx = AppNavBar.indexForRoute(route, auth);
    if (idx >= 0) return idx;

    if (currentNavIndex != null) {
      final itemsCount = AppNavBar.itemCount(auth);
      if (itemsCount > 0 && currentNavIndex! < itemsCount) {
        return currentNavIndex!;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: Text(title),
                actions: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...?actions,
                        if (auth.isAuthenticated)
                          IconButton(
                            icon: const Icon(Icons.logout),
                            tooltip: 'Logout',
                            onPressed: () {
                              auth.logout();
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              )
              : null,
      body: body,
      bottomNavigationBar:
          showNavBar ? AppNavBar(currentIndex: _resolveIndex(context, auth)) : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
