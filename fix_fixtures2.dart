import 'dart:io';

void main() {
  final Map<String, String> fixtureModels = {
    'dummy_users.dart': "export 'package:commission_apparel_flutter/models/user.dart';",
    'dummy_stores.dart': "export 'package:commission_apparel_flutter/models/team_store.dart';",
    'dummy_orders.dart': "export 'package:commission_apparel_flutter/models/parent_order.dart';",
    'dummy_content.dart': "export 'package:commission_apparel_flutter/models/landing_collection.dart';\nexport 'package:commission_apparel_flutter/models/testimonial.dart';\nexport 'package:commission_apparel_flutter/models/site_setting.dart';",
    'dummy_quotes.dart': "export 'package:commission_apparel_flutter/models/quote_request.dart';",
    'dummy_catalog.dart': "export 'package:commission_apparel_flutter/models/design_catalog.dart';\nexport 'package:commission_apparel_flutter/models/design_collection.dart';\nexport 'package:commission_apparel_flutter/models/store_item.dart';",
  };

  for (var file in fixtureModels.keys) {
    final f = File('test/fixtures/$file');
    if (f.existsSync()) {
      var content = f.readAsStringSync();
      // append the export if it doesn't already have it
      if (!content.contains(fixtureModels[file]!)) {
        f.writeAsStringSync("${fixtureModels[file]}\n$content");
      }
    }
  }
}
