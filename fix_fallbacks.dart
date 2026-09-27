import 'dart:io';

void main() {
  final servicesDir = Directory('lib/services');
  
  for (var file in servicesDir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      // Remove imports
      content = content.replaceAll(RegExp(r"import '\.\./data/dummy_[^']+';\n"), '');
      
      // We will remove all code starting from `// Dummy` or `// Fallback` until the end of the method body.
      // But wait! `catch (_) { return null; }` handles the fallback in store_service!
      
      content = content.replaceAll(RegExp(r'\s*// Dummy fallback logic[\s\S]*?(?=\n  \})'), '');
      content = content.replaceAll(RegExp(r'\s*// Fallback to dummy users[\s\S]*?(?=\n      \})'), '');
      content = content.replaceAll(RegExp(r'\s*// Fallback[\s\S]*?(?=\n    \})'), '');
      
      // store_service inline dummy usage
      content = content.replaceAll(r"try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }", "return null;");
      content = content.replaceAll(r"return dummyTeamStores.where((s) => s.isLive).toList();", "return [];");
      content = content.replaceAll(r"try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }", "return null;");
      content = content.replaceAll(r"return dummyTeamStores.where((s) => s.status == 'pending').toList();", "return [];");
      
      file.writeAsStringSync(content);
    }
  }
}
