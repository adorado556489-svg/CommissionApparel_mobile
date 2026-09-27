import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("isApproved: status == 'active',", "status: status,");
  file.writeAsStringSync(content);
}
