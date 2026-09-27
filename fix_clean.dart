
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

    // 1. Remove all dummy list imports
    c = c.replaceAll(RegExp(r'import .*/data/dummy_.*' + '\\n'), '');
    c = c.replaceAll(RegExp(r'import .*/fixtures/dummy_.*' + '\\n'), '');

    // 2. Auth service logic
    c = c.replaceAll(RegExp(r'// Fallback to dummy users[\\s\\S]*?}\\s*}\\s*}', multiLine: true), '}');
    c = c.replaceAll(RegExp(r'try \{ return dummy[a-zA-Z0-9_]+\.firstWhere[^}]+\} catch \(\_\) \{ return null; \}'), 'return null;');

    file.writeAsStringSync(c);
  }
}
