import 'dart:io';

void main() {
  var file1 = File('test/content_service_test.dart');
  if (file1.existsSync()) {
    var content = file1.readAsStringSync();
    content = content.replaceAll('addQuoteRequest(', 'createQuoteRequest(');
    content = content.replaceAll('updateQuoteRequest(', 'updateQuoteRequestStatus(');
    file1.writeAsStringSync(content);
  }

  var file2 = File('test/coach_order_edit_test.dart');
  if (file2.existsSync()) {
    var content = file2.readAsStringSync();
    content = content.replaceAll('currentUser: ', '');
    file2.writeAsStringSync(content);
  }
}
