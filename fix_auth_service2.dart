import 'dart:io';

void main() {
  var file = File('lib/services/auth_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceFirst(
      "final GoogleSignIn _googleSignIn = GoogleSignIn();",
      "final GoogleSignIn _googleSignIn;");
  
  content = content.replaceFirst(
      """  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {""",
      """  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ?? GoogleSignIn() {""");
  
  file.writeAsStringSync(content);
}
