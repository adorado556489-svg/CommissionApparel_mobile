import 'dart:io';

void main() {
  var file = File('lib/screens/public/parent_order_form_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("([])", "(<TeamStore>[])");
  content = content.replaceAll("( (<TeamStore>[])).where", "(<StoreItem>[]).where");
  file.writeAsStringSync(content);
}
