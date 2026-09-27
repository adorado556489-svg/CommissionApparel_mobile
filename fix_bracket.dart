import 'dart:io';

void main() {
  var code = File('lib/screens/coach/coach_dashboard_screen.dart').readAsStringSync();
  
  code = code.replaceAll("""      );
    }
        }
      );
    }
  
  Widget _buildOrderRow""", """      );
    }
  
  Widget _buildOrderRow""");

  File('lib/screens/coach/coach_dashboard_screen.dart').writeAsStringSync(code);
}
