import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains('Widget _buildDirectOrdersTab()')) {
      print('Found _buildDirectOrdersTab at line \${i + 1}');
    }
    if (lines[i].contains('Widget _buildOrderRow(')) {
      print('Found _buildOrderRow at line \${i + 1}');
    }
  }
}
