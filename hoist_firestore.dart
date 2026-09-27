import 'dart:io';

void main() {
  var testDir = Directory('test');
  for (var entity in testDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      var content = entity.readAsStringSync();
      
      // If it has local firestore
      if (content.contains('final firestore = FakeFirebaseFirestore();')) {
        content = content.replaceAll(
          "late AuthService auth;", 
          "late AuthService auth;\n  late FakeFirebaseFirestore firestore;"
        );
        content = content.replaceAll(
          "final firestore = FakeFirebaseFirestore();",
          "firestore = FakeFirebaseFirestore();"
        );
      }
      
      // Some files might have `FakeFirebaseFirestore firestore;` 
      if (content.contains('firestore = FakeFirebaseFirestore();')) {
          if (!content.contains('TestSeeder.seedAll(firestore)')) {
            content = content.replaceAll(
               "firestore = FakeFirebaseFirestore();",
               "firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);"
            );
            content = content.replaceAll("setUp(() {", "setUp(() async {");
            if (!content.contains("import 'helpers/test_seeder.dart';")) {
              content = "import 'helpers/test_seeder.dart';\n" + content;
            }
          }
      }
      
      entity.writeAsStringSync(content);
    }
  }
}
