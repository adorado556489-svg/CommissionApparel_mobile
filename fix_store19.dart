import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
    "if (_unbatchedOrders.isEmpty) {",
    "print('SUBMIT MASTER ORDER: length=\${_unbatchedOrders.length}');\n      if (_unbatchedOrders.isEmpty) {"
  );
  file.writeAsStringSync(content);
}
