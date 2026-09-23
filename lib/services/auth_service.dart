import 'package:flutter/foundation.dart';

import '../models/user.dart';
import '../data/dummy_users.dart';
import '../data/dummy_logs.dart';
export '../models/user.dart' show UserRole;

/// The three user roles identified in the Laravel project.
///
/// "Guest" is an unauthenticated state, NOT a role.

class PasswordResetSession {
  final String userId;
  final DateTime expiresAt;

  PasswordResetSession({required this.userId, required this.expiresAt});

  bool get isValid => DateTime.now().isBefore(expiresAt);
}

/// In-memory authentication service using [ChangeNotifier] for state
/// management via Provider.
///
/// Firebase Auth will replace this implementation later.
class AuthService extends ChangeNotifier {
  User? _currentUser;
  PasswordResetSession? _resetSession;

  // "?"? Getters "?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  UserRole? get currentRole => _currentUser?.role;

  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isCoach => _currentUser?.isCoach ?? false;
  bool get isParent => _currentUser?.isParent ?? false;

  PasswordResetSession? get resetSession => _resetSession;

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

  // "?"? Auth Actions "?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?"?

  /// Stub login: checks email and password against dummy users.
  ///
  /// Returns `null` on success, or an error message string on failure.
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

    // Enforce password check added in Phase 7B
    if (user.password != password) {
      return 'Invalid email or password.';
    }

    // Coaches can be declined by admin ?" block login
    if (user.status == 'declined') {
      return 'Your account has been declined. Please contact support.';
    }

    _currentUser = user;
    notifyListeners();
    return null; // success
  }

  /// Verifies identity matching Laravel's exact rule:
  /// Email, Phone, Organization must strictly match (trim/lowercase).
  /// Sets a 15-minute reset session in-memory on success.
  String? verifyResetIdentity(String email, String phone, String organization) {
    if (email.trim().isEmpty || phone.trim().isEmpty || organization.trim().isEmpty) {
      return 'The provided identity details do not match our records.';
    }

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedPhone = phone.trim().toLowerCase();
    final normalizedOrg = organization.trim().toLowerCase();

    final userIndex = dummyUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);

    if (userIndex == -1) {
      return 'The provided identity details do not match our records.';
    }
    final user = dummyUsers[userIndex];

    if ((user.phone?.trim().toLowerCase() ?? '') != normalizedPhone || 
        (user.organization?.trim().toLowerCase() ?? '') != normalizedOrg) {
      // Laravel exact generic error message:
      return 'The provided identity details do not match our records.';
    }

    // Create 15-minute session
    _resetSession = PasswordResetSession(
      userId: user.id, 
      expiresAt: DateTime.now().add(const Duration(minutes: 15))
    );
    notifyListeners();
    return null;
  }

  /// Updates the user's password using the active reset session.
  String? resetPassword(String password) {
    if (_resetSession == null || !_resetSession!.isValid) {
      _resetSession = null;
      return 'Your password reset session has expired or is invalid. Please verify your identity again.';
    }

    final userIndex = dummyUsers.indexWhere((u) => u.id == _resetSession!.userId);
    if (userIndex == -1) {
      _resetSession = null;
      return 'User not found.';
    }

    final user = dummyUsers[userIndex];
    dummyUsers[userIndex] = user.copyWith(password: password);

    // Simulate PasswordResetLog
    dummyPasswordResetLogs.add({
      'user_id': user.id,
      'ip_address': '127.0.0.1', // mock IP
      'user_agent': 'Flutter App',
      'created_at': DateTime.now(),
    });

    // Clear session on success
    _resetSession = null;
    notifyListeners();
    return null;
  }

  /// Force clear reset session for testing
  void clearResetSession() {
    _resetSession = null;
    notifyListeners();
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
      password: password,
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
  String? updateProfileLogo(String logoPath) {
    if (_currentUser == null) return 'Unauthenticated';
    final index = dummyUsers.indexWhere((u) => u.id == _currentUser!.id);
    if (index != -1) {
      dummyUsers[index] = dummyUsers[index].copyWith(logoPath: logoPath);
      _currentUser = dummyUsers[index];
      notifyListeners();
    }
    return null;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}
