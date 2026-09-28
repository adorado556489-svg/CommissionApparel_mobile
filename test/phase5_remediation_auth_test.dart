import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late MockFirebaseAuth auth;
  late AuthService authService;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    auth = MockFirebaseAuth();
    authService = AuthService(firestore: firestore, firebaseAuth: auth);
  });

  group('Phase 5 Remediation - Password Reset', () {
    test('7. Password reset identity verification follows intended behavior', () async {
      await firestore.collection('users').add({
        'email': 'coach@school.edu',
        'phone': '1234567890',
        'organization': 'High School',
      });
      
      // Correct identity
      final err1 = await authService.sendPasswordReset('coach@school.edu', '1234567890', 'High School');
      expect(err1, isNull);
      
      // Wrong phone
      final err2 = await authService.sendPasswordReset('coach@school.edu', '0000000000', 'High School');
      expect(err2, 'Identity verification failed. Information does not match our records.');
      
      // Wrong org
      final err3 = await authService.sendPasswordReset('coach@school.edu', '1234567890', 'Middle School');
      expect(err3, 'Identity verification failed. Information does not match our records.');
    });
  });
}
