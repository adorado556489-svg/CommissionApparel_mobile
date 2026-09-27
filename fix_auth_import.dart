import 'dart:io';
void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("import '../models/user.dart';", "import '../models/user.dart';\nimport 'dummy_fallbacks.dart';");
  file.writeAsStringSync(content);
}
