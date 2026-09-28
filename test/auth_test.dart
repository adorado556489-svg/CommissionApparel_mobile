import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'helpers/auto_seeding_mock_auth.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'fixtures/dummy_users.dart';

void main() {
  group('Phase 3 — Authentication & Role-Based Navigation', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());
      // Ensure dummyUsers is reset to initial state if modified in tests.
      // For in-memory tests, we can just rely on the existing dummyUsers list.
    });

    test('Valid Admin login', () async {
      final error = await authService.login('admin@commissionapparel.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isAdmin, isTrue);
      expect(authService.dashboardRoute, '/admin/dashboard');
    });

    test('Valid Coach login', () async {
      final error = await authService.login('coach@example.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isCoach, isTrue);
      expect(authService.dashboardRoute, '/coach/dashboard');
    });

    test('Valid Parent login', () async {
      final error = await authService.login('parent@test.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isParent, isTrue);
      expect(authService.dashboardRoute, '/');
    });

    test('Invalid email/password login', () async {
      final error = await authService.login('wrong@example.com', 'password123');
      expect(error, 'Invalid email or password.');
      expect(authService.isAuthenticated, isFalse);
    });

    test('Declined/pending account behavior (declined blocked)', () async {
      // Modify coach 3 temporarily for the test
      final targetEmail = 'david.chen@trackclub.org';
      final declinedIndex = dummyUsers.indexWhere((u) => u.email == targetEmail);
      final originalStatus = dummyUsers[declinedIndex].status;
      try {
        dummyUsers[declinedIndex] = dummyUsers[declinedIndex].copyWith(status: 'declined');

        final error = await authService.login(targetEmail, 'password123');
        expect(error, 'Your account has been declined. Please contact support.');
        expect(authService.isAuthenticated, isFalse);
      } finally {
        dummyUsers[declinedIndex] = dummyUsers[declinedIndex].copyWith(status: originalStatus);
      }
    });

    test('Logout clears session', () async {
      await authService.login('coach@example.com', 'password123');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(authService.isAuthenticated, isTrue);

      await authService.logout();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });
  });
}







