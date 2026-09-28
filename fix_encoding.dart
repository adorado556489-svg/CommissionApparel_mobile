import 'dart:io';
import 'dart:convert';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      try {
        file.readAsStringSync(encoding: utf8);
      } catch (e) {
        print("Fixing encoding for ${file.path}");
        var bytes = file.readAsBytesSync();
        // Check for UTF-16 LE BOM (FF FE)
        if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
          var str = utf8.decode(bytes.sublist(2), allowMalformed: true);
          // Wait, utf8.decode on UTF-16 bytes will be malformed.
          // Better: read with UTF-16
        }
      }
    }
  }
}
