import 'dart:io';

void main() {
  final servicesDir = Directory('lib/services');
  
  for (var file in servicesDir.listSync()) {
    if (file is File && file.path.endsWith('.dart') && !file.path.endsWith('dummy_fallbacks.dart')) {
      var content = file.readAsStringSync();
      if (!content.contains("import 'dummy_fallbacks.dart';")) {
        content = "import 'dummy_fallbacks.dart';\n" + content;
        file.writeAsStringSync(content);
      }
    }
  }
}
