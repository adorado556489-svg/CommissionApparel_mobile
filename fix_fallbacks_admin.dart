import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst('User dummyAdmin = dummyUsers.isNotEmpty ? dummyUsers.firstWhere((u) => u.role == UserRole.admin, orElse: () => dummyUsers[0]) : User.empty();', '');
  file.writeAsStringSync(content);
}
