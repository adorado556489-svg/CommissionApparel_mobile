import 'dart:io';
void main() {
  var path = 'lib/services/content_service.dart';
  var file = File(path);
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceFirst('static Future<void> markNotificationRead(dynamic firestore, String id) async {}', 'static Future<void> markNotificationRead(dynamic firestore, String id, String userId) async {}');
    file.writeAsStringSync(content);
  }
}
