import 'dart:io';

void fixImports(String dir) {
  for (var file in Directory(dir).listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      content = content.replaceAll("import '../../lib/models/", "import 'package:commission_apparel_flutter/models/");
      content = content.replaceAll("import '../../lib/constants/", "import 'package:commission_apparel_flutter/constants/");
      file.writeAsStringSync(content);
    }
  }
}

void main() {
  fixImports('test/fixtures');
}
