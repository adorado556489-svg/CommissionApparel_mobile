import 'dart:io';

void replaceLine(String file, int line, String text) {
  var lines = File(file).readAsLinesSync();
  lines[line - 1] = text;
  File(file).writeAsStringSync(lines.join('\n'));
}

void clearLines(String file, int start, int end) {
  var lines = File(file).readAsLinesSync();
  for (var i = start - 1; i < end; i++) {
    lines[i] = "";
  }
  File(file).writeAsStringSync(lines.join('\n'));
}

void main() {
  // auth_service.dart
  clearLines('lib/services/auth_service.dart', 4, 5); // imports
  clearLines('lib/services/auth_service.dart', 137, 139);
  clearLines('lib/services/auth_service.dart', 184, 187);
  clearLines('lib/services/auth_service.dart', 218, 218);
  clearLines('lib/services/auth_service.dart', 263, 268);
  clearLines('lib/services/auth_service.dart', 283, 289);
  clearLines('lib/services/auth_service.dart', 308, 312);

  // catalog_service.dart
  clearLines('lib/services/catalog_service.dart', 3, 3); // import
  replaceLine('lib/services/catalog_service.dart', 31, "    return [];");
  clearLines('lib/services/catalog_service.dart', 40, 40);
  clearLines('lib/services/catalog_service.dart', 49, 50);
  clearLines('lib/services/catalog_service.dart', 59, 59);
  replaceLine('lib/services/catalog_service.dart', 73, "    return [];");
  clearLines('lib/services/catalog_service.dart', 82, 82);
  clearLines('lib/services/catalog_service.dart', 91, 92);
  clearLines('lib/services/catalog_service.dart', 101, 101);
  replaceLine('lib/services/catalog_service.dart', 115, "    return [];");
  clearLines('lib/services/catalog_service.dart', 124, 124);
  clearLines('lib/services/catalog_service.dart', 133, 134);
  clearLines('lib/services/catalog_service.dart', 143, 143);
  
  // order_service.dart
  clearLines('lib/services/order_service.dart', 4, 5); // imports
  replaceLine('lib/services/order_service.dart', 31, "    return [];");
  clearLines('lib/services/order_service.dart', 44, 47);
  clearLines('lib/services/order_service.dart', 57, 57);
  clearLines('lib/services/order_service.dart', 104, 104);
  clearLines('lib/services/order_service.dart', 127, 132);
  clearLines('lib/services/order_service.dart', 162, 169); 
  clearLines('lib/services/order_service.dart', 196, 202); 
  clearLines('lib/services/order_service.dart', 229, 230); 
  clearLines('lib/services/order_service.dart', 258, 261); 
  
  // store_service.dart
  clearLines('lib/services/store_service.dart', 6, 7); // imports
  replaceLine('lib/services/store_service.dart', 36, "    return null;");
  replaceLine('lib/services/store_service.dart', 49, "    return [];");
  replaceLine('lib/services/store_service.dart', 57, "    return null;");
  replaceLine('lib/services/store_service.dart', 70, "    return [];");
  clearLines('lib/services/store_service.dart', 80, 80);
  clearLines('lib/services/store_service.dart', 84, 84);
  replaceLine('lib/services/store_service.dart', 86, "    final adminUsers = <String>{};");
  clearLines('lib/services/store_service.dart', 94, 94);
  clearLines('lib/services/store_service.dart', 101, 102);
  clearLines('lib/services/store_service.dart', 112, 112);
  replaceLine('lib/services/store_service.dart', 127, "    return [];");
  clearLines('lib/services/store_service.dart', 134, 134);
  clearLines('lib/services/store_service.dart', 141, 142);
  clearLines('lib/services/store_service.dart', 149, 149);
  
  // team_store_service.dart
  clearLines('lib/services/team_store_service.dart', 6, 7); // imports
  replaceLine('lib/services/team_store_service.dart', 26, "      return null;");
  clearLines('lib/services/team_store_service.dart', 27, 29); // rest of firstWhere block
  replaceLine('lib/services/team_store_service.dart', 44, "    return [];");
  replaceLine('lib/services/team_store_service.dart', 55, "    return null;");
  replaceLine('lib/services/team_store_service.dart', 71, "    return [];");
  clearLines('lib/services/team_store_service.dart', 83, 83);
  replaceLine('lib/services/team_store_service.dart', 86, "    final adminUsers = <String>{};");
  clearLines('lib/services/team_store_service.dart', 92, 92);
  clearLines('lib/services/team_store_service.dart', 97, 98);
}
