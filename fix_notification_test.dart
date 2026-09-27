import 'dart:io';

void main() {
  var file = File('test/notification_workflow_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("await AdminService.approveStore(firestore, adminUser, store.id);", "await AdminService.approveStore(firestore, store.id);");
  
  // also check other calls!
  content = content.replaceFirst("await AdminService.markDirectBatchAddressed(firestore, adminUser, directBatchId);", "await AdminService.markDirectBatchAddressed(firestore, adminUser, directBatchId);");
  file.writeAsStringSync(content);
}
