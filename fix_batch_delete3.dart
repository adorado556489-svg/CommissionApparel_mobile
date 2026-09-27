import 'dart:io';
void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("return 'Archived order batch not found.';", "return null;");
  file.writeAsStringSync(content);
}
