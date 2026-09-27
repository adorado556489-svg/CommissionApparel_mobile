import 'dart:io';

void main() {
  var file = File('test/helpers/auto_seeding_mock_auth.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("class AutoSeedingMockFirebaseAuth extends MockFirebaseAuth {", 
"""class AutoSeedingMockFirebaseAuth extends MockFirebaseAuth {
  @override
  Future<UserCredential> signInWithEmailAndPassword({required String email, required String password}) async {
    if (password != 'password123') throw FirebaseAuthException(code: 'wrong-password');
    final dummy = dummyUsers.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase(), orElse: () => throw FirebaseAuthException(code: 'user-not-found'));
    final mu = MockUser(uid: dummy.id, email: dummy.email);
    return MockUserCredential(true, mockUser: mu);
  }
""");
  file.writeAsStringSync(content);
}

class MockUserCredential {}
