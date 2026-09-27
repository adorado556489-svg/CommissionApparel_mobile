import 'dart:io';

void main() {
  for (var fileStr in ['test/auth_test.dart', 'test/phase1_auth_test.dart']) {
    var file = File(fileStr);
    var content = file.readAsStringSync();
    if (!content.contains("TestWidgetsFlutterBinding.ensureInitialized();")) {
      content = content.replaceFirst("void main() {", "void main() {\n  TestWidgetsFlutterBinding.ensureInitialized();");
      file.writeAsStringSync(content);
    }
  }
}
