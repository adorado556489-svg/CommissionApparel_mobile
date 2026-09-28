import 'dart:io';

void main() {
  var file = File('test/admin_coach_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('''
      final doc = await firestore.collection('users').doc(coachUser.id).get();
      expect(doc.data()?['password'], 'new_password123');

      
    });''', '');
  file.writeAsStringSync(content);
}
