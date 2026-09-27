import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("logo: imagePath", "logoPath: imagePath");
  file.writeAsStringSync(content);
}
