import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r'setUp\(\(\) \{.*?\}\);', dotAll: true), "setUp(() {\n    auth = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());\n  });");
  file.writeAsStringSync(content);
}
