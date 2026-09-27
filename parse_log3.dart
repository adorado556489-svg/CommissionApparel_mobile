import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

void main() {
  var file = File('test_results.log');
  var bytes = file.readAsBytesSync();
  
  String content;
  if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xFE) {
    var units = <int>[];
    for (int i = 2; i < bytes.length; i += 2) {
      if (i + 1 < bytes.length) {
        units.add(bytes[i] | (bytes[i + 1] << 8));
      }
    }
    content = String.fromCharCodes(units);
  } else {
    try {
      content = utf8.decode(bytes);
    } catch (_) {
      content = String.fromCharCodes(bytes);
    }
  }

  var lines = content.split('\n');
  var fails = <String>[];
  var inFails = false;
  
  for (var line in lines) {
    line = line.trimRight();
    if (line.startsWith('Failing tests:')) {
      inFails = true;
      continue;
    }
    if (inFails) {
      if (line.trim().isNotEmpty) {
        fails.add(line.trim());
      }
    }
  }

  print('TOTAL FAILURES: ${fails.length}');
  for (var f in fails) {
    print(f);
  }
}
