import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('fixtures')) {
      var content = file.readAsStringSync();
      
      content = content.replaceAll(RegExp(r"import 'package:commission_apparel_flutter/data/dummy_[^']+';\n?"), "");
      content = content.replaceAll(RegExp(r"import '\.\./lib/data/dummy_[^']+';\n?"), "");
      content = content.replaceAll(RegExp(r"import '\.\./\.\./lib/data/dummy_[^']+';\n?"), "");
      
      // Inject standard fixtures imports!
      if (content.contains('dummyUsers') || content.contains('dummyParentOrders') || content.contains('dummyTeamStores')) {
         var imports = '''
import 'fixtures/dummy_users.dart';
import 'fixtures/dummy_stores.dart';
import 'fixtures/dummy_orders.dart';
import 'fixtures/dummy_catalog.dart';
import 'fixtures/dummy_content.dart';
import 'fixtures/dummy_quotes.dart';
import 'fixtures/dummy_logs.dart';
''';
         // Insert after other imports
         var lastImport = content.lastIndexOf(RegExp(r"import '[^']+';"));
         if (lastImport != -1) {
            var insertPos = content.indexOf('\n', lastImport) + 1;
            content = content.substring(0, insertPos) + imports + content.substring(insertPos);
         } else {
            content = imports + content;
         }
      }
      
      file.writeAsStringSync(content);
    }
  }
}
