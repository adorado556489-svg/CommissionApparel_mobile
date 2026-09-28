import 'dart:io';

void main() {
  var files = ['test/admin_catalog_test.dart', 'test/admin_coach_test.dart', 'test/admin_store_test.dart'];
  for (var path in files) {
    var file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // change `fs ??= firestore;` to nothing, and pass FakeFirebaseFirestore directly if fs is null
      content = content.replaceAll('fs ??= firestore;', 'fs ??= FakeFirebaseFirestore();');
      file.writeAsStringSync(content);
    }
  }
}
