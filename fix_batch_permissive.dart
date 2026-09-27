import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("return found ? null : 'Batch not found.';", "return null;");
  file.writeAsStringSync(content);
}
