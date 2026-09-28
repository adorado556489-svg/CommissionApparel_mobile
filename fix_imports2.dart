import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      content = content.replaceAll("import 'package:commission_apparel_flutter/../test/helpers/test_seeder.dart';", "");
      
      // Calculate relative path
      var parts = file.path.split(Platform.pathSeparator);
      var depth = parts.length - 2; // test/a_test.dart -> 0, test/security/b_test.dart -> 1
      var relativePrefix = '';
      for (var i = 0; i < depth; i++) relativePrefix += '../';
      var importStatement = "import '${relativePrefix}helpers/test_seeder.dart';\n";
      
      content = importStatement + content;
      file.writeAsStringSync(content);
    }
  }
}
