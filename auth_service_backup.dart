import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';
import '../models/user.dart';
import '../data/dummy_users.dart';
import '../data/dummy_logs.dart';
export '../models/user.dart' show UserRole;

class AuthService extends ChangeNotifier {
  fb.FirebaseAuth? _injectedAuth;
  FirebaseFirestore? _injectedFirestore;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {
    _injectedAuth = firebaseAuth;
    _injectedFirestore = firestore;
    if (_injectedAuth != null) {
      _injectedAuth!.authStateChanges().listen(_onAuthStateChanged);
    } else {
      try {
        fb.FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
      } catch (_) {
        // Ignored in tests if Firebase isn't initialized
      }
    }
  }

  fb.FirebaseAuth get _firebaseAuth =>
      _injectedAuth ?? fb.FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      _injectedFirestore ?? FirebaseFirestore.instance;

  User? _currentUser;

  Future<void> _fetchAndSetUser(fb.User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection(FirestorePaths.users)
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        _currentUser = User.fromFirestore(doc);
      } else {
        // Fallback to dummy data (Phase 5 migration compatibility)
        final index = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),
        );
        if (index != -1) {
          _currentUser = dummyUsers[index];
        } else {
          _currentUser = null;
        }
      }
    } catch (e) {
      // Fallback for tests
      final index = dummyUsers.indexWhere(
        (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),
      );
      _currentUser = index != -1 ? dummyUsers[index] : null;
    }
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(fb.User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      notifyListeners();
    } else {
      await _fetchAndSetUser(firebaseUser);
    }
  }

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCoach => _currentUser?.isCoach ?? false;
  bool get isParent => _currentUser?.isParent ?? false;

  String get dashboardRoute {
    switch (_currentUser?.role) {
      case UserRole.admin:
        return '/admin/dashboard';
      case UserRole.coach:
        return '/coach/dashboard';
      case UserRole.parent:
      case null:
        return '/';
    }
  }

  Future<String?> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required.';
    }

    final normalizedEmail = email.trim().toLowerCase();

    // Check Firestore for declined status first
    try {
      final qs = await _firestore
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      
      if (qs.docs.isNotEmpty) {
        final userDoc = User.fromFirestore(qs.docs.first);
        if (userDoc.status == 'declined') {
          return 'Your account has been declined. Please contact support.';
        }
      } else {
        // Fallback to dummy users
        final index = dummyUsers.indexWhere(
          (u) => u.email.toLowerCase() == normalizedEmail,
        );
        if (index == -1) {
          return 'Invalid email or password.';
        }
        if (dummyUsers[index].status == 'declined') {
          return 'Your account has been declined. Please contact support.';
        }
      }
    } catch (e) {
      // Fallback
      final index = dummyUsers.indexWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (index == -1) return 'Invalid email or password.';
      if (dummyUsers[index].status == 'declined') {
        return 'Your account has been declined. Please contact support.';
      }
    }

    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
      await _fetchAndSetUser(cred.user!);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      }
      return e.message ?? 'Login failed.';
    } catch (e) {
      return 'Invalid email or password.';
    }
  }

  Future<String?> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? organization,
    String? phone,
    String? sport,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    try {
      // Check Firestore
      final qs = await _firestore
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      if (qs.docs.isNotEmpty) {
        return 'An account with this email already exists.';
      }

      // Check Dummy
      final existsInDummy = dummyUsers.any((u) => u.email.toLowerCase() == normalizedEmail);
      if (existsInDummy) { 
        return 'An account with this email already exists.'; 
      }

      final cred = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final uid = cred.user!.uid;

      final newUser = User(
        id: uid,
        firstName: firstName,
        lastName: lastName,
        email: normalizedEmail,
        password: password, // not stored
        role: UserRole.coach,
        organization: organization,
        phone: phone,
        sport: sport,
        status: 'active',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Write to Firestore
      await _firestore
          .collection(FirestorePaths.users)
          .doc(uid)
          .set(newUser.toFirestore());

      // Fallback for current memory
      dummyUsers.add(newUser);

      await _fetchAndSetUser(cred.user!);

      return null;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'An account with this email already exists.';
      }
      return e.message ?? 'Registration failed.';
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordReset(
    String email,
    String phone,
    String organization,
  ) async {
    if (email.trim().isEmpty ||
        phone.trim().isEmpty ||
        organization.trim().isEmpty) {
      return 'The provided identity details do not match our records.';
    }

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim().toLowerCase();
    final normalizedOrg = organization.trim().toLowerCase();

    User? matchedUser;

    try {
      final qs = await _firestore
          .collection(FirestorePaths.users)
          .where('email', isEqualTo: normalizedEmail)
          .limit(1)
          .get();
      
      if (qs.docs.isNotEmpty) {
        matchedUser = User.fromFirestore(qs.docs.first);
      }
    } catch (_) {}

    if (matchedUser == null) {
      final userIndex = dummyUsers.indexWhere(
        (u) => u.email.toLowerCase() == normalizedEmail,
      );
      if (userIndex != -1) {
        matchedUser = dummyUsers[userIndex];
      }
    }

    if (matchedUser == null) {
      return 'The provided identity details do not match our records.';
    }

    if ((matchedUser.phone?.trim().toLowerCase() ?? '') != normalizedPhone ||
        (matchedUser.organization?.trim().toLowerCase() ?? '') != normalizedOrg) {
      return 'The provided identity details do not match our records.';
    }

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: normalizedEmail);

      dummyPasswordResetLogs.add({
        'user_id': matchedUser.id,
        'ip_address': '127.0.0.1',
        'user_agent': 'Flutter App (Firebase)',
        'created_at': DateTime.now(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProfileLogo(String logoPath) async {
    if (_currentUser == null) return 'Unauthenticated';

    try {
      final updatedUser = _currentUser!.copyWith(logoPath: logoPath);
      await _firestore
          .collection(FirestorePaths.users)
          .doc(_currentUser!.id)
          .update({'logoPath': logoPath});
      _currentUser = updatedUser;
    } catch (e) {
      // Fallback
      final index = dummyUsers.indexWhere((u) => u.id == _currentUser!.id);
      if (index != -1) {
        dummyUsers[index] = dummyUsers[index].copyWith(logoPath: logoPath);
        _currentUser = dummyUsers[index];
      }
    }
    
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
