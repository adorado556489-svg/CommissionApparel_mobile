import 'dart:io';

void replaceLine(String file, int lineNum, String newContent) {
  var f = File(file);
  var lines = f.readAsLinesSync();
  if (lineNum <= lines.length) {
    lines[lineNum - 1] = newContent;
  }
  f.writeAsStringSync(lines.join('\n'));
}

void deleteLine(String file, int lineNum) {
  var f = File(file);
  var lines = f.readAsLinesSync();
  if (lineNum <= lines.length) {
    lines[lineNum - 1] = "";
  }
  f.writeAsStringSync(lines.join('\n'));
}

void main() {
  deleteLine('lib/services/auth_service.dart', 49);
  deleteLine('lib/services/auth_service.dart', 53);
  deleteLine('lib/services/auth_service.dart', 60);
  deleteLine('lib/services/auth_service.dart', 63);
  deleteLine('lib/services/auth_service.dart', 119);
  deleteLine('lib/services/auth_service.dart', 125);
  deleteLine('lib/services/auth_service.dart', 131);
  deleteLine('lib/services/auth_service.dart', 135);
  deleteLine('lib/services/auth_service.dart', 182);
  deleteLine('lib/services/auth_service.dart', 216);
  deleteLine('lib/services/auth_service.dart', 261);
  deleteLine('lib/services/auth_service.dart', 265);
  deleteLine('lib/services/auth_service.dart', 281);
  deleteLine('lib/services/auth_service.dart', 306);
  deleteLine('lib/services/auth_service.dart', 308);
  deleteLine('lib/services/auth_service.dart', 309);

  // Catalog service
  replaceLine('lib/services/catalog_service.dart', 132, "      return [];");
  replaceLine('lib/services/catalog_service.dart', 141, "      return [];");
  
  // Content service
  replaceLine('lib/services/content_service.dart', 138, "      return [];");
  replaceLine('lib/services/content_service.dart', 156, "      return [];");
  replaceLine('lib/services/content_service.dart', 178, "      return [];");
  replaceLine('lib/services/content_service.dart', 180, "");
  
  // Order service
  replaceLine('lib/services/order_service.dart', 29, "      return [];");
  replaceLine('lib/services/order_service.dart', 122, "      return [];");
  replaceLine('lib/services/order_service.dart', 123, "");
  replaceLine('lib/services/order_service.dart', 125, "      return [];");
  
  replaceLine('lib/services/order_service.dart', 157, "      return [];");
  replaceLine('lib/services/order_service.dart', 158, "");
  replaceLine('lib/services/order_service.dart', 160, "      return [];");
  
  replaceLine('lib/services/order_service.dart', 191, "      return [];");
  replaceLine('lib/services/order_service.dart', 192, "");
  replaceLine('lib/services/order_service.dart', 194, "      return [];");
  
  // Store service
  replaceLine('lib/services/store_service.dart', 34, "      return null;");
  replaceLine('lib/services/store_service.dart', 47, "      return [];");
  replaceLine('lib/services/store_service.dart', 55, "      return null;");
  replaceLine('lib/services/store_service.dart', 68, "      return [];");
  replaceLine('lib/services/store_service.dart', 78, "      return [];");
  replaceLine('lib/services/store_service.dart', 82, "");
  replaceLine('lib/services/store_service.dart', 84, "");
  replaceLine('lib/services/store_service.dart', 92, "");
  replaceLine('lib/services/store_service.dart', 99, "");
  replaceLine('lib/services/store_service.dart', 100, "");
  replaceLine('lib/services/store_service.dart', 110, "");
  
  replaceLine('lib/services/store_service.dart', 125, "      return [];");
  replaceLine('lib/services/store_service.dart', 132, "");
  replaceLine('lib/services/store_service.dart', 139, "");
  replaceLine('lib/services/store_service.dart', 140, "");
  replaceLine('lib/services/store_service.dart', 147, "");
  
  // Admin Service
  replaceLine('lib/services/admin_service.dart', 149, "      return [];");
  replaceLine('lib/services/admin_service.dart', 178, "      return [];");
  replaceLine('lib/services/admin_service.dart', 179, "");
  replaceLine('lib/services/admin_service.dart', 181, "      return [];");
  replaceLine('lib/services/admin_service.dart', 207, "      return [];");
  replaceLine('lib/services/admin_service.dart', 208, "");
  replaceLine('lib/services/admin_service.dart', 210, "      return [];");
  
  replaceLine('lib/services/admin_service.dart', 220, "      return [];");
  replaceLine('lib/services/admin_service.dart', 227, "      return [];");
  replaceLine('lib/services/admin_service.dart', 230, "      return [];");
  replaceLine('lib/services/admin_service.dart', 237, "");
  replaceLine('lib/services/admin_service.dart', 242, "");
  
  replaceLine('lib/services/admin_service.dart', 249, "      return [];");
  replaceLine('lib/services/admin_service.dart', 256, "      return [];");
  replaceLine('lib/services/admin_service.dart', 259, "      return [];");
  replaceLine('lib/services/admin_service.dart', 266, "");
  replaceLine('lib/services/admin_service.dart', 271, "");
  
  replaceLine('lib/services/admin_service.dart', 280, "");
  replaceLine('lib/services/admin_service.dart', 282, "");
  replaceLine('lib/services/admin_service.dart', 283, "");
  replaceLine('lib/services/admin_service.dart', 286, "");
  replaceLine('lib/services/admin_service.dart', 290, "");
  
  replaceLine('lib/services/admin_service.dart', 300, "");
  replaceLine('lib/services/admin_service.dart', 302, "");
  replaceLine('lib/services/admin_service.dart', 303, "");
  replaceLine('lib/services/admin_service.dart', 306, "");
  replaceLine('lib/services/admin_service.dart', 310, "");
  
  replaceLine('lib/services/admin_service.dart', 319, "");
  replaceLine('lib/services/admin_service.dart', 321, "");
  replaceLine('lib/services/admin_service.dart', 322, "");
  replaceLine('lib/services/admin_service.dart', 325, "");
  replaceLine('lib/services/admin_service.dart', 329, "");
  
  replaceLine('lib/services/admin_service.dart', 344, "      return [];");
  replaceLine('lib/services/admin_service.dart', 352, "      return [];");
  replaceLine('lib/services/admin_service.dart', 355, "      return [];");

  // team_store_service.dart is there too! I need to fix it.
  replaceLine('lib/services/team_store_service.dart', 24, "      return [];");
  replaceLine('lib/services/team_store_service.dart', 42, "      return [];");
  replaceLine('lib/services/team_store_service.dart', 53, "      return [];");
  replaceLine('lib/services/team_store_service.dart', 69, "      return [];");
  replaceLine('lib/services/team_store_service.dart', 81, "");
  replaceLine('lib/services/team_store_service.dart', 84, "");
  replaceLine('lib/services/team_store_service.dart', 90, "");
  replaceLine('lib/services/team_store_service.dart', 95, "");
  replaceLine('lib/services/team_store_service.dart', 96, "");
}
