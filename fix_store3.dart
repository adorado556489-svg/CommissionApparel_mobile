import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  if (!content.contains('test_seeder.dart')) {
    content = "import 'helpers/test_seeder.dart';\n" + content;
  }
  file.writeAsStringSync(content);
}
