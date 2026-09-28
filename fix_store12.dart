import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = "import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';\n" + content;
  file.writeAsStringSync(content);
}
