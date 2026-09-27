import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceFirst(
'''          }),
      ],
    );
  }
      }
    );
  }''',
'''          }),
      ],
    );
      }
    );
  }'''
  );

  file.writeAsStringSync(content);
}
