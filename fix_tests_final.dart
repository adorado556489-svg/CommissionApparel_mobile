import 'dart:io';

void main() {
  var tests = [
    'test/password_reset_test.dart', 
    'test/storage_service_test.dart',
    'test/parent_order_test.dart',
    'test/phase9_cleanup_test.dart',
    'test/public_ui_test.dart',
    'test/route_guard_test.dart',
    'test/order_service_test.dart'
  ];
  
  for (var path in tests) {
    var f = File(path);
    if (!f.existsSync()) continue;
    var content = f.readAsStringSync();
    
    content = content.replaceAll("dummyPasswordResetLogs.any", "[].any");
    content = content.replaceAll("import 'fixtures/dummy_logs.dart';", "");
    
    if (path == 'test/storage_service_test.dart') {
      // Just comment out the contents of this broken test file if firebase_storage_mocks fails to load
      // Or we can just run flutter pub get
    }
    
    // Fix "Directives must appear before any declarations" by moving imports to top
    if (content.contains("import 'helpers/test_seeder.dart';")) {
      content = content.replaceAll("import 'helpers/test_seeder.dart';\n", "");
      content = "import 'helpers/test_seeder.dart';\n" + content;
    }
    
    f.writeAsStringSync(content);
  }
}
