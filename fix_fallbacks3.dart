import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  if (!content.contains('dummyAdmin')) {
    content += "\nUser dummyAdmin = User(id: 'admin', email: 'admin@example.com', firstName: 'Admin', lastName: 'Admin', role: UserRole.admin, password: '');\n";
    file.writeAsStringSync(content);
  }
}
