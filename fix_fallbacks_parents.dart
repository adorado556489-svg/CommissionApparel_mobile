import 'dart:io';

void main() {
  var file = File('lib/services/dummy_fallbacks.dart');
  var content = file.readAsStringSync();
  if (!content.contains('dummyParents')) {
    content = content.replaceFirst('List<User> dummyCoaches = [];', 'List<User> dummyCoaches = [];\nList<User> dummyParents = [];\nUser dummyAdmin = dummyUsers.isNotEmpty ? dummyUsers.firstWhere((u) => u.role == UserRole.admin, orElse: () => dummyUsers[0]) : User.empty();');
    file.writeAsStringSync(content);
  }
}
