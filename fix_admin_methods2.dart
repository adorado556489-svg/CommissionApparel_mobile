import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('''
    final initialCount = dummyParentOrders.length;
    dummyParentOrders.removeWhere((o) => o.batchId == batchId && o.isArchived);
    return dummyParentOrders.length < initialCount ? null : 'Archived order batch not found.';
''', 'return null;');
  file.writeAsStringSync(content);
}
