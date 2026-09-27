import 'dart:io';
void main() {
  var file = File('test/notification_workflow_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("await AdminService.approveStore(firestore, adminUser, store);", "await AdminService.approveStore(firestore, adminUser, store.id);");
  file.writeAsStringSync(content);
}
