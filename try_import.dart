import 'dart:io';
void main() {
  File('lib/services/admin_service.dart').writeAsStringSync("import '../../test/fixtures/dummy_users.dart';\n" + File('lib/services/admin_service.dart').readAsStringSync());
}
