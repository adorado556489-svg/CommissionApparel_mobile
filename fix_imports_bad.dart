import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      
      content = content.replaceAll("import 'fixtures/\$1'", "import 'fixtures/dummy_users.dart'"); // wait, no! I don't know what it was.
    }
  }
}
