import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';
import '../models/user.dart';
export '../models/user.dart' show UserRole;

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final dynamic _googleSignIn;
  User? _currentUser;
  bool _isLoading = true;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    required FirebaseFirestore firestore,
    dynamic googleSignIn,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore,
        _googleSignIn = googleSignIn {
    _init();
  }

  bool get isAuthenticated => _currentUser != null;
  User? get currentUser => _currentUser;
  UserRole? get currentRole => _currentUser?.role;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isCoach => _currentUser?.role == UserRole.coach;
  bool get isParent => _currentUser?.role == UserRole.parent;

  String get dashboardRoute {
    if (!isAuthenticated) return '/login';
    switch (currentRole) {
      case UserRole.admin: return '/admin/dashboard';
      case UserRole.coach: return '/coach/dashboard';
      case UserRole.parent: return '/';
      default: return '/';
    }
  }

  void _init() {
    _auth.authStateChanges().listen((fbUser) async {
      _isLoading = true;
      notifyListeners();
      
      if (fbUser == null) {
        _currentUser = null;
      } else {
        await _loadUser(fbUser.uid);
      }
      
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
      } else {
        _currentUser = null;
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _currentUser = null;
    }
  }

  Future<User?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
      if (doc.exists) return User.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting user: $e');
    }
    return null;
  }

  Future<List<User>> getAllCoaches() async {
    try {
      final qs = await _firestore.collection(FirestorePaths.users).where('role', isEqualTo: 'coach').get();
      return qs.docs.map((d) => User.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('Error getting coaches: $e');
      return [];
    }
  }

  Future<String?> register(String email, String password, {required String firstName, required String lastName, String? organization}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      if (cred.user != null) {
        final newUser = User(
          id: cred.user!.uid,
          email: email,
          password: '',
          firstName: firstName,
          lastName: lastName,
          organization: organization,
          role: UserRole.coach,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _firestore.collection(FirestorePaths.users).doc(newUser.id).set(newUser.toFirestore());
        _currentUser = newUser;
        notifyListeners();
        return null; // Return null on success for tests
      }
    } catch (e) {
      return e.toString();
    }
    return 'Unknown error';
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // null on success
    } catch (e) {
      return 'Invalid email or password.';
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      if (_googleSignIn == null) throw Exception('Google SignIn not configured');
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final cred = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(cred);
      if (userCred.user != null) {
        final uid = userCred.user!.uid;
        final doc = await _firestore.collection(FirestorePaths.users).doc(uid).get();
        if (!doc.exists) {
          final newUser = User(
            id: uid,
            email: googleUser.email,
            password: '',
            firstName: googleUser.displayName?.split(' ').first ?? 'Google',
            lastName: googleUser.displayName?.split(' ').skip(1).join(' ') ?? 'User',
            role: UserRole.coach,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          await _firestore.collection(FirestorePaths.users).doc(uid).set(newUser.toFirestore());
          _currentUser = newUser;
          notifyListeners();
          return newUser;
        } else {
          _currentUser = User.fromFirestore(doc);
          notifyListeners();
          return _currentUser;
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In error: $e');
      rethrow;
    }
    return null;
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }

  Future<bool> verifyResetIdentity(String email, String answer) async {
    return true;
  }

  Future<void> completePasswordReset(String newPassword) async {
    final u = _auth.currentUser;
    if (u != null) {
      await u.updatePassword(newPassword);
    }
  }
  
  String? updateProfileLogo(String path) {
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
