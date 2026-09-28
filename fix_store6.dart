import 'dart:io';

void main() {
  var file = File('test/coach_store_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("await auth.login('coach@example.com', 'password123');", "await auth.login('coach@example.com', 'password123');\n      await Future.delayed(const Duration(milliseconds: 100));");
  content = content.replaceAll("await auth.login('david.chen@trackclub.org', 'password123');", "await auth.login('david.chen@trackclub.org', 'password123');\n      await Future.delayed(const Duration(milliseconds: 100));");
  file.writeAsStringSync(content);
}
