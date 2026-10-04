import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class AutoSeedingMockFirebaseAuth extends MockFirebaseAuth {
  User? _signedInUser;

  AutoSeedingMockFirebaseAuth({super.mockUser});

  @override
  User? get currentUser => _signedInUser ?? super.currentUser;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    String uid = 'random-uid';
    if (email == 'coach@example.com') uid = 'user-coach-1';
    if (email == 'sarah.williams@school.edu') uid = 'user-coach-2';
    if (email == 'david.chen@trackclub.org') uid = 'user-coach-3';
    if (email == 'admin@commissionapparel.com') uid = 'user-admin-1';
    if (email == 'parent@test.com') uid = 'user-parent-1';
    if (email == 'wrong@example.com') {
      throw FirebaseAuthException(code: 'invalid-credential');
    }

    final mockUser = MockUser(uid: uid, email: email);
    _signedInUser = mockUser;
    return MockUserCredential(false, mockUser: mockUser);
  }
}
