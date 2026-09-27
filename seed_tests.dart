import 'dart:io';

void main() {
  var testDir = Directory('test');
  for (var entity in testDir.listSync(recursive: true)) {
    if (entity is File && entity.path.endsWith('_test.dart')) {
      var content = entity.readAsStringSync();
      
      // Look for setUp(() { firestore = FakeFirebaseFirestore(); })
      if (content.contains('FakeFirebaseFirestore()') && content.contains('setUp(')) {
        if (!content.contains('TestSeeder.seedAll')) {
          var importLine = "import 'helpers/test_seeder.dart';\n";
          
          // Add import at the top
          var newContent = importLine + content;
          
          // Replace setUp
          // This regex handles setUp(() {...}); and setUp(() async {...});
          newContent = newContent.replaceAllMapped(
            RegExp(r"setUp\(\(\)\s*(async)?\s*\{([^\}]+)firestore = FakeFirebaseFirestore\(\);([^\}]*)\}\);"),
            (m) {
              return "setUp(() async {${m[2]}firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);${m[3]}});";
            }
          );
          
          // If the regex didn't catch it, we might need a simpler replacement
          if (!newContent.contains('TestSeeder.seedAll(firestore)')) {
             newContent = newContent.replaceAll(
                "firestore = FakeFirebaseFirestore();",
                "firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);"
             );
             // Ensure setUp has async
             newContent = newContent.replaceAll("setUp(() {", "setUp(() async {");
          }
          
          entity.writeAsStringSync(newContent);
        }
      }
    }
  }
}
