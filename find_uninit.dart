import 'dart:io';

void main() {
  var dir = Directory('test');
  for (var file in dir.listSync(recursive: true)) {
    if (file is File && file.path.endsWith('_test.dart')) {
      var content = file.readAsStringSync();
      if (content.contains('late FakeFirebaseFirestore firestore;') && !content.contains('firestore = FakeFirebaseFirestore()') && !content.contains('FakeFirebaseFirestore firestore =')) {
        print(file.path);
      }
    }
  }
}
