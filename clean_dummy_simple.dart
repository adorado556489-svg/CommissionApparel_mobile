import 'dart:io';

void main() {
  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var lines = file.readAsLinesSync();
      var newLines = <String>[];
      bool inDummyBlock = false;
      
      for (var line in lines) {
        if (line.contains("import '../data/dummy_")) continue;
        if (line.contains("import 'dummy_")) continue;
        
        if (line.contains("return dummy")) {
          if (line.contains(".firstWhere(") || line.contains(" ? dummy") || line.contains("return dummyUsers.firstWhere")) {
            newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return null;"));
          } else if (line.contains(".where(") || line.contains(".toList()")) {
            newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return [];"));
          } else if (line.contains("dummyDesignCatalog;") || line.contains("dummyDesignCollections;")) {
            newLines.add(line.replaceAll(RegExp(r"return dummy[^;]+;"), "return [];"));
          } else {
             newLines.add(line);
          }
          continue;
        }
        
        if (line.contains("dummyParentOrders.add") || 
            line.contains("dummyParentOrders.removeAt") ||
            line.contains("dummyParentOrders[dummyIndex]") ||
            line.contains("dummyParentOrders.removeWhere")) {
          continue;
        }
        if (line.contains("dummyTeamStores.add") || 
            line.contains("dummyTeamStores.removeWhere") ||
            line.contains("dummyTeamStores[") ||
            line.contains("stores = dummyTeamStores")) {
          continue;
        }
        if (line.contains("dummyStoreItems.add") || 
            line.contains("dummyStoreItems.removeWhere") ||
            line.contains("dummyStoreItems[")) {
          continue;
        }
        if (line.contains("dummyUsers.add") || 
            line.contains("dummyUsers.removeWhere") ||
            line.contains("dummyUsers[")) {
          continue;
        }
        if (line.contains("dummySiteSettings.add") || 
            line.contains("dummySiteSettings[")) {
          continue;
        }
        if (line.contains("dummyPasswordResetLogs.add") || 
            line.contains("dummyPasswordResetLogs[")) {
          continue;
        }
        if (line.contains("dummyNotifications.add") || 
            line.contains("dummyNotifications[")) {
          continue;
        }
        
        if (line.contains("final dummyIndex = dummy") || 
            line.contains("final storeIndex = dummy") || 
            line.contains("final uIndex = dummy") || 
            line.contains("final notifIndex = dummy") || 
            line.contains("final index = dummy") || 
            line.contains("final idx1 = dummy") || 
            line.contains("final idx2 = dummy") || 
            line.contains("final idx3 = dummy") ||
            line.contains("final idx = dummy")) {
          continue;
        }
        
        if (line.contains("if (dummyIndex != -1)") ||
            line.contains("if (storeIndex != -1)") ||
            line.contains("if (uIndex != -1)") ||
            line.contains("if (notifIndex != -1)") ||
            line.contains("if (idx != -1)") ||
            line.contains("if (idx1 != -1)") ||
            line.contains("if (idx2 != -1)") ||
            line.contains("if (idx3 != -1)")) {
           // We might need to skip block, but since we are just doing one line...
           // wait, if it's `if (idx != -1) {` we have a problem.
        }
        
        newLines.add(line);
      }
      file.writeAsStringSync(newLines.join('\n'));
    }
  }
}
