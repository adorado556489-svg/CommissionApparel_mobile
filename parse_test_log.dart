import 'dart:io';

void main() {
  var file = File(r'C:\Users\User\.gemini\antigravity\brain\068df35f-91ee-4740-9ef4-9cc7d9377e9d\.system_generated\tasks\task-9334.log');
  if (!file.existsSync()) {
    print('File not found');
    return;
  }
  var lines = file.readAsLinesSync();
  
  int passed = 0;
  int failed = 0;
  int total = 0;
  
  for (var line in lines) {
    if (line.contains('All tests passed!')) {
      print('All tests passed!');
      return;
    }
    if (line.contains('Some tests failed.')) {
      print('Some tests failed.');
    }
    if (line.contains(' +') && line.contains(': ')) {
      // rough heuristic
    }
  }
  
  var lastLines = lines.skip(lines.length > 50 ? lines.length - 50 : 0).toList();
  for (var line in lastLines) {
    print(line);
  }
}
