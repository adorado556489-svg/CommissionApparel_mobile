import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('fixtures')) {
      var content = file.readAsStringSync();
      
      content = content.replaceAll(RegExp(r"import '\.\./fixtures/[^']+';\n?"), "");
      content = content.replaceAll(RegExp(r"import 'fixtures/[^']+';\n?"), "");
      content = content.replaceAll(RegExp(r"import '\.\./\.\./fixtures/[^']+';\n?"), "");
      
      // Inject correct imports
      String prefix = file.path.contains('helpers') ? '../' : '';
      
      var imports = '''
import '${prefix}fixtures/dummy_users.dart';
import '${prefix}fixtures/dummy_stores.dart';
import '${prefix}fixtures/dummy_orders.dart';
import '${prefix}fixtures/dummy_catalog.dart';
import '${prefix}fixtures/dummy_content.dart';
import '${prefix}fixtures/dummy_quotes.dart';
''';
      // Insert after package imports
      var lastImport = content.lastIndexOf(RegExp(r"import '[^']+';"));
      if (lastImport != -1) {
         var insertPos = content.indexOf('\n', lastImport) + 1;
         content = content.substring(0, insertPos) + imports + content.substring(insertPos);
      } else {
         content = imports + content;
      }
      
      file.writeAsStringSync(content);
    }
  }
}
