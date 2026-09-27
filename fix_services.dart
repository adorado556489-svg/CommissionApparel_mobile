import 'dart:io';

void main() {
  final servicesDir = Directory('lib/services');
  
  for (var file in servicesDir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      content = content.replaceAll(RegExp(r"import '\.\./data/dummy_[^']+';\n"), '');
      
      // Simple fix: if it has fallback logic, we can't easily regex it.
      // But wait! AdminService just had the dummy logic at the END of each method!
      // If the firestore try/catch succeeds, it returns early!
      // So all the dummy logic is dead code if firestore is populated.
      // But we MUST remove it because the variables don't exist.
    }
  }
}
