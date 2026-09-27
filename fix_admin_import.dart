import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("import '../../test/fixtures/dummy_users.dart';\n", "");
  file.writeAsStringSync(content);
}
