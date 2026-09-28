import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var changed = false;
      var newContent = content.replaceAll(RegExp(r'\bdummyUsers\b'), 'rawdummyUsers')
                              .replaceAll(RegExp(r'\bdummyCoaches\b'), 'rawdummyCoaches')
                              .replaceAll(RegExp(r'\bdummyParents\b'), 'rawdummyParents')
                              .replaceAll(RegExp(r'\bdummyTeamStores\b'), 'rawdummyTeamStores')
                              .replaceAll(RegExp(r'\bdummyStoreItems\b'), 'rawdummyStoreItems')
                              .replaceAll(RegExp(r'\bdummyParentOrders\b'), 'rawdummyParentOrders')
                              .replaceAll(RegExp(r'\bdummyDesignCatalog\b'), 'rawdummyDesignCatalog')
                              .replaceAll(RegExp(r'\bdummyDesignCollections\b'), 'rawdummyDesignCollections')
                              .replaceAll(RegExp(r'\bdummyLandingCollections\b'), 'rawdummyLandingCollections')
                              .replaceAll(RegExp(r'\bdummyTestimonials\b'), 'rawdummyTestimonials')
                              .replaceAll(RegExp(r'\bdummySiteSettings\b'), 'rawdummySiteSettings')
                              .replaceAll(RegExp(r'\bdummyQuoteRequests\b'), 'rawdummyQuoteRequests')
                              .replaceAll(RegExp(r'\bdummyNotifications\b'), 'rawdummyNotifications');
                              
      // But wait! There are variables in dummy_users.dart that are NAMED rawdummyUsers. We don't want to turn `rawdummyUsers` into `rawrawdummyUsers`!
      // So we will do it smartly:
      if (content != newContent) {
        // Just manually doing it and reverting rawraw to raw
        newContent = newContent.replaceAll('rawraw', 'raw');
        file.writeAsStringSync(newContent);
      }
    }
  }
}
