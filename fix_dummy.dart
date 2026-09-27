
import 'dart:io';

void main() {
  final files = [
    'lib/services/auth_service.dart',
    'lib/services/order_service.dart',
    'lib/services/admin_service.dart',
    'lib/services/store_service.dart',
    'lib/services/catalog_service.dart',
    'lib/services/content_service.dart'
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) continue;

    var c = file.readAsStringSync();

    // Remove imports
    c = c.replaceAll(RegExp(r'import .*/data/dummy_.*\\n'), '');
    
    // Remove if(qs.docs.isNotEmpty) wrapping map...
    c = c.replaceAll(RegExp(r'if\s*\((qs|snap)\.docs\.isNotEmpty\)\s*\{\s*return\s*(qs|snap)\.docs\.map[^}]+\}\s*\}\s*catch\s*\((e|_)\)\s*\{\s*_handleError[^}]+\}\s*return\s*dummy[a-zA-Z0-9_]+(?:\.toList\(\))?;', multiLine: true), 
      'return \.docs.map((d) => \.docs.first.data() /* WILL BE BROKEN, NEED TO RETHINK */).toList();');

  }
}
