import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('late AuthService auth;', 'late AuthService auth;\n  late FakeFirebaseFirestore fakeFirestore;');
  content = content.replaceAll(RegExp(r'setUp\(\(\) \{.*?\}\);', dotAll: true), "setUp(() async {\n    fakeFirestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(fakeFirestore);\n    auth = AuthService(firestore: fakeFirestore, firebaseAuth: AutoSeedingMockFirebaseAuth());\n  });");
  
  content = content.replaceAll('createTestApp(const CoachDashboardScreen(), auth)', 'createTestApp(const CoachDashboardScreen(), auth, fakeFirestore)');
  
  file.writeAsStringSync(content);
}
