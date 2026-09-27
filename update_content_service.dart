import 'dart:io';

void main() {
  final file = File('lib/services/content_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');
  
  final streamMethod = '''  static Stream<List<NotificationItem>> getUserNotificationsStream(FirebaseFirestore firestore, String userId) {
    return firestore
        .collection(FirestorePaths.notifications)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) {
          if (qs.docs.isEmpty) {
            return dummyNotifications.where((n) => n.userId == userId).toList();
          }
          return qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList();
        });
  }

  static Future<List<NotificationItem>> getUserNotifications''';
  
  content = content.replaceFirst('static Future<List<NotificationItem>> getUserNotifications', streamMethod);
  file.writeAsStringSync(content);
}
