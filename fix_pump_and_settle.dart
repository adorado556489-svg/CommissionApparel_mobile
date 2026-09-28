import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      bool changed = false;
      
      // Some tests might use `await tester.pumpWidget(...);` across multiple lines.
      // But typically it ends with `);`
      var lines = content.split('\n');
      for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.contains('await tester.pumpWidget(')) {
          // Check if pumpAndSettle is already there in the next few lines
          bool hasPumpAndSettle = false;
          for (var j = i + 1; j < i + 5 && j < lines.length; j++) {
            if (lines[j].contains('tester.pumpAndSettle')) {
              hasPumpAndSettle = true;
              break;
            }
          }
          if (!hasPumpAndSettle) {
            // we need to find where the pumpWidget call ends.
            // If it's a single line:
            if (line.contains(');')) {
              lines.insert(i + 1, '      await tester.pumpAndSettle();');
              changed = true;
              i++;
            } else {
              // multiline pumpWidget. Let's find the closing ');'
              for (var j = i + 1; j < lines.length; j++) {
                if (lines[j].contains(');')) {
                  lines.insert(j + 1, '      await tester.pumpAndSettle();');
                  changed = true;
                  i = j + 1;
                  break;
                }
              }
            }
          }
        }
      }
      
      if (changed) {
        file.writeAsStringSync(lines.join('\n'));
        print("Injected pumpAndSettle in ${file.path}");
      }
    }
  }
}
