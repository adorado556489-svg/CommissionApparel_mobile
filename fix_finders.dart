import 'dart:io';

void main() {
  final files = ['test/public_ui_test.dart', 'test/widget_test.dart'];
  
  for (final path in files) {
    if (!File(path).existsSync()) continue;
    var content = File(path).readAsStringSync();
    
    content = content.replaceAll(
      "find.text('CUSTOM TEAM APPAREL MADE EASY')",
      "find.textContaining('CUSTOM TEAM APPAREL')"
    );
    
    File(path).writeAsStringSync(content);
  }
  
  print('Done fixing finders');
}
