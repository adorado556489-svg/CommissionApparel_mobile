import 'dart:io';

void main() {
  final file = File('lib/services/auth_service.dart');
  var lines = file.readAsLinesSync();
  int start = lines.indexWhere((l) => l.contains('Future<String?> login'));
  if (start != -1) {
    for (int i = start + 30; i < start + 60; i++) {
      if (i < lines.length) print(lines[i]);
    }
  }
}
