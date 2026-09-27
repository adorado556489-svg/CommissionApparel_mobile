import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll("if (qs.docs.isNotEmpty) {", "print('FOUND DOCS: \${qs.docs.length}'); if (qs.docs.isNotEmpty) {");
  file.writeAsStringSync(content);
}
