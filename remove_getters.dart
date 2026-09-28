import 'dart:io';

void main() {
  var contentFile = File('test/fixtures/dummy_content.dart');
  if (contentFile.existsSync()) {
    var content = contentFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'List<LandingCollection> get rawdummyLandingCollections => \[\];\n?'), '');
    content = content.replaceAll(RegExp(r'List<Testimonial> get rawdummyTestimonials => \[\];\n?'), '');
    content = content.replaceAll(RegExp(r'List<SiteSetting> get rawdummySiteSettings => \[\];\n?'), '');
    contentFile.writeAsStringSync(content);
  }
  
  var quoteFile = File('test/fixtures/dummy_quotes.dart');
  if (quoteFile.existsSync()) {
    var content = quoteFile.readAsStringSync();
    content = content.replaceAll(RegExp(r'List<QuoteRequest> get rawdummyQuoteRequests => \[\];\n?'), '');
    quoteFile.writeAsStringSync(content);
  }
}
