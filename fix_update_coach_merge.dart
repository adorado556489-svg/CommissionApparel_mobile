import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  var pattern = '''      final doc = await firestore.collection('users').doc(coach.id).get();
      if (doc.exists) {
        await firestore.collection('users').doc(coach.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'organization': organization,
          'phone': phone,
          'sport': sport,
          'status': status,
        });
      }''';
      
  var replacement = '''      await firestore.collection('users').doc(coach.id).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'organization': organization,
        'phone': phone,
        'sport': sport,
        'status': status,
      }, SetOptions(merge: true));''';
      
  content = content.replaceFirst(pattern, replacement);
  file.writeAsStringSync(content);
}
