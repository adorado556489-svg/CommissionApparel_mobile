import 'dart:io';

void main() {
  var file = File('test_results.log');
  var lines = file.readAsLinesSync();
  
  var failures = <String>[];
  var inFail = false;
  
  for (var line in lines) {
    if (line.startsWith('Failing tests:')) {
      inFail = true;
      continue;
    }
    if (inFail) {
      if (line.trim().isNotEmpty) {
        failures.add(line.trim());
      }
    }
  }
  
  print('TOTAL FAILURES: ${failures.length}');
  for (var f in failures) {
    print(f);
  }
}
