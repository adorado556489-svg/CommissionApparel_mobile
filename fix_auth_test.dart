import 'dart:io';

void main() {
  var file = File('test/auth_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
'''    setUp(() {
      authService = AuthService(firestore: FakeFirebaseFirestore(), firebaseAuth: AutoSeedingMockFirebaseAuth());''',
'''    late FakeFirebaseFirestore firestore;
    setUp(() async {
      firestore = FakeFirebaseFirestore();
      await TestSeeder.seedAdminEnvironment(firestore);
      await TestSeeder.seedCoachStoreEnvironment(firestore);
      authService = AuthService(firestore: firestore, firebaseAuth: AutoSeedingMockFirebaseAuth());''');
  
  content = content.replaceFirst("test('Valid Admin login', () async {", "test('Valid Admin login', () async {\n");
  
  file.writeAsStringSync(content);
}
