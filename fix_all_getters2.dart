import 'dart:io';

void main() {
  var gettersToRemove = [
    'List<User> get rawdummyUsers => [];',
    'List<User> get rawdummyCoaches => [];',
    'List<User> get rawdummyParents => [];',
    'List<LandingCollection> get rawdummyLandingCollections => [];',
    'List<Testimonial> get rawdummyTestimonials => [];',
    'List<SiteSetting> get rawdummySiteSettings => [];',
    'List<QuoteRequest> get rawdummyQuoteRequests => [];',
    'List<TeamStore> get rawdummyTeamStores => [];',
    'List<StoreItem> get rawdummyStoreItems => [];',
    'List<DesignCollection> get rawdummyDesignCollections => [];',
    'List<DesignCatalog> get rawdummyDesignCatalog => [];',
    'List<ParentOrder> get rawdummyParentOrders => [];',
  ];

  var dir = Directory('test/fixtures');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var changed = false;
      for (var getter in gettersToRemove) {
        if (content.contains(getter)) {
          content = content.replaceAll(getter, '');
          changed = true;
        }
      }
      if (changed) {
        file.writeAsStringSync(content);
        print("Fixed ${file.path}");
      }
    }
  }
}
