import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(RegExp(r"import '\.\./\.\./data/dummy_.*';\n"), "");
  file.writeAsStringSync(content);
}
