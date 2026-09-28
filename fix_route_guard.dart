import 'dart:io';

void main() {
  var path = 'test/route_guard_test.dart';
  if (File(path).existsSync()) {
    var content = File(path).readAsStringSync();
    content = content.replaceAll("'Coach Dashboard'", "'My Store'");
    File(path).writeAsStringSync(content);
  }
  print('Done fixing route_guard_test');
}
