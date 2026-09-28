import 'dart:io';

void main() {
  var dir = Directory('test/fixtures');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var lines = file.readAsLinesSync();
      var newLines = lines.where((line) => !line.contains('get rawdummy')).toList();
      if (lines.length != newLines.length) {
        file.writeAsStringSync(newLines.join('\n'));
        print("Fixed getters in ${file.path}");
      }
    }
  }
}
