import 'dart:io';

void main() {
  var files = [
    'lib/screens/admin/admin_dashboard_screen.dart',
    'lib/screens/admin/widgets/admin_catalog_tab.dart'
  ];
  for (var path in files) {
    var file = File(path);
    var content = file.readAsStringSync();
    if (!content.contains("import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart';")) {
      content = "import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart';\n" + content;
      // dummyCoaches is in admin_catalog_tab.dart, we need to map it correctly.
      // dummyCoaches is a list of User where role == 'coach'.
      // If it complains about dummyCoaches, I will define it in dummy_fallbacks!
      file.writeAsStringSync(content);
    }
  }
}
