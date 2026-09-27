import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('List<dynamic> dummyStoreItemComments = [];', 'List<StoreItemComment> dummyStoreItemComments = [];');
  if (!content.contains('store_item_comment.dart')) {
    content = content.replaceFirst("import 'package:commission_apparel_flutter/models/store_item.dart';", "import 'package:commission_apparel_flutter/models/store_item.dart';\nimport 'package:commission_apparel_flutter/models/store_item_comment.dart';");
  }
  file.writeAsStringSync(content);
}
