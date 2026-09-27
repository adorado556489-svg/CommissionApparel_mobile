import 'dart:io';
void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("print('FOUND DOCS: \${qs.docs.length}'); ", "");
  file.writeAsStringSync(content);
}
