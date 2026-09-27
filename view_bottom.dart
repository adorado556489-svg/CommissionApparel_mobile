import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  var idx = content.indexOf('// --- LANDING COLLECTIONS ---');
  if (idx != -1) {
    print(content.substring(idx));
  }
}
