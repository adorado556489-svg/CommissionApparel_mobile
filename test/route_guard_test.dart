
import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/app/routes.dart';
import 'package:commission_apparel_flutter/app/theme.dart';

Widget createTestApp(AuthService authService, String initialRoute) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: authService),
      Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore()),
    ],
    child: MaterialApp(
      theme: AppTheme.darkTheme,
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}

void main() {
  group('Phase 3 — Route Guard & Navigation Tests', () {
    testWidgets('Guest access to auth-required route redirects to login', (tester) async {
      final auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      await tester.pumpWidget(createTestApp(auth, AppRoutes.coachDashboard));
      
      // Wait for post-frame redirect
      await tester.pumpAndSettle();

      // Should be on the Login screen
      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('Authenticated user accessing guest-only route redirects to home', (tester) async {
      final auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      await auth.login('parent@test.com', 'password123'); // Role: Parent
      
      await tester.pumpWidget(createTestApp(auth, AppRoutes.login));
      await tester.pumpAndSettle();

      // Parent home screen doesn't have a distinct title here, but we can verify
      // login screen text is NOT present.
      expect(find.text('Sign in to your account'), findsNothing);
    });

    testWidgets('Unauthorized role access (Parent to Admin route) redirects to home', (tester) async {
      final auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      await auth.login('parent@test.com', 'password123');
      
      await tester.pumpWidget(createTestApp(auth, AppRoutes.adminDashboard));
      await tester.pumpAndSettle();

      // Shouldn't be on admin dashboard
      expect(find.text('Admin Dashboard'), findsNothing);
    });

    testWidgets('Authorized role access (Coach to Coach route) allowed', (tester) async {
      final auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      await auth.login('coach@example.com', 'password123');
      
      await tester.pumpWidget(createTestApp(auth, AppRoutes.coachDashboard));
      await tester.pumpAndSettle();

      // Placeholder or real dashboard is rendered
      // Coach dashboard placeholder says "Coach Dashboard"
      expect(find.text('Coach Dashboard'), findsWidgets);
    });

    testWidgets('Authorized role access (Admin to Coach route) allowed', (tester) async {
      final auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      await auth.login('admin@commissionapparel.com', 'password123');
      
      // Admin should be able to access Coach routes
      await tester.pumpWidget(createTestApp(auth, AppRoutes.coachDashboard));
      await tester.pumpAndSettle();

      expect(find.text('Coach Dashboard'), findsWidgets);
    });
  });
}






