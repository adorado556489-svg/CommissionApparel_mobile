import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../constants/firestore_paths.dart';
import '../constants/statuses.dart';
import '../models/user.dart';
import 'user_service.dart';

export '../models/user.dart' show UserRole;

/// Authentication + current-user session.
///
/// The Firestore `users/{uid}` document is the source of truth for role and
/// status and is streamed live, so role changes (e.g. store approval making a
/// user a coach) take effect immediately without re-login.
class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  User? _currentUser;
  bool _isLoading = true;
  String? _sessionMessage;

  StreamSubscription<fb.User?>? _authSub;
  StreamSubscription<DocumentSnapshot>? _userDocSub;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    required FirebaseFirestore firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
    _authSub = _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ---- Session state --------------------------------------------------------

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  UserRole? get currentRole => _currentUser?.role;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCoach => _currentUser?.role == UserRole.coach;
  bool get isParent => _currentUser?.role == UserRole.parent;

  /// One-shot message for the login screen (e.g. account suspended).
  String? takeSessionMessage() {
    final m = _sessionMessage;
    _sessionMessage = null;
    return m;
  }

  /// Sign-in providers linked to the current Firebase account.
  Set<String> get _providers =>
      _auth.currentUser?.providerData.map((p) => p.providerId).toSet() ?? {};

  /// True when the account can change email/password inside the app.
  /// Google-only accounts are managed by Google.
  bool get hasPasswordProvider =>
      _providers.contains('password') || (_providers.isEmpty && _auth.currentUser != null);
  bool get isGoogleAccount => _providers.contains('google.com');

  String get dashboardRoute {
    if (!isAuthenticated) return '/login';
    switch (currentRole) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.coach:
        return '/coach/dashboard';
      default:
        return '/home';
    }
  }

  void _onAuthStateChanged(fb.User? fbUser) {
    _userDocSub?.cancel();
    _userDocSub = null;

    if (fbUser == null) {
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _userDocSub = _firestore
        .collection(FirestorePaths.users)
        .doc(fbUser.uid)
        .snapshots()
        .listen((doc) => _onUserDoc(fbUser, doc), onError: (Object e) {
      debugPrint('AUTH: user stream error: $e');
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _onUserDoc(fb.User fbUser, DocumentSnapshot doc) async {
    if (!doc.exists) {
      // Self-heal: an auth account without a profile (e.g. interrupted
      // sign-up). Recreate a minimal parent profile; the stream will fire
      // again with the new document.
      try {
        await _createProfile(
          uid: fbUser.uid,
          email: fbUser.email ?? '',
          displayName: fbUser.displayName,
        );
      } catch (e) {
        debugPrint('AUTH: could not repair profile: $e');
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      }
      return;
    }

    final user = User.fromFirestore(doc);

    if (user.status == UserStatus.suspended) {
      _sessionMessage = 'Your account has been suspended. Please contact support.';
      await logout();
      return;
    }

    // Keep the profile email in sync after a verified email change.
    final authEmail = fbUser.email;
    if (authEmail != null && authEmail.isNotEmpty && authEmail != user.email) {
      unawaited(doc.reference.update({'email': authEmail, 'updatedAt': FieldValue.serverTimestamp()})
          .catchError((Object e) => debugPrint('AUTH: email sync failed: $e')));
    }

    _currentUser = user;
    _isLoading = false;
    notifyListeners();
  }

  Future<User> _createProfile({
    required String uid,
    required String email,
    String? displayName,
    String? firstName,
    String? lastName,
    String? phone,
    String? organization,
  }) async {
    final parts = (displayName ?? '').trim().split(RegExp(r'\s+'));
    final now = DateTime.now();
    final user = User(
      id: uid,
      email: email,
      password: '',
      firstName: firstName ?? (parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'New'),
      lastName: lastName ?? (parts.length > 1 ? parts.skip(1).join(' ') : 'User'),
      phone: phone,
      organization: organization,
      role: UserRole.parent,
      status: UserStatus.active,
      createdAt: now,
      updatedAt: now,
    );
    await _firestore.collection(FirestorePaths.users).doc(uid).set(user.toFirestore());
    return user;
  }

  // ---- Sign in / up ---------------------------------------------------------

  /// Returns null on success, otherwise a user-friendly error.
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return authErrorMessage('unknown');
    }
  }

  /// Creates an email/password account with a `parent` profile.
  /// Returns null on success, otherwise a user-friendly error.
  Future<String?> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? organization,
    String? phone,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password);
      final fbUser = cred.user;
      if (fbUser == null) return authErrorMessage('unknown');

      final user = await _createProfile(
        uid: fbUser.uid,
        email: email.trim(),
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: _nullIfBlank(phone),
        organization: _nullIfBlank(organization),
      );
      unawaited(fbUser.updateDisplayName(user.fullName).catchError((_) {}));
      unawaited(fbUser.sendEmailVerification().catchError((_) {}));
      _currentUser = user;
      notifyListeners();
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return authErrorMessage('unknown');
    }
  }

  /// Google sign-in. Always shows the account picker. Returns null if the
  /// user cancels. Throws a user-friendly [String] message on failure.
  Future<User?> signInWithGoogle() async {
    try {
      // Clear cached Google session so the account picker is always shown.
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final cred = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(cred);
      final fbUser = userCred.user;
      if (fbUser == null) return null;

      final doc = await _firestore.collection(FirestorePaths.users).doc(fbUser.uid).get();
      final user = doc.exists
          ? User.fromFirestore(doc)
          : await _createProfile(
              uid: fbUser.uid,
              email: googleUser.email,
              displayName: googleUser.displayName,
            );
      if (user.status == UserStatus.suspended) {
        await logout();
        throw 'Your account has been suspended. Please contact support.';
      }
      _currentUser = user;
      notifyListeners();
      return user;
    } on fb.FirebaseAuthException catch (e) {
      debugPrint('Google Sign-In error: ${e.code}');
      throw authErrorMessage(e.code);
    }
  }

  /// Sends a password reset email. Always reports success for unknown emails
  /// to avoid account enumeration. Returns an error only for invalid input or
  /// network problems.
  Future<String?> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') return null;
      return authErrorMessage(e.code);
    } catch (_) {
      return authErrorMessage('unknown');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('AUTH: signOut error: $e');
    }
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    _currentUser = null;
    notifyListeners();
  }

  // ---- Profile --------------------------------------------------------------

  Future<String?> updateProfileDetails(String firstName, String lastName, {String? phone}) async {
    final user = _currentUser;
    final fbUser = _auth.currentUser;
    if (user == null || fbUser == null) return 'You are not signed in.';
    if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
      return 'First and last name are required.';
    }
    try {
      await _firestore.collection(FirestorePaths.users).doc(user.id).update({
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        if (phone != null) 'phone': _nullIfBlank(phone),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      unawaited(fbUser.updateDisplayName('${firstName.trim()} ${lastName.trim()}').catchError((_) {}));
      return null;
    } catch (e) {
      debugPrint('AUTH: updateProfileDetails: $e');
      return 'Could not update your profile. Please try again.';
    }
  }

  /// Sends a verification link to [newEmail]. The address changes only after
  /// the user clicks the link; the profile email is synced on next session.
  Future<String?> updateEmailAddress(String newEmail, {required String currentPassword}) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || fbUser.email == null) return 'You are not signed in.';
    if (!hasPasswordProvider) return 'Your email is managed by your Google account.';
    try {
      await fbUser.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(email: fbUser.email!, password: currentPassword),
      );
      await fbUser.verifyBeforeUpdateEmail(newEmail.trim());
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return authErrorMessage('unknown');
    }
  }

  /// Changes the password after re-authenticating with the current one.
  Future<String?> changePassword({required String currentPassword, required String newPassword}) async {
    final fbUser = _auth.currentUser;
    if (fbUser == null || fbUser.email == null) return 'You are not signed in.';
    if (!hasPasswordProvider) return 'Your password is managed by your Google account.';
    try {
      await fbUser.reauthenticateWithCredential(
        fb.EmailAuthProvider.credential(email: fbUser.email!, password: currentPassword),
      );
      await fbUser.updatePassword(newPassword);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return authErrorMessage(e.code);
    } catch (_) {
      return authErrorMessage('unknown');
    }
  }

  Future<String?> sendPasswordResetToCurrentEmail() async {
    final email = _auth.currentUser?.email;
    if (email == null) return 'You are not signed in.';
    return sendPasswordReset(email);
  }

  /// Kept for backwards compatibility; prefer [UserService.getUserById].
  Future<User?> getUserById(String uid) => UserService.getUserById(_firestore, uid);

  // ---- Helpers --------------------------------------------------------------

  static String? _nullIfBlank(String? v) => (v == null || v.trim().isEmpty) ? null : v.trim();

  /// Maps Firebase Auth error codes to user-facing messages.
  static String authErrorMessage(String code) {
    const messages = {
      'invalid-email': 'Enter a valid email address.',
      'user-disabled': 'This account has been disabled.',
      'user-not-found': 'Invalid email or password.',
      'wrong-password': 'Invalid email or password.',
      'invalid-credential': 'Invalid email or password.',
      'email-already-in-use': 'An account already exists with this email.',
      'weak-password': 'Choose a stronger password (at least 8 characters).',
      'too-many-requests': 'Too many attempts. Please wait and try again.',
      'network-request-failed': 'No internet connection. Please try again.',
      'requires-recent-login': 'Please sign in again to continue.',
      'operation-not-allowed': 'This sign-in method is not enabled.',
      'account-exists-with-different-credential':
          'An account already exists with this email using a different sign-in method.',
    };
    return messages[code] ?? 'Something went wrong. Please try again.';
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _userDocSub?.cancel();
    super.dispose();
  }
}

