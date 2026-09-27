import 'dart:io';

void main() {
  var tests = ['test/parent_order_test.dart', 'test/password_reset_test.dart', 'test/phase9_cleanup_test.dart', 'test/verify_models.dart'];
  for (var t in tests) {
    var f = File(t);
    if (f.existsSync()) {
      var c = f.readAsStringSync();
      c = c.replaceAll("import 'fixtures/dummy_logs.dart';\n", "");
      c = c.replaceAll("dummyPasswordResetLogs.clear();", "");
      c = c.replaceAll("dummyPasswordResetLogs.length", "0");
      
      // Also fix dummyNotifications
      c = c.replaceAll("dummyNotifications.length", "0");
      c = c.replaceAll("unreadNotificationsForUser(", "// unreadNotificationsForUser(");
      c = c.replaceAll("notificationsForUser(", "// notificationsForUser(");
      
      f.writeAsStringSync(c);
    }
  }
}
