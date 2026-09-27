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
      
      var regExp = RegExp(r'final\s+List<([A-Za-z]+)>\s+(dummy[A-Za-z]+)\s*=');
      
      content = content.replaceAllMapped(regExp, (match) {
        var type = match.group(1);
        var name = match.group(2);
        return 'final List<$type> raw$name =';
      });
      
      var exports = "import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart' as f;\n";
      
      var matches = RegExp(r'final\s+List<([A-Za-z]+)>\s+raw(dummy[A-Za-z]+)\s*=').allMatches(content);
      for (var match in matches) {
        var type = match.group(1);
        var name = match.group(2);
        content += "\nList<$type> get $name => f.$name;\n";
      }
      
      if (!content.contains('package:commission_apparel_flutter/services/dummy_fallbacks.dart')) {
        content = exports + content;
      }
      
      f.writeAsStringSync(content);
    }
  }
}
