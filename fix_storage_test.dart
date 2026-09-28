import 'dart:io';

void main() {
  var file = File('test/storage_service_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('mockStorage = dynamic();', 'mockStorage = null;');
    file.writeAsStringSync(content);
  }
}
