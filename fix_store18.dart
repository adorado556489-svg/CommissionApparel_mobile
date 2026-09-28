import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "testWidgets('Empty roster cannot be submitted', (tester) async {\n      auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-1', email: 'coach@example.com')));\n      await auth.login('coach@example.com', 'password123');\n      await tester.pumpAndSettle(); // David has no orders",
    "testWidgets('Empty roster cannot be submitted', (tester) async {\n      auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-2', email: 'sarah.williams@school.edu')));\n      await auth.login('sarah.williams@school.edu', 'password123');\n      await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 100)));"
  );
  file.writeAsStringSync(content);
}
