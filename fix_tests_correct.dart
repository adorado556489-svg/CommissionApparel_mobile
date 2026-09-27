import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      
      content = content.replaceAllMapped(
        RegExp(r"import 'package:commission_apparel_flutter/data/(dummy_[^']+)'"),
        (match) => "import 'fixtures/${match.group(1)}'"
      );
      content = content.replaceAllMapped(
        RegExp(r"import '\.\./\.\./lib/data/(dummy_[^']+)'"),
        (match) => "import '../fixtures/${match.group(1)}'"
      );
      
      if (content.contains('FakeFirebaseFirestore') && !content.contains('test_seeder.dart')) {
        String seederImport = file.parent.path == 'test' ? "import 'helpers/test_seeder.dart';" : "import '../helpers/test_seeder.dart';";
        content = content.replaceFirst("void main() {", "$seederImport\n\nvoid main() {");
      }
      
      if (content.contains('firestore = FakeFirebaseFirestore();') && !content.contains('TestSeeder.seedAdminEnvironment')) {
        var setupRegex = RegExp(r'setUp\(\(\) \{([\s\S]*?)firestore = FakeFirebaseFirestore\(\);([\s\S]*?)\}\);');
        if (setupRegex.hasMatch(content)) {
          content = content.replaceFirstMapped(setupRegex, (match) => "setUp(() async {${match.group(1)}firestore = FakeFirebaseFirestore();\n      await TestSeeder.seedAdminEnvironment(firestore);${match.group(2)}});");
        } else {
          var setupAsyncRegex = RegExp(r'setUp\(\(\) async \{([\s\S]*?)firestore = FakeFirebaseFirestore\(\);([\s\S]*?)\}\);');
          if (setupAsyncRegex.hasMatch(content)) {
            content = content.replaceFirstMapped(setupAsyncRegex, (match) => "setUp(() async {${match.group(1)}firestore = FakeFirebaseFirestore();\n      await TestSeeder.seedAdminEnvironment(firestore);${match.group(2)}});");
          }
        }
      }
      
      file.writeAsStringSync(content);
    }
  }
}
