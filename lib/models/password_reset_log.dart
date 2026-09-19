/// Audit trail for password reset events.
class PasswordResetLog {
  final String id;
  final String userId; // FK → User
  final String? ipAddress;
  final String? userAgent;
  final DateTime createdAt;

  const PasswordResetLog({ 
    required this.id,
    required this.userId,
    this.ipAddress,
    this.userAgent,
    required this.createdAt,
  });
}
