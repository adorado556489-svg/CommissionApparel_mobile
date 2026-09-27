import 'dart:io';

void main() {
  var file = File('test/admin_coach_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst("dummyUsers.add(tempCoach);", "await firestore.collection('users').doc(tempCoach.id).set(tempCoach.toFirestore());");
  content = content.replaceFirst("final exists = dummyUsers.any((u) => u.id == tempCoach.id);", "final doc = await firestore.collection('users').doc(tempCoach.id).get(); final exists = doc.exists;");
  
  // also update coach!
  content = content.replaceFirst("final updatedCoach = dummyUsers.firstWhere((u) => u.id == coachUser.id);", "final doc2 = await firestore.collection('users').doc(coachUser.id).get(); final updatedCoach = User.fromFirestore(doc2);");
  
  file.writeAsStringSync(content);
}
