import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

class AutoSeedingMockFirebaseAuth extends MockFirebaseAuth {
  AutoSeedingMockFirebaseAuth({super.mockUser});

  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    await createUserWithEmailAndPassword(email: email, password: password);
    return super.signInWithEmailAndPassword(email: email, password: password);
  }
}
