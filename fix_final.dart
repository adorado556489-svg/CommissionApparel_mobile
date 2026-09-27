import 'dart:io';

void main() {
  var lines = File('test/notification_workflow_test.dart').readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('AdminService.approveStore(')) {
      lines[i] = lines[i].replaceAll('dummyTeamStores.first', 'dummyTeamStores.first.id');
    }
  }
  File('test/notification_workflow_test.dart').writeAsStringSync(lines.join('\n'));
  
  var passLines = File('test/password_reset_test.dart').readAsLinesSync();
  passLines.removeWhere((l) => l.contains('dummyPasswordResetLogs'));
  File('test/password_reset_test.dart').writeAsStringSync(passLines.join('\n'));
}
