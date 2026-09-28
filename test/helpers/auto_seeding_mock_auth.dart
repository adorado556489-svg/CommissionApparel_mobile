import 'package:firebase_auth_mocks/src/mock_user_credential.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class AutoSeedingMockFirebaseAuth extends MockFirebaseAuth {
  AutoSeedingMockFirebaseAuth({super.mockUser});

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    String uid = 'random-uid';
    if (email == 'coach@example.com') uid = 'user-coach-1';
    if (email == 'sarah.williams@school.edu') uid = 'user-coach-2';
    if (email == 'david.chen@trackclub.org') uid = 'user-coach-3';
    if (email == 'admin@commissionapparel.com') uid = 'user-admin-1';
    if (email == 'parent@test.com') uid = 'user-parent-1';
    if (email == 'wrong@example.com') throw Exception('invalid');
    
    // We can't easily change the MockFirebaseAuth's generated UID, but wait, MockFirebaseAuth has `mockUser`.
    // Actually, we don't even need to call createUserWithEmailAndPassword if we just want to return a UserCredential.
    // Wait, MockFirebaseAuth needs the user to exist in its internal state.
    // But since it's a test file, we can just instantiate a new MockFirebaseAuth with the right mockUser for that email!
    final mockUser = MockUser(uid: uid, email: email);
    return MockUserCredential(false, mockUser: mockUser);
  }
}



