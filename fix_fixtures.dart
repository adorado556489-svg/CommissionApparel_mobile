import 'dart:io';

void main() {
  final files = [
    'dummy_users.dart',
    'dummy_stores.dart',
    'dummy_orders.dart',
    'dummy_content.dart',
    'dummy_quotes.dart',
    'dummy_catalog.dart',
    'dummy_notifications.dart',
    'dummy_data.dart'
  ];

  for (var file in files) {
    final f = File('test/fixtures/$file');
    if (f.existsSync()) {
      f.writeAsStringSync("export 'package:commission_apparel_flutter/services/dummy_fallbacks.dart';\n");
    }
  }
}
