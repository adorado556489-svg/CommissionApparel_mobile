import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('Widget createTestApp(Widget home, AuthService auth) {', 'Widget createTestApp(Widget home, AuthService auth, FirebaseFirestore firestore) {');
  content = content.replaceFirst('Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore()),', 'Provider<FirebaseFirestore>.value(value: firestore),');
  file.writeAsStringSync(content);
}
