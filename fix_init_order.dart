import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      if (content.contains('await TestSeeder.seedAll(firestore);') && content.contains('firestore = FakeFirebaseFirestore();')) {
        // We want to ensure firestore = FakeFirebaseFirestore() comes FIRST.
        // We will match the setup block.
        var pattern = RegExp(r'(await TestSeeder\.seedAll\(firestore\);[\s\S]*?firestore\s*=\s*FakeFirebaseFirestore\(\);)');
        if (pattern.hasMatch(content)) {
          content = content.replaceAllMapped(pattern, (match) {
            return 'firestore = FakeFirebaseFirestore();\n    await TestSeeder.seedAll(firestore);';
          });
          file.writeAsStringSync(content);
          print("Fixed init order in ${file.path}");
        }
      }
    }
  }
}
