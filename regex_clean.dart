import 'dart:io';

void replaceAllMatching(String path, RegExp regex, String replacement) {
  var file = File(path);
  var content = file.readAsStringSync();
  content = content.replaceAll(regex, replacement);
  file.writeAsStringSync(content);
}

void main() {
  // OrderService
  replaceAllMatching('lib/services/order_service.dart', RegExp(r"import '\.\./data/dummy_orders\.dart';\s*"), "");
  replaceAllMatching('lib/services/order_service.dart', RegExp(r"import '\.\./data/dummy_stores\.dart';\s*"), "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"\} catch \(_\) \{\s*return dummyParentOrders\.toList\(\);\s*\}"), 
    "} catch (e) {\n      _handleError(e, 'OrderService.getAllOrders');\n      return [];\n    }");
  
  replaceAllMatching('lib/services/order_service.dart', RegExp(r"final storeIndex = dummyTeamStores\.indexWhere\(\(s\) => s\.id == storeId\);\s*if \(storeIndex != -1\) \{\s*return dummyTeamStores\[storeIndex\]\.userId == currentUser\.id;\s*\}"), 
    "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"dummyParentOrders\.add\(order\); // fallback\s*"), "");
  replaceAllMatching('lib/services/order_service.dart', RegExp(r"dummyParentOrders\.add\(newOrder\);\s*"), "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"\} catch \(_\) \{\s*unbatched = dummyParentOrders[^}]+\}\s*"), 
    "} catch (e) {\n      _handleError(e, 'OrderService.submitStoreOrdersToAdmin');\n    }\n");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"for \(var i = 0; i < dummyParentOrders\.length; i\+\+\) \{[^}]+if \([^}]+o\.teamStoreId == storeId && o\.batchId == null\)[^}]+\}\s*\}\s*"), "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"\} catch \(_\) \{\s*draftOrders = dummyParentOrders[^}]+\}\s*"), 
    "} catch (e) {\n      _handleError(e, 'OrderService.finalizeDirectOrders');\n    }\n");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"for \(var i = 0; i < dummyParentOrders\.length; i\+\+\) \{[^}]+if \([^}]+o\.teamStoreId == null && o\.userId == currentUser\.id && o\.status == 'Draft'\)[^}]+\}\s*\}\s*"), "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"\} catch \(_\) \{\s*batchOrders = dummyParentOrders[^}]+\}\s*"), 
    "} catch (e) {\n      _handleError(e, 'OrderService.archiveDirectOrderBatch');\n    }\n");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"for \(var i = 0; i < dummyParentOrders\.length; i\+\+\) \{[^}]+if \([^}]+o\.userId == currentUser\.id && o\.batchId == batchId\)[^}]+\}\s*\}\s*"), "");

  replaceAllMatching('lib/services/order_service.dart', RegExp(r"final dummyIndex = dummyParentOrders\.indexWhere[^\n]+\n\s*if \(dummyIndex != -1\) dummyParentOrders\.removeAt\(dummyIndex\);\s*"), "");
  
  replaceAllMatching('lib/services/order_service.dart', RegExp(r"final dummyIndex = dummyParentOrders\.indexWhere[^}]+\}\s*"), "");
  
  // StoreService
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"import '\.\./data/dummy_stores\.dart';\s*"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"import '\.\./data/dummy_users\.dart';\s*"), "");
  
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"\} catch \(_\) \{ return null; \}"), "} catch (e) { return null; }");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"try \{ return dummyTeamStores\.firstWhere[^}]+ \}"), "");
  
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"return dummyTeamStores\.where[^;]+;\s*"), "return [];\n");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"return dummyStoreItems\.where[^;]+;\s*"), "return [];\n");
  
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"stores = dummyTeamStores;"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"final adminUsers = dummyUsers\.where[^;]+;"), "final adminUsers = <String>{};");
  
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"dummyTeamStores\.add[^;]+;"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"final idx = dummyTeamStores\.indexWhere[^;]+;\s*if \(idx != -1\) dummyTeamStores\[idx\] = store;"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"dummyTeamStores\.removeWhere[^;]+;"), "");
  
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"dummyStoreItems\.add[^;]+;"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"final idx = dummyStoreItems\.indexWhere[^;]+;\s*if \(idx != -1\) dummyStoreItems\[idx\] = item;"), "");
  replaceAllMatching('lib/services/store_service.dart', RegExp(r"dummyStoreItems\.removeWhere[^;]+;"), "");

  // TeamStoreService
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"import '\.\./data/dummy_stores\.dart';\s*"), "");
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"import '\.\./data/dummy_users\.dart';\s*"), "");
  
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"try \{\s*return dummyTeamStores\.firstWhere[^}]+\}\s*catch \(_\) \{\s*return null;\s*\}\s*"), "");
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"return dummyTeamStores\.where[^;]+;"), "return [];");
  
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"stores = dummyTeamStores;"), "");
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"final adminUsers = dummyUsers\.where[^;]+;"), "final adminUsers = <String>{};");
  
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"dummyTeamStores\.add[^;]+;"), "");
  replaceAllMatching('lib/services/team_store_service.dart', RegExp(r"final idx = dummyTeamStores\.indexWhere[^;]+;\s*if \(idx != -1\) dummyTeamStores\[idx\] = store;"), "");
  
  // CatalogService
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"import '\.\./data/dummy_catalog\.dart';\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{ return dummyDesignCatalog; \} catch \(_\) \{ return \[\]; \}\s*"), "return [];\n");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{ return dummyDesignCollections; \} catch \(_\) \{ return \[\]; \}\s*"), "return [];\n");
  
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"\} catch \(_\) \{\s*return dummyLandingCollections;\s*\}\s*"), "} catch (e) { _handleError(e, 'CatalogService'); return []; }\n");
  
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyDesignCatalog\.add[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*final idx = dummyDesignCatalog\.indexWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyDesignCatalog\.removeWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyDesignCollections\.add[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*final idx = dummyDesignCollections\.indexWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyDesignCollections\.removeWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyLandingCollections\.add[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*final idx = dummyLandingCollections\.indexWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");
  replaceAllMatching('lib/services/catalog_service.dart', RegExp(r"try \{\s*dummyLandingCollections\.removeWhere[^}]+\}\s*catch \(_\) \{\}\s*"), "");

}
