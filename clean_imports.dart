import 'dart:io';

void cleanFile(String filePath) {
  var file = File(filePath);
  if (!file.existsSync()) return;
  var lines = file.readAsLinesSync();
  
  var newLines = <String>[];
  bool skipMode = false;
  
  for (int i = 0; i < lines.length; i++) {
    var line = lines[i];
    
    // Remove dummy imports
    if (line.contains("import '../data/dummy_") || line.contains("import 'dummy_")) continue;
    
    // Remove inline dummy mutations (e.g. try { dummyUsers.add... } catch (_) {})
    if (line.trim().startsWith("try { dummy") || line.trim().startsWith("try { final dummyIndex")) {
      // Find the closing brace of catch (_) {}
      while (i < lines.length && !lines[i].contains("catch (_) {}")) {
        i++;
      }
      continue;
    }
    
    // Replace if (snapshot.docs.isEmpty) return dummy... with nothing if it's in a map()
    // Or replace with return [] if it's a Future.
    
    newLines.add(line);
  }
  
  file.writeAsStringSync(newLines.join('\n'));
}

void main() {
  var dir = Directory('lib/services');
  for (var entity in dir.listSync()) {
    if (entity is File && entity.path.endsWith('.dart')) {
      cleanFile(entity.path);
    }
  }
}
