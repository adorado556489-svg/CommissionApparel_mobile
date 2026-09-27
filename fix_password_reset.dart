import 'dart:io';

void main() {
  var file = File('test/password_reset_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('void main() {', 'var dummyPasswordResetLogs = [];\nvoid main() {');
  file.writeAsStringSync(content);
}
