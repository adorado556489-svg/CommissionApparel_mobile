import 'dart:io';

void main() {
  final servicesDir = Directory('lib/services');
  
  for (var file in servicesDir.listSync()) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      
      // We will just replace ALL dummy variables with empty lists/maps!
      content = content.replaceAll('dummyUsers', '<User>[]');
      content = content.replaceAll('dummyParentOrders', '<ParentOrder>[]');
      content = content.replaceAll('dummyTeamStores', '<TeamStore>[]');
      content = content.replaceAll('dummyStoreItems', '<StoreItem>[]');
      content = content.replaceAll('dummyDesignCatalog', '<DesignCatalog>[]');
      content = content.replaceAll('dummyDesignCollections', '<DesignCollection>[]');
      content = content.replaceAll('dummyLandingCollections', '<LandingCollection>[]');
      content = content.replaceAll('dummyTestimonials', '<Testimonial>[]');
      content = content.replaceAll('dummyQuoteRequests', '<QuoteRequest>[]');
      content = content.replaceAll('dummySiteSettings', '<SiteSetting>[]');
      
      content = content.replaceAll(RegExp(r"import '\.\./data/dummy_[^']+';\n"), '');
      
      file.writeAsStringSync(content);
    }
  }
}
