import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var lines = file.readAsLinesSync();
  
  var newLines = lines.where((line) => !line.contains('dummy')).toList();
  
  file.writeAsStringSync(newLines.join('\n'));
}
