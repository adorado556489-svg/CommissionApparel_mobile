import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      
      bool changed = false;
      if (content.contains('FakeFirebaseFirestore') && !content.contains('seedAll(firestore)')) {
        if (content.contains('setUp(() async {')) {
          content = content.replaceFirst('setUp(() async {', "setUp(() async {\n    await TestSeeder.seedAll(firestore);\n");
          changed = true;
        } else if (content.contains('setUp(() {')) {
          content = content.replaceFirst('setUp(() {', "setUp(() async {\n    await TestSeeder.seedAll(firestore);\n");
          changed = true;
        }
      }
      
      if (changed) {
        if (!content.contains('import \'package:commission_apparel_flutter/test/helpers/test_seeder.dart\';') && !content.contains('test_seeder.dart')) {
            // we will just use a relative or absolute-like package import
            content = "import 'helpers/test_seeder.dart';\n" + content;
        }
        file.writeAsStringSync(content);
      }
    }
  }
}
