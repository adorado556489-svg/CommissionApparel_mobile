import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "await auth.login('david.chen@trackclub.org', 'password123');",
    "auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-3', email: 'david.chen@trackclub.org')));\n      await auth.login('david.chen@trackclub.org', 'password123');"
  );
  file.writeAsStringSync(content);
}
