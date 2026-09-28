import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"final qs_test.*?; }", dotAll: true), "");
  file.writeAsStringSync(content);
}
