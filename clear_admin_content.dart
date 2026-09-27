import 'dart:io';

void replaceLine(String file, int line, String text) {
  var lines = File(file).readAsLinesSync();
  lines[line - 1] = text;
  File(file).writeAsStringSync(lines.join('\n'));
}

void clearLines(String file, int start, int end) {
  var lines = File(file).readAsLinesSync();
  for (var i = start - 1; i < end; i++) {
    lines[i] = "";
  }
  File(file).writeAsStringSync(lines.join('\n'));
}

void main() {
  // admin_service.dart
  clearLines('lib/services/admin_service.dart', 7, 11);
  clearLines('lib/services/admin_service.dart', 57, 58);
  clearLines('lib/services/admin_service.dart', 60, 60);
  clearLines('lib/services/admin_service.dart', 63, 67);
  clearLines('lib/services/admin_service.dart', 81, 81);
  clearLines('lib/services/admin_service.dart', 84, 88);
  clearLines('lib/services/admin_service.dart', 94, 94);
  clearLines('lib/services/admin_service.dart', 97, 97);
  clearLines('lib/services/admin_service.dart', 119, 122);
  clearLines('lib/services/admin_service.dart', 151, 155);
  clearLines('lib/services/admin_service.dart', 183, 187);
  clearLines('lib/services/admin_service.dart', 212, 213);
  clearLines('lib/services/admin_service.dart', 215, 215);
  clearLines('lib/services/admin_service.dart', 225, 225);
  clearLines('lib/services/admin_service.dart', 232, 232);
  clearLines('lib/services/admin_service.dart', 235, 235);
  clearLines('lib/services/admin_service.dart', 242, 242);
  clearLines('lib/services/admin_service.dart', 247, 247);
  clearLines('lib/services/admin_service.dart', 254, 254);
  clearLines('lib/services/admin_service.dart', 261, 261);
  clearLines('lib/services/admin_service.dart', 264, 264);
  clearLines('lib/services/admin_service.dart', 271, 271);
  clearLines('lib/services/admin_service.dart', 276, 276);
  clearLines('lib/services/admin_service.dart', 285, 285);
  clearLines('lib/services/admin_service.dart', 287, 288);
  clearLines('lib/services/admin_service.dart', 291, 291);
  clearLines('lib/services/admin_service.dart', 295, 301);
  clearLines('lib/services/admin_service.dart', 305, 305);
  clearLines('lib/services/admin_service.dart', 307, 308);
  clearLines('lib/services/admin_service.dart', 311, 311);
  clearLines('lib/services/admin_service.dart', 315, 321);
  clearLines('lib/services/admin_service.dart', 324, 324);
  clearLines('lib/services/admin_service.dart', 326, 327);
  clearLines('lib/services/admin_service.dart', 330, 330);
  clearLines('lib/services/admin_service.dart', 334, 340);
  clearLines('lib/services/admin_service.dart', 349, 349);
  clearLines('lib/services/admin_service.dart', 357, 357);
  clearLines('lib/services/admin_service.dart', 360, 360);

  // content_service.dart
  clearLines('lib/services/content_service.dart', 4, 5); // imports
  replaceLine('lib/services/content_service.dart', 140, "    return [];");
  replaceLine('lib/services/content_service.dart', 158, "    return [];");
  clearLines('lib/services/content_service.dart', 180, 182);
}
