import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  if (!content.contains('dummyStoreItemComments')) {
    content = content.replaceFirst('List<NotificationItem> dummyNotifications = [];', 'List<NotificationItem> dummyNotifications = [];\nList<dynamic> dummyStoreItemComments = [];');
    file.writeAsStringSync(content);
  }
}
