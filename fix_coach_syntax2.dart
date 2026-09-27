import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"      \],\n    \);\n  \}\n      \}\n    \);\n  \}"),
"""      ],
    );
      }
    );
  }""");

  file.writeAsStringSync(content);
  print('Done fixing braces');
}
