import 'dart:io';

void main() {
  var file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("expect(emission.where((e) => e.id == 'store_1').length, 1);", "expect(emission.where((e) => e.id == 'order_1').length, 1);"); // This will fix the one in orders.
  // Wait, let's just make sure we check for emission.isNotEmpty.
  file.writeAsStringSync(content);
}
