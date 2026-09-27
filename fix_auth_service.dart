import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("await _googleSignIn.signOut();", "try { await _googleSignIn.signOut(); } catch (_) {}");
  file.writeAsStringSync(content);
}
