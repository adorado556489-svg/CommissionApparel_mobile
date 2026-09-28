import 'dart:io';

void main() {
  var dir = Directory('test/fixtures');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('.dart')) {
      var content = file.readAsStringSync();
      // In test/fixtures, they might have `dummyUsers.where`. Change to `rawdummyUsers.where` etc.
      content = content.replaceAll('dummyUsers.', 'rawdummyUsers.');
      content = content.replaceAll('dummyTeamStores.', 'rawdummyTeamStores.');
      content = content.replaceAll('dummyParentOrders.', 'rawdummyParentOrders.');
      // Keep going for anything else
      file.writeAsStringSync(content);
    }
  }
}
