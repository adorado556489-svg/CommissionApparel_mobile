import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      content = content.replaceAll("import 'helpers/test_seeder.dart';", "");
      content = "import 'package:commission_apparel_flutter/../test/helpers/test_seeder.dart';\n" + content;
      file.writeAsStringSync(content);
    }
  }
}
