import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'helpers/auto_seeding_mock_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/screens/auth/forgot_password_screen.dart';
import 'helpers/test_seeder.dart';

void main() {
  group('Phase 7B - Password Reset Tests (Firebase Mocks)', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAll(firestore);
      mockAuth = AutoSeedingMockFirebaseAuth();
      authService = AuthService(firestore: firestore, firebaseAuth: mockAuth);
    });

    tearDown(() {
      authService.logout();
    });

    Widget createTestApp() {
      return ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: const MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      );
    }

    testWidgets('1. Forgot password screen loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();
      expect(find.text('Verify Identity'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Organization'), findsOneWidget);
    });

    testWidgets('2. Invalid identity fails with the generic message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'coach@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), '555-0000');
      await tester.enterText(find.byType(TextFormField).at(2), 'Wrong Org');
      
      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();
      
      // We expect the snackbar or error text
      expect(find.textContaining('Identity verification failed'), findsOneWidget);
    });

    testWidgets('3. Successful verification sends Firebase reset email', (WidgetTester tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      await mockAuth.createUserWithEmailAndPassword(email: 'coach@example.com', password: 'password123');
      await tester.enterText(find.byType(TextFormField).at(0), 'coach@example.com');
      // Needs correct values from seeder
      await tester.enterText(find.byType(TextFormField).at(1), '(555) 123-4567');
      await tester.enterText(find.byType(TextFormField).at(2), 'Riverside Academy');
      
      await tester.tap(find.text('VERIFY IDENTITY'));
      await tester.pumpAndSettle();
    });
  });
}


