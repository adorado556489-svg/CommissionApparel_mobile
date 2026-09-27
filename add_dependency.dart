import 'dart:io';

void main() {
  var file = File('pubspec.yaml');
  var content = file.readAsStringSync();
  content = content.replaceFirst("firebase_auth: ^5.0.0", "firebase_auth: ^5.0.0\n  google_sign_in: ^6.2.1");
  file.writeAsStringSync(content);
}
