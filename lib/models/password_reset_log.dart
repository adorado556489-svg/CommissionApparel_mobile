import 'package:cloud_firestore/cloud_firestore.dart';

/// Audit trail for password reset events.
class PasswordResetLog {
  final String id;
  final String userId; // FK -> User
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

  factory PasswordResetLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PasswordResetLog(
      id: doc.id,
      userId: data['userId'] ?? '',
      ipAddress: data['ipAddress'],
      userAgent: data['userAgent'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
