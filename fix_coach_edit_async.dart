import 'dart:io';

void main() {
  var file = File('lib/screens/admin/admin_coach_edit_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("void _resetPassword() {", "Future<void> _resetPassword() async {");
  file.writeAsStringSync(content);
}
