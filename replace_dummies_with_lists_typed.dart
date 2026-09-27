import 'dart:io';

void addImports(String path, List<String> imports) {
  var file = File(path);
  var lines = file.readAsLinesSync();
  int lastImportIdx = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].startsWith('import ')) {
      lastImportIdx = i;
    }
  }
  if (lastImportIdx != -1) {
    for (var imp in imports.reversed) {
      if (!lines.any((l) => l.contains(imp))) {
        lines.insert(lastImportIdx + 1, imp);
      }
    }
  }
  file.writeAsStringSync(lines.join('\n'));
}

void main() {
  var replacements = {
    "dummyUsers": "<User>[]",
    "dummyTeamStores": "<TeamStore>[]",
    "dummyStoreItems": "<StoreItem>[]",
    "dummyParentOrders": "<ParentOrder>[]",
    "dummyDesignCatalog": "<DesignCatalog>[]",
    "dummyDesignCollections": "<DesignCollection>[]",
    "dummyLandingCollections": "<LandingCollection>[]",
    "dummyTestimonials": "<Testimonial>[]",
    "dummyQuoteRequests": "<QuoteRequest>[]",
    "dummySiteSettings": "<SiteSetting>[]",
    "dummyPasswordResetLogs": "<PasswordResetLog>[]",
    "dummyNotifications": "<NotificationItem>[]",
  };

  // Ensure necessary imports in files before we replace them
  addImports('lib/services/admin_service.dart', [
    "import '../models/user.dart';",
    "import '../models/team_store.dart';",
    "import '../models/parent_order.dart';",
    "import '../models/design_collection.dart';",
    "import '../models/landing_collection.dart';",
    "import '../models/testimonial.dart';",
    "import '../models/quote_request.dart';",
    "import '../models/site_setting.dart';",
  ]);
  
  addImports('lib/services/content_service.dart', [
    "import '../models/notification_item.dart';",
    "import '../models/landing_collection.dart';",
    "import '../models/quote_request.dart';",
  ]);
  
  addImports('lib/services/order_service.dart', [
    "import '../models/team_store.dart';",
  ]);

  addImports('lib/services/auth_service.dart', [
    "import '../models/user.dart';",
    "import '../models/password_reset_log.dart';",
  ]);

  addImports('lib/services/catalog_service.dart', [
    "import '../models/store_item.dart';",
  ]);
  
  addImports('lib/services/store_service.dart', [
    "import '../models/user.dart';",
  ]);
  
  addImports('lib/services/team_store_service.dart', [
    "import '../models/user.dart';",
  ]);

  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      // strip imports first so we don't replace in imports
      content = content.replaceAll(RegExp(r"import '\.\./data/dummy_[^']+\.dart';\s*"), "");
      content = content.replaceAll(RegExp(r"import 'dummy_[^']+\.dart';\s*"), "");
      
      for (var entry in replacements.entries) {
        content = content.replaceAll(entry.key, entry.value);
      }
      
      file.writeAsStringSync(content);
    }
  }
}
