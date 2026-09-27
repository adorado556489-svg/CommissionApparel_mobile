import 'dart:io';

void main() {
  final files = [
    'dummy_users.dart',
    'dummy_stores.dart',
    'dummy_orders.dart',
    'dummy_catalog.dart',
    'dummy_content.dart',
    'dummy_quotes.dart',
    'dummy_notifications.dart',
  ];

  for (var file in files) {
    final f = File('test/fixtures/$file');
    if (f.existsSync()) {
      var content = f.readAsStringSync();
      
      content = content.replaceAll("import '../models/", "import 'package:commission_apparel_flutter/models/");
      content = content.replaceAll("import '../utils/", "import 'package:commission_apparel_flutter/utils/");
      
      f.writeAsStringSync(content);
    }
  }
}
