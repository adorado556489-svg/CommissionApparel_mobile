/// Team store model matching the Laravel `TeamStore` Eloquent model.
///
/// Represents a coach's storefront where parents can browse items and
/// place orders. Has a defined lifecycle: pending → approved → live →
/// submitted_to_admin → archived.
class TeamStore {
  final String id;
  final String userId; // FK → User (coach owner)
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

  // ── Lifecycle Computed Properties ───────────────────────────────────────

  /// Store is publicly visible and accepting orders.
  bool get isLive =>
      status == 'approved' && pricingApproved && !isArchived && !isLocked && !isDeadlinePassed;

  /// Store roster has been submitted — no more orders allowed.
  bool get isLocked => status == 'submitted_to_admin';

  /// Whether the order deadline has passed.
  bool get isDeadlinePassed =>
      orderDeadline != null && orderDeadline!.isBefore(DateTime.now());

  /// Returns the reason the store is closed, or `null` if open.
  String? get closedReason {
    if (isArchived) return 'archived';
    if (isLocked) return 'submitted_to_admin';
    if (status != 'approved') return 'not_active';
    if (!pricingApproved) return 'pricing_review';
    if (isDeadlinePassed) return 'deadline_passed';
    return null;
  }

  /// Whether the store is accepting orders.
  bool get isAcceptingOrders => closedReason == null;

  /// Generates a slug from a store name.
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
