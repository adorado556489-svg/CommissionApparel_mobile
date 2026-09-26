import 'package:cloud_firestore/cloud_firestore.dart';

/// Team store model matching the Laravel TeamStore Eloquent model.
///
/// Represents a coach's storefront where parents can browse items and
/// place orders. Has a defined lifecycle: pending -> approved -> live ->
/// submitted_to_admin -> archived.
class TeamStore {
  final String id;
  final String userId; // FK -> User (coach owner)
  final String name;
  final String slug;
  final String? description;
  final String? coverImagePath;
  final DateTime? orderDeadline;
  final String status; // pending, approved, declined, submitted_to_admin
  final String? packageType; // package_a, package_b, package_c, individual
  final bool pricingApproved;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamStore({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    this.description,
    this.coverImagePath,
    this.orderDeadline,
    this.status = 'pending',
    this.packageType,
    this.pricingApproved = false,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeamStore.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return TeamStore(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      description: data['description'],
      coverImagePath: data['coverImagePath'],
      orderDeadline: (data['orderDeadline'] as Timestamp?)?.toDate(),
      status: data['status'] ?? 'pending',
      packageType: data['packageType'],
      pricingApproved: data['pricingApproved'] ?? false,
      isArchived: data['isArchived'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'slug': slug,
      'description': description,
      'coverImagePath': coverImagePath,
      'orderDeadline': orderDeadline != null ? Timestamp.fromDate(orderDeadline!) : null,
      'status': status,
      'packageType': packageType,
      'pricingApproved': pricingApproved,
      'isArchived': isArchived,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Lifecycle Computed Properties
  bool get isLive =>
      status == 'approved' && pricingApproved && !isArchived && !isLocked && !isDeadlinePassed;

  bool get isLocked => status == 'submitted_to_admin';

  bool get isDeadlinePassed =>
      orderDeadline != null && orderDeadline!.isBefore(DateTime.now());

  String? get closedReason {
    if (isArchived) return 'archived';
    if (isLocked) return 'submitted_to_admin';
    if (status != 'approved') return 'not_active';
    if (!pricingApproved) return 'pricing_review';
    if (isDeadlinePassed) return 'deadline_passed';
    return null;
  }

  bool get isAcceptingOrders => closedReason == null;

  static String generateSlug(String name) {
    return name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }

  TeamStore copyWith({
    String? id,
    String? userId,
    String? name,
    String? slug,
    String? description,
    String? coverImagePath,
    DateTime? orderDeadline,
    String? status,
    String? packageType,
    bool? pricingApproved,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamStore(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      orderDeadline: orderDeadline ?? this.orderDeadline,
      status: status ?? this.status,
      packageType: packageType ?? this.packageType,
      pricingApproved: pricingApproved ?? this.pricingApproved,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TeamStore($id, $name, status=$status)';
}
