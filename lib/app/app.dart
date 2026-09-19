import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'theme.dart';
import 'routes.dart';

/// Root application widget.
///
/// Configures [MaterialApp] with:
/// - Provider-based state management ([AuthService])
/// - Dark theme from [AppTheme]
/// - Named route navigation with role-based guards from [AppRoutes]
class CommissionApparelApp extends StatelessWidget {
  const CommissionApparelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService(),
      child: MaterialApp(
        title: 'Commission Apparel',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
