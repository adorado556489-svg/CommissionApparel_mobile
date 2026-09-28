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
import '../screens/public/parent_order_form_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';

import '../screens/coach/coach_dashboard_screen.dart';
import '../screens/coach/coach_order_edit_screen.dart';
import '../screens/coach/direct_order_form_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/admin_coach_edit_screen.dart';
import '../screens/admin/admin_batch_show_screen.dart';
import '../screens/admin/admin_content_screens.dart';
import '../screens/admin/admin_store_edit_screen.dart';

// New user screens
import '../screens/user/user_dashboard_screen.dart';
import '../screens/user/orders_history_screen.dart';
import '../screens/user/notifications_screen.dart';
import '../screens/user/account_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  
  static const String catalog = '/catalog';
  static const String catalogCollection = '/catalog/collection';
  static const String storeSearch = '/store/search';
  static const String storeDetail = '/store/detail';
  static const String storeOrder = '/store/order';
  static const String quote = '/quote';
  static const String quoteSuccess = '/quote/success';

  static const String orders = '/orders';
  static const String notifications = '/notifications';
  static const String account = '/account';

  static const String coachDashboard = '/coach/dashboard';
  static const String coachOrderEdit = '/coach/order/edit';
  static const String coachDirectOrderSubmit = '/coach/direct-order/submit';

  static const String adminDashboard = '/admin/dashboard';
  static const String adminCoachEdit = '/admin/coach/edit';
  static const String adminBatchShow = '/admin/batch/show';
  static const String adminTestimonials = '/admin/testimonials';
  static const String adminQuotes = '/admin/quotes';
  static const String adminLandingCollections = '/admin/landing-collections';
  static const String adminStoreEdit = '/admin/store/edit';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    return MaterialPageRoute(
      settings: settings,
      builder: (context) {
        return _RouteGuard(
          settings: settings,
          child: _buildScreen(settings),
        );
      },
    );
  }

  static Widget _buildScreen(RouteSettings settings) {
    switch (settings.name) {
      case home: return const UserDashboardScreen();
      case login: return const LoginScreen();
      case register: return const RegisterScreen();
      case forgotPassword: return const ForgotPasswordScreen();
      case catalog: return const CatalogScreen();
      case catalogCollection: return CatalogCollectionScreen(categoryId: settings.arguments as String);
      case storeSearch: return const StoreSearchScreen();
      case storeDetail: return StoreDetailScreen(storeId: settings.arguments as String);
      case storeOrder: return ParentOrderFormScreen(storeId: settings.arguments as String);
      case quote: return const QuoteScreen();
      case quoteSuccess: return const QuoteSuccessScreen();
      case orders: return const OrdersHistoryScreen();
      case notifications: return const NotificationsScreen();
      case account: return const AccountScreen();
      case coachDashboard: return const CoachDashboardScreen();
      case coachOrderEdit: return CoachOrderEditScreen(orderId: settings.arguments as String);
      case coachDirectOrderSubmit: return const DirectOrderFormScreen();
      case adminDashboard: return const AdminDashboardScreen();
      case adminCoachEdit: return AdminCoachEditScreen(coachId: settings.arguments as String);
      case adminBatchShow: return AdminBatchShowScreen(batchId: settings.arguments as String);
      case adminTestimonials: return const AdminTestimonialsScreen();
      case adminQuotes: return const AdminQuotesScreen();
      case adminLandingCollections: return const AdminLandingCollectionsScreen();
      case adminStoreEdit: return AdminStoreEditScreen(storeId: settings.arguments as String);
      default:
        return const Scaffold(
          body: Center(child: Text('404 - Page not found')),
        );
    }
  }
}

class _RouteGuard extends StatelessWidget {
  final RouteSettings settings;
  final Widget child;

  const _RouteGuard({required this.settings, required this.child});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    if (auth.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isAuth = auth.isAuthenticated;
    final role = auth.currentRole;

    final guestOnlyRoutes = [
      AppRoutes.login,
      AppRoutes.register,
      AppRoutes.forgotPassword,
    ];
    final requireAuthRoutes = [
      AppRoutes.home,
      AppRoutes.orders,
      AppRoutes.notifications,
      AppRoutes.account,
      AppRoutes.catalog,
      AppRoutes.storeSearch,
      AppRoutes.quote,
    ];

    if (guestOnlyRoutes.contains(settings.name) && isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (requireAuthRoutes.contains(settings.name) && !isAuth) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (settings.name?.startsWith('/coach') == true) {
      if (!isAuth || (role != UserRole.coach && role != UserRole.admin)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    if (settings.name?.startsWith('/admin') == true) {
      if (!isAuth || role != UserRole.admin) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed(AppRoutes.login);
        });
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
    }

    return child;
  }
}
