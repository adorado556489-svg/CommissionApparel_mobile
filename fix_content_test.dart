import 'dart:io';

void main() {
  var file = File('test/content_service_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('getSiteSettings(', 'getAllSiteSettings(');
    content = content.replaceAll('createQuoteRequest(', 'addQuoteRequest('); 
    content = content.replaceAll('updateQuoteRequestStatus(', 'updateQuoteRequest('); 
    file.writeAsStringSync(content);
  }
}
