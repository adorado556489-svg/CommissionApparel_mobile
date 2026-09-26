import 'package:cloud_firestore/cloud_firestore.dart';

/// Comment on a store item, used for coach<->admin communication.
class StoreItemComment {
  final String id;
  final String storeItemId; // FK -> StoreItem
  final String? userId; // FK -> User (nullable for system comments)
  final String? userName; // denormalized for display
  final String comment;
  final DateTime createdAt;

  const StoreItemComment({
    required this.id,
    required this.storeItemId,
    this.userId,
    this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory StoreItemComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreItemComment(
      id: doc.id,
      storeItemId: data['storeItemId'] ?? '',
      userId: data['userId'],
      userName: data['userName'],
      comment: data['comment'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'storeItemId': storeItemId,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  StoreItemComment copyWith({
    String? id,
    String? storeItemId,
    String? userId,
    String? userName,
    String? comment,
    DateTime? createdAt,
  }) {
    return StoreItemComment(
      id: id ?? this.id,
      storeItemId: storeItemId ?? this.storeItemId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
