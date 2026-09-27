import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  if (!content.contains('List<NotificationItem> dummyNotifications = [];')) {
    content = content.replaceFirst('List<Map<String, dynamic>> dummyPasswordResetLogs = [];', 'List<Map<String, dynamic>> dummyPasswordResetLogs = [];\nList<NotificationItem> dummyNotifications = [];');
    content = content.replaceFirst("import 'package:commission_apparel_flutter/models/site_setting.dart';", "import 'package:commission_apparel_flutter/models/site_setting.dart';\nimport 'package:commission_apparel_flutter/models/notification_item.dart';");
    file.writeAsStringSync(content);
  }
}
