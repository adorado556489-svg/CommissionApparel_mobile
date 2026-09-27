import 'dart:io';

void main() {
  for (var fileStr in ['test/auth_test.dart', 'test/phase1_auth_test.dart']) {
    var file = File(fileStr);
    var content = file.readAsStringSync();
    
    if (!content.contains("import 'helpers/mock_google_sign_in.dart';")) {
      content = content.replaceFirst(
        "import 'helpers/test_seeder.dart';",
        "import 'helpers/test_seeder.dart';\nimport 'helpers/mock_google_sign_in.dart';"
      );
    }
    
    content = content.replaceAll(
      "authService = AuthService(firestore: firestore, firebaseAuth: AutoSeedingMockFirebaseAuth());",
      "authService = AuthService(firestore: firestore, firebaseAuth: AutoSeedingMockFirebaseAuth(), googleSignIn: MockGoogleSignIn());"
    );
    file.writeAsStringSync(content);
  }
}
