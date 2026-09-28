import 'dart:io';

void main() {
  var file = File('test/order_service_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('OrderService.getAllOrders(firestore)', 'OrderService.getOrdersForUser(firestore, "user-coach-1")');
    content = content.replaceAll('OrderService.getAllOrders(throwingFirestore)', 'OrderService.getOrdersForUser(throwingFirestore, "user-coach-1")');
    file.writeAsStringSync(content);
  }
}
