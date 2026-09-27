import 'dart:io';

void main() {
  var file = File('test/helpers/test_seeder.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll('addAll(dummyUsers)', 'addAll(rawdummyUsers)');
  content = content.replaceAll('addAll(dummyTeamStores)', 'addAll(rawdummyTeamStores)');
  content = content.replaceAll('addAll(dummyParentOrders)', 'addAll(rawdummyParentOrders)');
  content = content.replaceAll('addAll(dummyDesignCatalog)', 'addAll(rawdummyDesignCatalog)');
  content = content.replaceAll('addAll(dummyStoreItems)', 'addAll(rawdummyStoreItems)');
  content = content.replaceAll('addAll(dummyLandingCollections)', 'addAll(rawdummyLandingCollections)');
  content = content.replaceAll('addAll(dummyTestimonials)', 'addAll(rawdummyTestimonials)');
  content = content.replaceAll('addAll(dummySiteSettings)', 'addAll(rawdummySiteSettings)');
  content = content.replaceAll('addAll(dummyQuoteRequests)', 'addAll(rawdummyQuoteRequests)');
  content = content.replaceAll('addAll(dummyNotifications)', 'addAll(rawdummyNotifications)');
  content = content.replaceAll('dummyUsers.firstWhere', 'rawdummyUsers.firstWhere');
  content = content.replaceAll('dummyUsers.where', 'rawdummyUsers.where');
  
  file.writeAsStringSync(content);
}
