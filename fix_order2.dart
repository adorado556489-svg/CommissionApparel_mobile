import 'dart:io';

void main() {
  var file = File('test/order_service_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('getOrdersByUserId(', 'getOrdersForUser(');
    file.writeAsStringSync(content);
  }
}
