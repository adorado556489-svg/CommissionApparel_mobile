import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  if (code.contains("setState(() {});")) {
    code = code.replaceAll("setState(() {});", "await _loadData();");
    file.writeAsStringSync(code);
    print("Replaced setState with await _loadData");
  }
}
