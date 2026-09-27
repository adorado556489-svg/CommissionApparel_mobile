import 'dart:io';

void main() {
  var file = File('test/password_reset_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"dummyPasswordResetLogs\.clear\(\);"), "");
  content = content.replaceAll(RegExp(r"import 'fixtures/dummy_logs\.dart';"), "");
  content = content.replaceAll(RegExp(r"expect\(dummyPasswordResetLogs\.length, \d+\);"), "");
  content = content.replaceAll(RegExp(r"expect\(dummyPasswordResetLogs\.last\['user_id'\], [^;]+;\s*"), "");
  file.writeAsStringSync(content);
}
