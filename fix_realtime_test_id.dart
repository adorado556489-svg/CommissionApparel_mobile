import 'dart:io';

void main() {
  final file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix String instead of Timestamp
  content = content.replaceAll(
    "'createdAt': DateTime.now().toIso8601String(),",
    "'createdAt': Timestamp.now(),"
  );
  
  content = content.replaceAll(
    "'updatedAt': DateTime.now().toIso8601String(),",
    "'updatedAt': Timestamp.now(),"
  );
  
  // They are inserting DataTime.now(), not string in some places
  content = content.replaceAll(
    "'createdAt': DateTime.now(),",
    "'createdAt': Timestamp.now(),"
  );
  content = content.replaceAll(
    "'updatedAt': DateTime.now(),",
    "'updatedAt': Timestamp.now(),"
  );

  // Fix .add() to .doc(id).set()
  content = content.replaceAllMapped(
    RegExp(r"await firestore\.collection\('([^']+)'\)\.add\(\{\s*'id': '([^']+)',", multiLine: true),
    (match) => "await firestore.collection('${match.group(1)}').doc('${match.group(2)}').set({\n        'id': '${match.group(2)}',"
  );

  file.writeAsStringSync(content);
}
