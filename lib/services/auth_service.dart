import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../data/dummy_users.dart';
export '../models/user.dart' show UserRole;

/// The three user roles identified in the Laravel project.
///
/// "Guest" is an unauthenticated state, NOT a role.


/// In-memory authentication service using [ChangeNotifier] for state
/// management via Provider.
///
/// Firebase Auth will replace this implementation later.
class AuthService extends ChangeNotifier {
  User? _currentUser;

  // ── Getters ─────────────────────────────────────────────────────────────
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCoach => _currentUser?.isCoach ?? false;
  bool get isParent => _currentUser?.isParent ?? false;

  /// Returns the appropriate dashboard route for the current user's role.
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

  // ── Auth Actions ────────────────────────────────────────────────────────

  /// Stub login: checks email against dummy users.
  ///
  /// Returns `null` on success, or an error message string on failure.
  /// Accepts any non-empty password for testing purposes.
  String? login(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      return 'Email and password are required.';
    }

    final normalizedEmail = email.trim().toLowerCase();

    final index = dummyUsers.indexWhere(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    
    if (index == -1) {
      return 'Invalid email or password.';
    }

    final user = dummyUsers[index];

    // Coaches can be declined by admin — block login
    if (user.status == 'declined') {
      return 'Your account has been declined. Please contact support.';
    }

    _currentUser = user;
    notifyListeners();
    return null; // success
  }

  /// Stub register: creates a new coach account (matching Laravel behavior
  /// where registration creates coach-role users).
  ///
  /// Returns `null` on success, or an error message string on failure.
  String? register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? organization,
    String? phone,
    String? sport,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    // Check for existing email
    final exists = dummyUsers.any(
      (u) => u.email.toLowerCase() == normalizedEmail,
    );
    if (exists) {
      return 'An account with this email already exists.';
    }

    final newUser = User(
      id: 'user-coach-${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      email: normalizedEmail,
      role: UserRole.coach,
      organization: organization,
      phone: phone,
      sport: sport,
      status: 'active', // Laravel auto-approves coach registration initially
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    dummyUsers.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return null; // success
  }

  /// Clears the current user session.
  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}

