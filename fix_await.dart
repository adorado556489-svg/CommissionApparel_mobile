import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix await in wrong context
  content = content.replaceAll(
    'onPressed: () {',
    'onPressed: () async {'
  );
  
  // Actually, replaceAll might replace other unrelated things, but they are buttons, so making them async is fine.
  
  file.writeAsStringSync(content);
}
