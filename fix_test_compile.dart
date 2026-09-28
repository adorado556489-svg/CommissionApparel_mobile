import 'dart:io';
void main() {
  var file = File('test/coach_direct_order_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('currentUser: ', '');
    file.writeAsStringSync(content);
  }
}
