import 'dart:io';

void main() {
  var file = File('lib/screens/public/parent_order_form_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("storeItems = (<TeamStore>[]).where", "storeItems = (<StoreItem>[]).where");
  file.writeAsStringSync(content);
}
