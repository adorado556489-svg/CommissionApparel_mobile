import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_coach_edit_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("final error = AdminService.resetCoachPassword(admin, _coach, _passwordCtrl.text);", "final error = await AdminService.resetCoachPassword(FirebaseFirestore.instance, admin, _coach, _passwordCtrl.text);");
  file.writeAsStringSync(content);
}
