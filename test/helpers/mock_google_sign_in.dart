import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_test/flutter_test.dart';

class MockGoogleSignIn extends Fake implements GoogleSignIn {
  @override
  Future<GoogleSignInAccount?> signOut() async {
    return null;
  }
}
