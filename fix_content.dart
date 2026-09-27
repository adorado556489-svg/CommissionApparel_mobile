import 'dart:io';

void main() {
  var lines = File('lib/services/content_service.dart').readAsLinesSync();
  lines[159] = ""; // 160
  lines[179] = ""; // 180
  lines[180] = ""; // 181
  File('lib/services/content_service.dart').writeAsStringSync(lines.join('\n'));
}
