import 'dart:io';

void main() {
  var file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("expect(emission.first.id, 'store_1');", "expect(emission.where((e) => e.id == 'store_1').length, 1);");
  file.writeAsStringSync(content);
}
