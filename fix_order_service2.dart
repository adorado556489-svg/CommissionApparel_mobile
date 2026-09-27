import 'dart:io';

void main() {
  var file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("FirestorePaths.parentOrders", "'orders'");
  file.writeAsStringSync(content);
}
