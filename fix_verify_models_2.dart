import 'dart:io';

void main() {
  var verifyFile = File('test/verify_models.dart');
  var content = verifyFile.readAsStringSync();
  if (!content.contains("import 'fixtures/dummy_data.dart';")) {
    content = "import 'fixtures/dummy_data.dart';\n" + content;
  }
  verifyFile.writeAsStringSync(content);
}
