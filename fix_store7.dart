import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("await Future.delayed(const Duration(milliseconds: 100));", "await tester.pump(const Duration(milliseconds: 100));");
  file.writeAsStringSync(content);
}
