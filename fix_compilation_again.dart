import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      var changed = false;
      
      // Fix all 'await TestSeeder.seedAll(firestore);' inside non-async setups
      if (content.contains('setUp(() {') && content.contains('await TestSeeder')) {
        content = content.replaceAll('setUp(() {', 'setUp(() async {');
        changed = true;
      }
      
      // Fix order service signature in phase4 and firestore_rules
      if (content.contains('submitDirectOrder(')) {
        // Need to add firestore argument if missing
        content = content.replaceAll('OrderService.submitDirectOrder(\n        order,', 'OrderService.submitDirectOrder(\n        firestore,\n        order,');
        content = content.replaceAll('OrderService.submitDirectOrder(order,', 'OrderService.submitDirectOrder(firestore, order,');
        changed = true;
      }
      
      var newContent = content.replaceAll(RegExp(r'List<[a-zA-Z0-9_]+>\s+get\s+rawdummy[a-zA-Z0-9_]+\s*=>\s*\[\];'), '');
      if (newContent != content) {
        content = newContent;
        changed = true;
      }
      
      if (changed) {
        file.writeAsStringSync(content);
        print("Fixed ${file.path}");
      }
    }
  }
}
