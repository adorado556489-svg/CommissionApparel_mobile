import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('''
      if (dummyParentOrders.length == initialLength) {
        return 'Archived order batch not found.';
      }''', '');
  file.writeAsStringSync(content);
}
