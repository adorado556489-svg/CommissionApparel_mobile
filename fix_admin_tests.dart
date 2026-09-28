import 'dart:io';

void main() {
  var files = ['test/admin_catalog_test.dart', 'test/admin_coach_test.dart', 'test/admin_store_test.dart'];
  for (var path in files) {
    var file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      content = content.replaceFirst("await TestSeeder.seedAll(firestore);\n", "");
      // Now define it globally
      if (!content.contains('late FakeFirebaseFirestore firestore;')) {
        content = content.replaceAll('void main() {', "void main() {\n  late FakeFirebaseFirestore firestore;");
      }
      if (!content.contains('firestore = FakeFirebaseFirestore();')) {
        content = content.replaceAll('setUp(() async {', "setUp(() async {\n    firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);");
      }
      content = content.replaceAll('Provider<FirebaseFirestore>.value(value: FakeFirebaseFirestore())', 'Provider<FirebaseFirestore>.value(value: firestore)');
      content = content.replaceAll('Widget createTestApp(Widget home, AuthService auth) {', 'Widget createTestApp(Widget home, AuthService auth, [FirebaseFirestore? fs]) {\n  fs ??= firestore;');
      content = content.replaceAll('Provider<FirebaseFirestore>.value(value: firestore)', 'Provider<FirebaseFirestore>.value(value: fs!)');
      
      file.writeAsStringSync(content);
    }
  }
}
