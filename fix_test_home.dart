import 'dart:io';

void main() {
  var file = File('test/test_home.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"import 'fixtures/[^']+';\n"), "");
  file.writeAsStringSync(content);
}
