import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("import '../fixtures/dummy_quotes.dart';", "import '../fixtures/dummy_quotes.dart';\nimport '../fixtures/dummy_notifications.dart';");
  file.writeAsStringSync(content);
}
