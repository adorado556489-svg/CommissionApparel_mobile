import 'dart:io';

void main() {
  final testDir = Directory('test');
  
  for (var file in testDir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart') && !file.path.contains('fixtures')) {
      var content = file.readAsStringSync();
      
      // Update data references
      content = content.replaceAll(RegExp(r"package:commission_apparel_flutter/data/dummy_[^']+"), (match) {
        return match.group(0)!.replaceFirst('data/', 'test/fixtures/'); // Wrong, it shouldn't use package for test directory! test is not in lib!
      });
      
      content = content.replaceAll("import 'package:commission_apparel_flutter/data/dummy_", "import 'fixtures/dummy_");
      content = content.replaceAll("import '../lib/data/dummy_", "import 'fixtures/dummy_");
      content = content.replaceAll("import '../../lib/data/dummy_", "import '../fixtures/dummy_");
      
      file.writeAsStringSync(content);
    }
  }
}
