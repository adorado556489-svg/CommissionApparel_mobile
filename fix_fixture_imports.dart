import 'dart:io';

void fixImports(String dir) {
  for (var file in Directory(dir).listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      content = content.replaceAll("import '../models/", "import '../../lib/models/");
      content = content.replaceAll("import '../constants/", "import '../../lib/constants/");
      file.writeAsStringSync(content);
    }
  }
}

void main() {
  fixImports('test/fixtures');
}
