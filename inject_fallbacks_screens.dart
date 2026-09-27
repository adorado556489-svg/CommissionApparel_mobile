import 'dart:io';

void main() {
  final dir = Directory('lib/screens');
  
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      if (!content.contains("import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart';")) {
        content = "import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart';\n" + content;
        file.writeAsStringSync(content);
      }
    }
  }
}
