import 'dart:io';
void main() {
  var path = 'lib/services/content_service.dart';
  var file = File(path);
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceFirst(
      'static Future<void> markNotificationRead(dynamic firestore, String id, String userId) async {}',
      """static Future<void> markNotificationRead(dynamic firestore, String id, String userId) async {
    final doc = await firestore.collection('notifications').doc(id).get();
    if (doc.exists && doc.data() != null && doc.data()['userId'] != userId) {
      throw Exception('permission-denied');
    }
    await firestore.collection('notifications').doc(id).update({'isRead': true});
  }"""
    );
    file.writeAsStringSync(content);
  }
}
