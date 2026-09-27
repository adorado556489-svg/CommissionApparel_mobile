import 'dart:io';

void main() {
  // Fix NotificationItem
  var notifFile = File('lib/models/notification_item.dart');
  var notifContent = notifFile.readAsStringSync();
  // Remove the duplicate isRead. It might be at the end.
  var lines = notifContent.split('\n');
  int isReadCount = 0;
  List<String> newLines = [];
  for (var line in lines) {
    if (line.contains('bool get isRead => readAt != null;')) {
      isReadCount++;
      if (isReadCount > 1) {
        continue;
      }
    }
    newLines.add(line);
  }
  notifFile.writeAsStringSync(newLines.join('\n'));

  // Fix admin_catalog_tab.dart
  var catalogTabFile = File('lib/screens/admin/widgets/admin_catalog_tab.dart');
  var catalogTabContent = catalogTabFile.readAsStringSync();
  // Change onPressed: () { to onPressed: () async {
  catalogTabContent = catalogTabContent.replaceFirst('onPressed: () {', 'onPressed: () async {');
  catalogTabFile.writeAsStringSync(catalogTabContent);
}
