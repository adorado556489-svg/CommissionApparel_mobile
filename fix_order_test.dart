import 'dart:io';

void main() {
  var file = File('test/order_service_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('getAllOrders(firestore)', "getOrdersByUserId(firestore, 'user1')");
    content = content.replaceAll('getAllOrders(throwingFirestore)', "getOrdersByUserId(throwingFirestore, 'user1')");
    file.writeAsStringSync(content);
  }
}
