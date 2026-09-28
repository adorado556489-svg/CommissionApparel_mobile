import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("auth = AuthService(firestore: fakeFirestore, firebaseAuth: AutoSeedingMockFirebaseAuth());", "auth = AuthService(firestore: fakeFirestore, firebaseAuth: MockFirebaseAuth(mockUser: MockUser(uid: 'user-coach-1', email: 'coach@example.com')));");
  content = content.replaceAll("await tester.pump(const Duration(milliseconds: 100));", "await tester.pumpAndSettle();");
  file.writeAsStringSync(content);
}
