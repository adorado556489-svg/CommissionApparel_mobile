import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../coach/coach_dashboard_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../public/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (!authService.isAuthenticated) {
          return const LoginScreen();
        }
        
        switch (authService.currentRole) {
          case UserRole.admin:
            return const AdminDashboardScreen();
          case UserRole.coach:
            return const CoachDashboardScreen();
          case UserRole.parent:
          default:
            return const HomeScreen(); // Normal user access
        }
      },
    );
  }
}
