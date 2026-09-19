import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user.dart';
import '../screens/public/home_screen.dart';
import '../screens/public/quote_screen.dart';
import '../screens/public/quote_success_screen.dart';
import '../screens/public/catalog_screen.dart';
import '../screens/public/catalog_collection_screen.dart';
import '../screens/public/store_search_screen.dart';
import '../screens/public/store_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/coach/coach_dashboard_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_store_edit_screen.dart';

/// Centralized route definitions and route generation with role-based guards.
///
/// Route guard behavior (matching the Laravel middleware):
/// - **Guest-only routes** (login, register): redirect to home if
///   already authenticated.
/// - **Coach routes**: require auth + (coach OR admin role).
/// - **Admin routes**: require auth + admin role only.
/// - **Public routes**: accessible to everyone.
class AppRoutes {
  AppRoutes._();

  // ── Route Name Constants ────────────────────────────────────────────────
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String catalog = '/catalog';
  static const String catalogCollection = '/catalog/collection';
  static const String storeSearch = '/store/search';
  static const String storeDetail = '/store/detail';
  static const String quote = '/quote';
  static const String quoteSuccess = '/quote/success';
  static const String testimonials = '/testimonials';
  static const String coachDashboard = '/coach/dashboard';
  static const String coachOrderEdit = '/coach/order/edit';
  static const String adminDashboard = '/admin/dashboard';
  static const String adminStoreEdit = '/admin/store/edit';
  static const String adminCoachEdit = '/admin/coach/edit';
  static const String adminOrderEdit = '/admin/order/edit';
  static const String adminDirectBatch = '/admin/direct-batch';

  /// Generates routes with role-based access guards.
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Public routes ─────────────────────────────────────────────────
      case home:
        return _buildRoute(settings, const HomeScreen());

      case catalog:
        return _buildRoute(
          settings,
          const CatalogScreen(),
        );

      case catalogCollection:
        return _buildRoute(
          settings,
          CatalogCollectionScreen(
            collectionId: settings.arguments as String? ?? 'col-basketball',
          ),
        );

      case storeSearch:
        return _buildRoute(
          settings,
          const StoreSearchScreen(),
        );

      case storeDetail:
        return _buildRoute(
          settings,
          StoreDetailScreen(
            storeId: settings.arguments as String? ?? 'store-1',
          ),
        );

      case testimonials:
        // Placeholder: these screens will be implemented in later phases.
        // For now, route to a simple placeholder.
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: _titleForRoute(settings.name)),
        );

      case quote:
        return _buildRoute(
          settings,
          const QuoteScreen(),
        );

      case quoteSuccess:
        return _buildRoute(
          settings,
          const QuoteSuccessScreen(),
        );

      // ── Guest-only routes (redirect away if authenticated) ────────────
      case login:
        return _buildRoute(
          settings,
          const LoginScreen(),
          guestOnly: true,
        );

      case register:
        return _buildRoute(
          settings,
          const RegisterScreen(),
          guestOnly: true,
        );

      case forgotPassword:
      case resetPassword:
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: _titleForRoute(settings.name)),
          guestOnly: true,
        );

      // ── Coach routes (auth + coach/admin) ─────────────────────────────
      case coachDashboard:
        return _buildRoute(
          settings,
          const CoachDashboardScreen(),
          requireAuth: true,
          allowedRoles: [UserRole.coach, UserRole.admin],
        );

      case coachOrderEdit:
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: _titleForRoute(settings.name)),
          requireAuth: true,
          allowedRoles: [UserRole.coach, UserRole.admin],
        );

      // ── Admin routes (auth + admin only) ──────────────────────────────
      case adminDashboard:
        return _buildRoute(
          settings,
          const AdminDashboardScreen(),
          requireAuth: true,
          allowedRoles: [UserRole.admin],
        );

      case adminStoreEdit:
      case adminCoachEdit:
      case adminOrderEdit:
      case adminDirectBatch:
        return _buildRoute(
          settings,
          _PlaceholderScreen(title: _titleForRoute(settings.name)),
          requireAuth: true,
          allowedRoles: [UserRole.admin],
        );

      // ── Default / 404 ─────────────────────────────────────────────────
      default:
        return _buildRoute(
          settings,
          const _PlaceholderScreen(title: 'Page Not Found'),
        );
    }
  }

  /// Wraps a screen widget with a route guard.
  static MaterialPageRoute<dynamic> _buildRoute(
    RouteSettings settings,
    Widget screen, {
    bool requireAuth = false,
    bool guestOnly = false,
    List<UserRole>? allowedRoles,
  }) {
    return MaterialPageRoute(
      settings: settings,
      builder:
          (context) => _RouteGuard(
            requireAuth: requireAuth,
            guestOnly: guestOnly,
            allowedRoles: allowedRoles ?? [],
            child: screen,
          ),
    );
  }

  /// Returns a human-readable title for a route (used by placeholders).
  static String _titleForRoute(String? route) {
    switch (route) {
      case catalog:
        return 'Design Catalog';
      case storeSearch:
        return 'Find a Store';
      case quote:
        return 'Request a Quote';
      case testimonials:
        return 'Testimonials';
      case register:
        return 'Register';
      case forgotPassword:
        return 'Forgot Password';
      case resetPassword:
        return 'Reset Password';
      case coachOrderEdit:
        return 'Edit Order';
      case adminStoreEdit:
        return 'Edit Store';
      case adminCoachEdit:
        return 'Edit Coach';
      case adminOrderEdit:
        return 'Edit Order';
      case adminDirectBatch:
        return 'Direct Order Batch';
      default:
        return 'Page';
    }
  }
}

/// Widget that enforces route access rules before rendering the child.
///
/// If the user does not meet the requirements, they are redirected:
/// - Unauthenticated → login screen
/// - Wrong role → home screen
/// - Already authenticated on guest-only route → home screen
class _RouteGuard extends StatelessWidget {
  final Widget child;
  final bool requireAuth;
  final bool guestOnly;
  final List<UserRole> allowedRoles;

  const _RouteGuard({
    required this.child,
    this.requireAuth = false,
    this.guestOnly = false,
    this.allowedRoles = const [],
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    // Guest-only routes: redirect authenticated users to home
    if (guestOnly && auth.isAuthenticated) {
      _redirect(context, AppRoutes.home);
      return const _LoadingScreen();
    }

    // Auth-required routes: redirect unauthenticated users to login
    if (requireAuth && !auth.isAuthenticated) {
      _redirect(context, AppRoutes.login);
      return const _LoadingScreen();
    }

    // Role check: redirect if user's role is not in allowed list
    if (allowedRoles.isNotEmpty &&
        auth.currentRole != null &&
        !allowedRoles.contains(auth.currentRole)) {
      _redirect(context, AppRoutes.home);
      return const _LoadingScreen();
    }

    return child;
  }

  /// Schedules a redirect after the current frame completes.
  void _redirect(BuildContext context, String route) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(route);
      }
    });
  }
}

/// Shown briefly during route guard redirects.
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Generic placeholder screen for routes not yet implemented.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              'This screen will be implemented in a later phase.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed:
                  () => Navigator.of(context).pushReplacementNamed('/'),
              icon: const Icon(Icons.home, size: 18),
              label: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
