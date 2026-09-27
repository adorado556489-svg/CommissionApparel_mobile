import 'dart:io';

void main() {
  var dir = Directory('test');
  var files = dir.listSync(recursive: false).whereType<File>().where((f) => f.path.endsWith('_test.dart'));
  for (var file in files) {
    var content = file.readAsStringSync();
    if (!content.contains("TestSeeder.populateDummyFallbacks();")) {
      content = content.replaceFirst("void main() {", "void main() {\n  TestSeeder.populateDummyFallbacks();\n");
      if (!content.contains("import 'helpers/test_seeder.dart';")) {
        content = "import 'helpers/test_seeder.dart';\n" + content;
      }
      file.writeAsStringSync(content);
    }
  }
}
