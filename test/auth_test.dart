import 'helpers/auto_seeding_mock_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'helpers/test_seeder.dart';

void main() {
  group('Phase 3 — Authentication & Role-Based Navigation', () {
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAll(firestore);
    });

    test('Valid Admin login', () async {
      final mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'user-admin-1', email: 'admin@commissionapparel.com'));
      final authService = AuthService(firestore: firestore, firebaseAuth: mockAuth);

      final error = await authService.login('admin@commissionapparel.com', 'password123');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isAdmin, isTrue);
      expect(authService.dashboardRoute, '/admin/dashboard');
    });

    test('Valid Coach login', () async {
      final mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-1', email: 'coach@example.com'));
      final authService = AuthService(firestore: firestore, firebaseAuth: mockAuth);

      final error = await authService.login('coach@example.com', 'password123');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isCoach, isTrue);
      expect(authService.dashboardRoute, '/coach/dashboard');
    });

    test('Valid Parent login', () async {
      final mockAuth = MockFirebaseAuth(mockUser: MockUser(uid: 'user-parent-1', email: 'parent@test.com'));
      final authService = AuthService(firestore: firestore, firebaseAuth: mockAuth);

      final error = await authService.login('parent@test.com', 'password123');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(error, isNull);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isParent, isTrue);
      expect(authService.dashboardRoute, '/home');
    });

    test('Invalid email/password login', () async {
      final mockAuth = AutoSeedingMockFirebaseAuth();
      final authService = AuthService(firestore: firestore, firebaseAuth: mockAuth);

      final error = await authService.login('wrong@example.com', 'password123');
      await Future.delayed(const Duration(milliseconds: 50));
      expect(error, 'Invalid email or password.');
      expect(authService.isAuthenticated, isFalse);
    });
  });
}

