import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/firestore_paths.dart';
import '../models/user.dart';
export '../models/user.dart' show UserRole;

class AuthService extends ChangeNotifier {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  User? _currentUser;
  bool _isLoading = true;

  AuthService({
    fb.FirebaseAuth? firebaseAuth,
    required FirebaseFirestore firestore,
    GoogleSignIn? googleSignIn,
  })  : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore,
        _googleSignIn = googleSignIn ?? GoogleSignIn() {
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
      case UserRole.parent: return '/home';
      default: return '/home';
    }
  }

  StreamSubscription<DocumentSnapshot>? _userDocSub;
  StreamSubscription<QuerySnapshot>? _storeSub;
  bool _hasApprovedStore = false;
  
  bool get hasApprovedStore => _hasApprovedStore;

  void _init() {
    _auth.authStateChanges().listen((fbUser) {
      _isLoading = true;
      notifyListeners();
      
      _userDocSub?.cancel();
      _userDocSub = null;
      _storeSub?.cancel();
      _storeSub = null;
      _hasApprovedStore = false;
      
      if (fbUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        _userDocSub = _firestore.collection(FirestorePaths.users).doc(fbUser.uid).snapshots().listen((doc) {
          if (doc.exists) {
            _currentUser = User.fromFirestore(doc);
            debugPrint('AUTH: User updated via stream');
          } else {
            _currentUser = null;
          }
          _isLoading = false;
          notifyListeners();
        });
        
        _storeSub = _firestore.collection(FirestorePaths.teamStores)
            .where('userId', isEqualTo: fbUser.uid)
            .where('status', isEqualTo: 'approved')
            .where('isArchived', isEqualTo: false)
            .snapshots().listen((snapshot) {
          _hasApprovedStore = snapshot.docs.isNotEmpty;
          debugPrint('AUTH: hasApprovedStore updated');
          notifyListeners();
        });
      }
    });
  }

  Future<String?> updateProfileDetails(String firstName, String lastName) async {
    try {
      final user = _currentUser;
      final fbUser = _auth.currentUser;
      if (user == null || fbUser == null) return 'User not logged in.';

      await _firestore.collection(FirestorePaths.users).doc(user.id).update({
        'firstName': firstName,
        'lastName': lastName,
        'updatedAt': DateTime.now(),
      });

      await fbUser.updateDisplayName('$firstName $lastName');
      return null;
    } catch (e) {
      return 'Failed to update name: $e';
    }
  }

  Future<String?> updateEmailAddress(String newEmail) async {
    try {
      final user = _currentUser;
      final fbUser = _auth.currentUser;
      if (user == null || fbUser == null) return 'User not logged in.';

      await fbUser.verifyBeforeUpdateEmail(newEmail);

      await _firestore.collection(FirestorePaths.users).doc(user.id).update({
        'email': newEmail,
        'updatedAt': DateTime.now(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> sendPasswordResetToCurrentEmail() async {
    try {
      final fbUser = _auth.currentUser;
      if (fbUser == null || fbUser.email == null) return 'User not logged in or missing email.';
      
      await _auth.sendPasswordResetEmail(email: fbUser.email!);
      return null;
    } catch (e) {
      return e.toString();
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

  Future<String?> register({required String email, required String password, required String firstName, required String lastName, String? organization, String? phone, String? sport}) async {
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
          role: UserRole.parent,
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
            role: UserRole.parent,
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

    Future<String?> sendPasswordReset(String email, String phone, String organization) async {
    try {
      final qs = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (qs.docs.isEmpty) {
        return 'No account found with this email.';
      }
      final userData = qs.docs.first.data();
      
      final dbPhone = userData['phone'] as String?;
      final dbOrg = userData['organization'] as String?;
      
      if (dbPhone != phone || dbOrg != organization) {
        return 'Identity verification failed. Information does not match our records.';
      }

      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } catch (e) {
      return 'Failed to process password reset.';
    }
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

