import 'dart:io';

void main() {
  var testDir = Directory('test');
  for (var entity in testDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      var content = entity.readAsStringSync();
      
      // If it contains FakeFirebaseFirestore() inline in AuthService
      if (content.contains('FakeFirebaseFirestore()') && !content.contains('TestSeeder.seedAll')) {
        content = "import 'helpers/test_seeder.dart';\n" + content;
        
        // We need to extract the firestore variable so we can seed it
        // Or if it's already extracted but regex missed it...
        if (content.contains('auth = AuthService(firestore: FakeFirebaseFirestore()')) {
          content = content.replaceAll(
            "auth = AuthService(firestore: FakeFirebaseFirestore()",
            "final firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);\n    auth = AuthService(firestore: firestore"
          );
          content = content.replaceAll("setUp(() {", "setUp(() async {");
        }
        
        entity.writeAsStringSync(content);
      }
    }
  }
}
