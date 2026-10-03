import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:commission_apparel_flutter/services/auth_service.dart';
import 'helpers/test_seeder.dart';
import 'helpers/mock_google_sign_in.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestSeeder.populateDummyFallbacks();

  group('Phase 1 — Auth', () {
    late AuthService authService;
    late FakeFirebaseFirestore firestore;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
      await TestSeeder.seedCoachStoreEnvironment(firestore);
      await TestSeeder.seedParentEnvironment(firestore);
      authService = AuthService(firestore: firestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-admin-1', email: 'admin@commissionapparel.com')), googleSignIn: MockGoogleSignIn());
    });

    test('Valid Admin login', () async {
      final error = await authService.login('admin@commissionapparel.com', 'password123');
      expect(error, isNull);
      await Future.delayed(Duration(milliseconds: 100));
      expect(authService.isAuthenticated, isTrue);
      expect(authService.isAdmin, isTrue);
    });

    test('Normal user registration succeeds and auto-logs in', () async {
      final error = await authService.register(
        firstName: 'New',
        lastName: 'User',
        email: 'newuser@example.com',
        password: 'password123',
      );
      
      expect(error, isNull);
      await Future.delayed(Duration(milliseconds: 100));
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser!.role, UserRole.parent); // Default for normal user
      expect(authService.currentUser!.status, 'active'); // Does not require approval

      final doc = await firestore.collection('users').doc(authService.currentUser!.id).get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['email'], 'newuser@example.com');
    });
  });
}





