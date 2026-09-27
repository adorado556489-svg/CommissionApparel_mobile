import 'dart:io';

void main() {
  var file = File('test/route_guard_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"auth = AuthService"), "var auth = AuthService");
  file.writeAsStringSync(content);
}
