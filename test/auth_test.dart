import 'package:flutter_test/flutter_test.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'package:commission_apparel_flutter/data/dummy_users.dart';

void main() {
  group('Phase 3 — Authentication & Role-Based Navigation', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      // Ensure dummyUsers is reset to initial state if modified in tests.
      // For in-memory tests, we can just rely on the existing dummyUsers list.
    });

    test('Valid Admin login', () {
      final error = authService.login('admin@commissionapparel.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isAdmin, isTrue);
      expect(authService.dashboardRoute, '/admin/dashboard');
    });

    test('Valid Coach login', () {
      final error = authService.login('coach@example.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isCoach, isTrue);
      expect(authService.dashboardRoute, '/coach/dashboard');
    });

    test('Valid Parent login', () {
      final error = authService.login('parent@test.com', 'password123');
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isParent, isTrue);
      expect(authService.dashboardRoute, '/');
    });

    test('Invalid email/password login', () {
      final error = authService.login('wrong@example.com', 'password123');
      expect(error, 'Invalid email or password.');
      expect(authService.isAuthenticated, isFalse);
    });

    test('Declined/pending account behavior (declined blocked)', () {
      // Modify coach 3 temporarily for the test
      final targetEmail = 'david.chen@trackclub.org';
      final declinedIndex = dummyUsers.indexWhere((u) => u.email == targetEmail);
      final originalStatus = dummyUsers[declinedIndex].status;
      try {
        dummyUsers[declinedIndex] = dummyUsers[declinedIndex].copyWith(status: 'declined');

        final error = authService.login(targetEmail, 'password123');
        expect(error, 'Your account has been declined. Please contact support.');
        expect(authService.isAuthenticated, isFalse);
      } finally {
        dummyUsers[declinedIndex] = dummyUsers[declinedIndex].copyWith(status: originalStatus);
      }
    });

    test('Logout clears session', () {
      authService.login('admin@commissionapparel.com', 'password123');
      expect(authService.isAuthenticated, isTrue);
      authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentUser, isNull);
    });

    test('Registration validation and flow', () {
      final error = authService.register(
        firstName: 'New',
        lastName: 'Coach',
        email: 'newcoach@example.com',
        password: 'password123',
        organization: 'New School',
      );
      
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isCoach, isTrue);
      expect(authService.currentUser?.status, 'active');
      expect(authService.dashboardRoute, '/coach/dashboard');

      // Test duplicate registration
      final duplicateError = authService.register(
        firstName: 'Other',
        lastName: 'Guy',
        email: 'newcoach@example.com',
        password: 'password123',
      );
      expect(duplicateError, 'An account with this email already exists.');
    });
  });
}
