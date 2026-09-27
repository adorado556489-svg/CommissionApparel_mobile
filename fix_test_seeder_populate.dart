import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("class TestSeeder {", "import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart' as f;\nclass TestSeeder {\n  static void populateDummyFallbacks() {\n    f.dummyUsers.clear(); f.dummyUsers.addAll(dummyUsers);\n    f.dummyTeamStores.clear(); f.dummyTeamStores.addAll(dummyTeamStores);\n    f.dummyParentOrders.clear(); f.dummyParentOrders.addAll(dummyParentOrders);\n    f.dummyDesignCatalog.clear(); f.dummyDesignCatalog.addAll(dummyDesignCatalog);\n    f.dummyStoreItems.clear(); f.dummyStoreItems.addAll(dummyStoreItems);\n    f.dummyLandingCollections.clear(); f.dummyLandingCollections.addAll(dummyLandingCollections);\n    f.dummyTestimonials.clear(); f.dummyTestimonials.addAll(dummyTestimonials);\n    f.dummySiteSettings.clear(); f.dummySiteSettings.addAll(dummySiteSettings);\n    f.dummyQuoteRequests.clear(); f.dummyQuoteRequests.addAll(dummyQuoteRequests);\n    f.dummyNotifications.clear(); f.dummyNotifications.addAll(dummyNotifications);\n    f.dummyAdmin = dummyUsers.firstWhere((u) => u.role == UserRole.admin);\n  }\n");
  file.writeAsStringSync(content);
}
