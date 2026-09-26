import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import 'theme.dart';
import 'routes.dart';

/// Root application widget.
///
/// Configures [MaterialApp] with:
/// - Provider-based state management ([AuthService] and [FirebaseFirestore])
/// - Dark theme from [AppTheme]
/// - Named route navigation with role-based guards from [AppRoutes]
class CommissionApparelApp extends StatelessWidget {
  final FirebaseFirestore firestore;
  
  const CommissionApparelApp({super.key, required this.firestore});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirebaseFirestore>.value(value: firestore),
        ChangeNotifierProvider(create: (_) => AuthService(firestore: firestore)),
      ],
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
