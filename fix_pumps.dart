import 'dart:io';

void main() {
  final files = ['test/public_ui_test.dart', 'test/widget_test.dart', 'test/route_guard_test.dart'];
  
  for (final path in files) {
    if (!File(path).existsSync()) continue;
    var content = File(path).readAsStringSync();
    
    // Pump more times to allow async data to load
    content = content.replaceAll(
      'await tester.pumpAndSettle();',
      'await tester.pumpAndSettle(); await tester.pump(const Duration(seconds: 1)); await tester.pumpAndSettle();'
    );
    
    File(path).writeAsStringSync(content);
  }
  
  print('Done fixing pumps');
}
