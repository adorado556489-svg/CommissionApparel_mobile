import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      bool changed = false;
      
      // Fix imports position
      var imports = <String>[];
      var lines = content.split('\n');
      var newLines = <String>[];
      
      for (var line in lines) {
        if (line.startsWith("import 'fixtures/") || line.startsWith("import '../fixtures/") || line.startsWith("import 'helpers/test_seeder.dart';")) {
          imports.add(line);
          changed = true;
        } else {
          newLines.add(line);
        }
      }
      
      if (changed) {
        // Insert after last import, or at top
        var newContent = newLines.join('\n');
        var lastImport = newContent.lastIndexOf(RegExp(r"import '[^']+';"));
        if (lastImport != -1) {
          var insertPos = newContent.indexOf('\n', lastImport) + 1;
          newContent = newContent.substring(0, insertPos) + imports.join('\n') + '\n' + newContent.substring(insertPos);
        } else {
          newContent = imports.join('\n') + '\n' + newContent;
        }
        file.writeAsStringSync(newContent);
      }
    }
  }
}
