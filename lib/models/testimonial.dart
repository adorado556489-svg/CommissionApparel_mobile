import 'package:cloud_firestore/cloud_firestore.dart';

/// Testimonial model matching the Laravel Testimonial Eloquent model.
///
/// Coach/client endorsements displayed on the public landing page.
/// Admin manages testimonials via site settings.
class Testimonial {
  final String id;
  final String clientName;
  final String? organization;
  final String content;
  final String? imagePath;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Testimonial({
    required this.id,
    required this.clientName,
    this.organization,
    required this.content,
    this.imagePath,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Testimonial.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Testimonial(
      id: doc.id,
      clientName: data['clientName'] ?? '',
      organization: data['organization'],
      content: data['content'] ?? '',
      imagePath: data['imagePath'],
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'clientName': clientName,
      'organization': organization,
      'content': content,
      'imagePath': imagePath,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  Testimonial copyWith({
    String? id,
    String? clientName,
    String? organization,
    String? content,
    String? imagePath,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Testimonial(
      id: id ?? this.id,
      clientName: clientName ?? this.clientName,
      organization: organization ?? this.organization,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
