import 'dart:io';

void main() {
  var linesToRemove = [
    "return dummyTeamStores.where((s) => s.status == 'pending').toList();",
    "stores = dummyTeamStores;",
    "stores = dummyTeamStores; ",
    "dummyTeamStores.add(store);",
    "final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);",
    "if (idx != -1) dummyTeamStores[idx] = store;",
    "dummyTeamStores.removeWhere((s) => s.userId == coachId);",
    "dummyStoreItems.add(item);",
    "final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);",
    "if (idx != -1) dummyStoreItems[idx] = item;",
    "dummyStoreItems.removeWhere((i) => i.id == itemId);",
    
    // team_store_service
    "return dummyTeamStores.firstWhere(",
    "      stores = dummyTeamStores;",
    "return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();",
    "return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();",
    "final idx = dummyTeamStores.indexWhere((s) => s.id == storeId);",
  ];

  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var lines = file.readAsLinesSync();
      var newLines = <String>[];
      for (var line in lines) {
         bool shouldRemove = false;
         for (var rm in linesToRemove) {
           if (line.contains(rm)) {
             shouldRemove = true;
             break;
           }
         }
         if (shouldRemove) {
            if (line.contains("return dummyTeamStores.where") || line.contains("return dummyTeamStores.firstWhere")) {
               newLines.add("return [];"); // wait, firstWhere might be null, let's just make it null
            }
         }
         if (!shouldRemove) {
           newLines.add(line);
         }
      }
      file.writeAsStringSync(newLines.join('\n'));
    }
  }
}
