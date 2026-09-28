import 'dart:io';

void main() {
  var file = File('lib/services/content_service.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    if (!content.contains('createQuoteRequest')) {
      content = content.replaceFirst('class ContentService {', "class ContentService {\n  static Future<void> createQuoteRequest(dynamic firestore, dynamic quote) async { await firestore.collection('quote_requests').doc(quote.id).set(quote.toFirestore()); }\n  static Future<void> updateQuoteRequestStatus(dynamic firestore, String id, String status) async { await firestore.collection('quote_requests').doc(id).update({'status': status}); }\n");
      file.writeAsStringSync(content);
    }
  }
}
