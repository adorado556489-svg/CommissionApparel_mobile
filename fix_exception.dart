import 'dart:io';
void main() {
  var path = 'lib/services/content_service.dart';
  var file = File(path);
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll(
      "throw Exception('permission-denied');",
      "throw FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');"
    );
    if (!content.contains('FirebaseException')) {
       // if it wasn't replaced, just ensure it imports it
    }
    file.writeAsStringSync(content);
  }
}
