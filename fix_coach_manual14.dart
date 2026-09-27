import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll("imagePaths: design.imagePath != null ? [design.imagePath!] : const [],", "imagePaths: design.displayImage != null ? [design.displayImage!] : const [],");
  
  file.writeAsStringSync(content);
}
