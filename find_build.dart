import 'dart:io';
void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget build(BuildContext context)')) {
      print('Found build at line ' + (i + 1).toString());
    }
  }
}
