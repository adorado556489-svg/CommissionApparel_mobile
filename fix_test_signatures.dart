import 'dart:io';
void main() {
  var files = [
    'test/phase4_transactions_test.dart',
    'test/security/firestore_rules_test.dart'
  ];
  for (var path in files) {
    var file = File(path);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      content = content.replaceAll('currentUser: ', '');
      file.writeAsStringSync(content);
    }
  }
}
