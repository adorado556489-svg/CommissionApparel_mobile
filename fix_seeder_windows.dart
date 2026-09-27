import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("import 'fixtures/", "import '../fixtures/");
  file.writeAsStringSync(content);
}
