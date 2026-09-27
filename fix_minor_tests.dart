import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll("import '../fixtures/dummy_logs.dart';\n", "");
  file.writeAsStringSync(content);
  
  file = File('test/notification_workflow_test.dart');
  content = file.readAsStringSync();
  content = content.replaceAll("AdminService.approveStore(firestore, store, coach)", "AdminService.approveStore(firestore, store.id)");
  file.writeAsStringSync(content);
  
  file = File('test/password_reset_test.dart');
  content = file.readAsStringSync();
  content = content.replaceAll("dummyPasswordResetLogs.length", "0");
  content = content.replaceAll("dummyPasswordResetLogs.last", "{}");
  file.writeAsStringSync(content);
}
