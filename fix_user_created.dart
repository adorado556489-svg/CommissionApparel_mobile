import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("UserRole.admin, password: '');", "UserRole.admin, password: '', createdAt: DateTime.now(), updatedAt: DateTime.now());");
  file.writeAsStringSync(content);
  
  file = File('lib/screens/public/store_search_screen.dart');
  content = file.readAsStringSync();
  if (!content.contains("import '../../models/user.dart';")) {
    content = "import '../../models/user.dart';\n" + content;
  }
  content = content.replaceAll("return User(id: '', email: '', firstName: '', lastName: '', password: '', role: 'coach');", "return User(id: '', email: '', firstName: '', lastName: '', password: '', role: UserRole.coach, createdAt: DateTime.now(), updatedAt: DateTime.now());");
  file.writeAsStringSync(content);
}
