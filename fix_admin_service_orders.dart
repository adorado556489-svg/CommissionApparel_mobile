import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("'parentOrders'", "'orders'");
  file.writeAsStringSync(content);
}
