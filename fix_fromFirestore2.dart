import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var newContent = content.replaceAll(RegExp(r'ParentOrder\.fromFirestore\(([^,]+)\.data\(\)!?\s*,\s*[^)]+\)'), r'ParentOrder.fromFirestore($1)');
      if (content != newContent) {
        file.writeAsStringSync(newContent);
        print("Fixed ${file.path}");
      }
    }
  }
}
