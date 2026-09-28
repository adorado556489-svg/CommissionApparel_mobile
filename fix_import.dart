import 'dart:io';

void main() {
  var path = 'test/public_ui_test.dart';
  if (File(path).existsSync()) {
    var content = File(path).readAsStringSync();
    
    // Remove the bad import
    content = content.replaceFirst("import 'helpers/auto_seeding_mock_auth.dart';", "");
    
    // Add to top
    content = "import 'helpers/auto_seeding_mock_auth.dart';\n" + content;
    
    File(path).writeAsStringSync(content);
  }

  print('Done fixing import');
}
