import 'dart:io';

void main() {
  var files = [
    'test/admin_catalog_test.dart',
    'test/admin_coach_test.dart',
    'test/admin_store_test.dart',
    'test/auth_test.dart',
    'test/catalog_service_test.dart',
    'test/coach_direct_order_test.dart',
    'test/coach_order_edit_test.dart',
    'test/coach_store_test.dart',
    'test/password_reset_test.dart',
    'test/phase9_cleanup_test.dart'
  ];
  
  for (var path in files) {
    var file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // Remove the injected line
      content = content.replaceAll("await TestSeeder.seedAll(firestore);\n", "");
      content = content.replaceAll("await TestSeeder.seedAll(firestore);", "");
      
      // Let's just remove it completely from these files to see if they need it.
      // Most widget tests didn't actually read dummyLists directly, they mocked the service!
      // Wait, no. They do read from firestore now because the UI uses FutureBuilder with Firebase!
      // But if they failed because firestore was undefined, it means they were NOT using a global firestore variable!
      file.writeAsStringSync(content);
    }
  }
}
