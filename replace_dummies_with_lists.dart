import 'dart:io';

void main() {
  var replacements = {
    "dummyUsers": "<User>[]",
    "dummyTeamStores": "<TeamStore>[]",
    "dummyStoreItems": "<StoreItem>[]",
    "dummyParentOrders": "<ParentOrder>[]",
    "dummyDesignCatalog": "<StoreItem>[]",
    "dummyDesignCollections": "<DesignCollection>[]",
    "dummyLandingCollections": "<DesignCollection>[]",
    "dummyTestimonials": "<Testimonial>[]",
    "dummyQuoteRequests": "<QuoteRequest>[]",
    "dummySiteSettings": "<SiteSetting>[]",
    "dummyPasswordResetLogs": "<PasswordResetLog>[]",
    "dummyNotifications": "<NotificationItem>[]",
  };

  var dir = Directory('lib/services');
  for (var file in dir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      // strip imports first so we don't replace in imports
      content = content.replaceAll(RegExp(r"import '../data/dummy_[^']+\.dart';"), "");
      content = content.replaceAll(RegExp(r"import 'dummy_[^']+\.dart';"), "");
      
      for (var entry in replacements.entries) {
        content = content.replaceAll(entry.key, entry.value);
      }
      
      file.writeAsStringSync(content);
    }
  }
}
