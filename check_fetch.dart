import 'dart:io';

void main() {
  final file = File('lib/services/auth_service.dart');
  var lines = file.readAsLinesSync();
  int start = lines.indexWhere((l) => l.contains('_fetchAndSetUser'));
  if (start != -1) {
    for (int i = start; i < start + 30; i++) {
      if (i < lines.length) print(lines[i]);
    }
  }
}
