import 'dart:io';

void main() {
  var file = File('test/phase4_transactions_test.dart');
  if (file.existsSync()) {
    var content = file.readAsStringSync();
    content = content.replaceAll('currentUser: normalUser,', 'normalUser,');
    file.writeAsStringSync(content);
  }
  var ruleFile = File('test/security/firestore_rules_test.dart');
  if (ruleFile.existsSync()) {
    var content = ruleFile.readAsStringSync();
    content = content.replaceAll('currentUser: normalUser,', 'normalUser,');
    ruleFile.writeAsStringSync(content);
  }
}
