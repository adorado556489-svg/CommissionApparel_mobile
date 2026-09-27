import 'dart:io';
void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildTabButton(')) {
      print('Found _buildTabButton at line ' + (i + 1).toString());
    }
  }
}
