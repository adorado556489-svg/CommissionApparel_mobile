import 'dart:io';

void clearLines(String path, int start, int end) {
  var lines = File(path).readAsLinesSync();
  for (var i = start - 1; i < end; i++) {
    lines[i] = "";
  }
  File(path).writeAsStringSync(lines.join('\n'));
}

void main() {
  clearLines('lib/services/auth_service.dart', 282, 287);
}
