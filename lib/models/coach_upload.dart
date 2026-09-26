import 'package:cloud_firestore/cloud_firestore.dart';

/// Coach upload model matching the Laravel CoachUpload Eloquent model.
///
/// Tracks image uploads by coaches for identity verification or custom
/// design references. Admin reviews uploads.
class CoachUpload {
  final String id;
  final String userId; // FK -> User (coach)
  final String imagePath;
  final String? description;
  final String status; // 'pending', 'approved', 'rejected'
  final DateTime createdAt;
  final DateTime updatedAt;

  const CoachUpload({
    required this.id,
    required this.userId,
    required this.imagePath,
    this.description,
    this.status = 'pending',
    required this.createdAt,
    required this.updatedAt,
  });

  factory CoachUpload.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CoachUpload(
      id: doc.id,
      userId: data['userId'] ?? '',
      imagePath: data['imagePath'] ?? '',
      description: data['description'],
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'imagePath': imagePath,
      'description': description,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
}
