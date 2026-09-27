import 'dart:io';

void replaceLine(String file, int line, String text) {
  var lines = File(file).readAsLinesSync();
  lines[line - 1] = text;
  File(file).writeAsStringSync(lines.join('\n'));
}

void deleteLines(String file, int start, int end) {
  var lines = File(file).readAsLinesSync();
  for (var i = start - 1; i < end; i++) {
    lines[i] = "";
  }
  File(file).writeAsStringSync(lines.join('\n'));
}

void deleteMatch(String file, String text) {
  var lines = File(file).readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    if (lines[i].contains(text)) {
      lines[i] = "";
    }
  }
  File(file).writeAsStringSync(lines.join('\n'));
}

void main() {
  // OrderService
  deleteLines('lib/services/order_service.dart', 4, 5); // imports
  replaceLine('lib/services/order_service.dart', 31, "    return [];");
  deleteLines('lib/services/order_service.dart', 44, 47);
  deleteLines('lib/services/order_service.dart', 57, 57);
  deleteLines('lib/services/order_service.dart', 104, 104);
  deleteLines('lib/services/order_service.dart', 127, 133);
  deleteLines('lib/services/order_service.dart', 162, 169); // plus extra just in case? wait, let's use exact match
}
