import 'dart:io';

void main() {
  var dir = Directory('test/fixtures');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var changed = false;
      var newContent = content.replaceAll(RegExp(r'List<[^>]+>\s+get\s+rawdummy[a-zA-Z0-9_]+\s*=>\s*\[\];\n?'), '');
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print("Fixed ${file.path}");
      }
    }
  }
}
