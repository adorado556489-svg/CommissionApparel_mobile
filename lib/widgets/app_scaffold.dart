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
  final int currentNavIndex;
  final List<Widget>? actions;
  final FloatingActionButton? floatingActionButton;
  final bool showNavBar;
  final bool showAppBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentNavIndex = 0,
    this.actions,
    this.floatingActionButton,
    this.showNavBar = true,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    return Scaffold(
      appBar:
          showAppBar
              ? AppBar(
                title: Text(title),
                actions: [
                  if (auth.isAuthenticated)
                    IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () {
                        auth.logout();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                    ),
                  ...?actions,
                ],
              )
              : null,
      body: body,
      bottomNavigationBar:
          showNavBar ? AppNavBar(currentIndex: currentNavIndex) : null,
      floatingActionButton: floatingActionButton,
    );
  }
}
