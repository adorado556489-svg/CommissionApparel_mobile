import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains("testWidgets('Coach without store can create a store'")) {
      // Find the auth.login line inside this test
      for (var j = i + 1; j < lines.length; j++) {
        if (lines[j].contains("await auth.login(")) {
          lines[j] = "      auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-3', email: 'david.chen@trackclub.org')));\n      await auth.login('david.chen@trackclub.org', 'password123');";
          break;
        }
      }
    } else if (lines[i].contains("testWidgets(")) {
      // For all other tests, we also need to re-init auth to reset state!
      for (var j = i + 1; j < lines.length; j++) {
        if (lines[j].contains("await auth.login(")) {
          lines[j] = "      auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-1', email: 'coach@example.com')));\n      await auth.login('coach@example.com', 'password123');";
          break;
        }
      }
    }
  }
  file.writeAsStringSync(lines.join('\n'));
}
