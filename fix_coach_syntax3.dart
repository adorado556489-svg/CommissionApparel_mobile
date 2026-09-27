import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"      \],\s*\);\s*\}\s*\}\s*\);\s*\}"),
"""      ],
    );
      }
    );
  }""");

  file.writeAsStringSync(content);
  print('Done fixing braces 3');
}
