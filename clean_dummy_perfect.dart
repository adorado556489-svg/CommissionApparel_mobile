import 'dart:io';

void main() {
  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var lines = file.readAsLinesSync();
      var newLines = <String>[];
      
      for (var line in lines) {
        if (line.contains("import '../data/dummy_")) continue;
        if (line.contains("import 'dummy_")) continue;
        
        // Return fallbacks
        if (line.contains("return dummy")) {
          if (line.contains(".firstWhere(") || line.contains(" ? dummy") || line.contains("return dummyUsers.firstWhere")) {
             newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return null;"));
          } else if (line.contains(".where(") || line.contains(".toList()")) {
             newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return [];"));
          } else if (line.contains("dummyDesignCatalog;") || line.contains("dummyDesignCollections;")) {
             newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return [];"));
          } else if (line.contains("dummyTeamStores[")) {
             newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return false;"));
          } else {
             newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return [];")); // catch all
          }
          continue;
        }
        
        // Variable Assignments from dummy
        if (line.contains(" stores = dummyTeamStores;")) {
           continue;
        }
        if (line.contains("final adminUsers = dummyUsers.where")) {
           newLines.add("    final adminUsers = <String>{};");
           continue;
        }
        if (line.contains("final coachStoreIds = dummyTeamStores.where")) {
           newLines.add("    final coachStoreIds = <String>{};");
           continue;
        }
        
        // Mutations (add, remove, assignments)
        if (line.contains("dummy") && (
            line.contains(".add(") || 
            line.contains(".removeAt(") ||
            line.contains(".removeWhere(") ||
            line.contains(".sort(") ||
            line.contains(" = o.copyWith(") ||
            line.contains("] = dummy") ||
            line.contains("] = updated") ||
            line.contains("] = item") ||
            line.contains("] = store") ||
            line.contains("] = order") ||
            line.contains("] = newOrder") ||
            line.contains("] = collection") ||
            line.contains("] = o.copyWith"))) {
          continue;
        }
        
        // Specific complex blocks
        if (line.contains("for (var i = 0; i < dummyParentOrders.length; i++) {")) {
           continue;
        }
        if (line.contains("final o = dummyParentOrders[i];")) {
           continue;
        }
        if (line.contains("if (dummyParentOrders.length == initialLength) {")) {
           continue;
        }
        if (line.contains("final initialLength = dummyParentOrders.length;")) {
           continue;
        }
        if (line.contains("if (dummyUsers.any((u) => u.email == email && u.id != coach.id)) {")) {
           continue;
        }
        if (line.contains("final existsInDummy = dummyUsers.any")) {
           continue;
        }
        
        // Index lookups
        if (line.contains("final dummyIndex = dummy") || 
            line.contains("final storeIndex = dummy") || 
            line.contains("final userIndex = dummy") ||
            line.contains("final uIndex = dummy") || 
            line.contains("final notifIndex = dummy") || 
            line.contains("final index = dummy") || 
            line.contains("final subIdx = dummy") ||
            line.contains("final pathIdx = dummy") ||
            line.contains("final typeIdx = dummy") ||
            line.contains("final idx1 = dummy") || 
            line.contains("final idx2 = dummy") || 
            line.contains("final idx3 = dummy") ||
            line.contains("final idx = dummy")) {
          continue;
        }
        
        // We do NOT want to skip `if (idx != -1) {` because it leaves empty braces, which is fine, 
        // BUT if it's `if (idx != -1) dummyTeamStores[idx] = store;` it was already caught by the mutation check above!
        
        newLines.add(line);
      }
      file.writeAsStringSync(newLines.join('\n'));
    }
  }
}
