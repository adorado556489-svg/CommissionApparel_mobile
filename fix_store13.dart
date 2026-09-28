import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("await tester.pumpAndSettle(); // Marcus", "await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));");
  content = content.replaceAll("await tester.pumpAndSettle(); // David Chen", "await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));");
  content = content.replaceFirst(
    "await auth.login('coach@example.com', 'password123');\n      await tester.runAsync",
    "auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-3', email: 'david.chen@trackclub.org')));\n      await auth.login('david.chen@trackclub.org', 'password123');\n      await tester.runAsync"
  );
  file.writeAsStringSync(content);
}
