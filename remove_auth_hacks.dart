import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceFirst('''
    try {
      final doc = await _firestore.collection(FirestorePaths.users).doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
      } else {
        // Fallback for tests
        final index = dummyUsers.indexWhere((u) => u.id == firebaseUser.uid);
        if (index != -1) {
          _currentUser = dummyUsers[index];
        } else {
          _currentUser = null;
        }
      }
    } catch (e) {
      // Fallback for tests
      final index = dummyUsers.indexWhere((u) => u.id == firebaseUser.uid);
      if (index != -1) {
        _currentUser = dummyUsers[index];
      } else {
        _currentUser = null;
      }
    }
''', '''
    try {
      final doc = await _firestore.collection(FirestorePaths.users).doc(firebaseUser.uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      _currentUser = null;
    }
''');

  file.writeAsStringSync(content);
}
