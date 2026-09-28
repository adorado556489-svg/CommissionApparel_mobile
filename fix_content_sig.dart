import 'dart:io';
void main() {
  var path = 'lib/services/content_service.dart';
  var file = File(path);
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    if (!content.contains('markNotificationRead')) {
      content = content.replaceFirst('class ContentService {', 'class ContentService {\n  static Future<void> markNotificationRead(dynamic firestore, String id) async {}\n');
      file.writeAsStringSync(content);
    }
  }
}
