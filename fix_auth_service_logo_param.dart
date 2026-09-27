import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("logoUrl: imagePath", "logo: imagePath");
  file.writeAsStringSync(content);
}
