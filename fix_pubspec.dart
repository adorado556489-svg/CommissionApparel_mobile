import 'dart:io';

void main() {
  var file = File('pubspec.yaml');
  var content = file.readAsStringSync();
  content = content.replaceAll("google_sign_in: ^7.2.0", "google_sign_in: ^6.2.1");
  file.writeAsStringSync(content);
}
