import 'dart:io';

void main() {
  var file = File('test/notification_workflow_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('AdminService.approveStore(firestore, store.id)', "StoreService.updateStore(firestore, store.copyWith(status: 'approved'))");
    content = content.replaceAll('ContentService.getUserNotifications(', "ContentService.getNotificationsForUser(");
    file.writeAsStringSync(content);
  }
}
