import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/statuses.dart';
import '../utils/formatters.dart';

/// A coach's storefront where parents browse items and place orders.
///
/// Lifecycle: pending -> approved (live) -> submitted_to_admin (locked)
/// -> approved (re-opened) ... ; or pending -> declined. Admin may archive.
class TeamStore {
  final String id;
  final String userId; // FK -> User (coach owner)
  final String name;
  final String slug;
  final String? description; // welcome message shown on the storefront
  final String? sport;
  final String? logoPath; // team logo (HTTPS URL)
  final String? coverImagePath; // banner image (HTTPS URL)
  final DateTime? orderDeadline; // last day orders are accepted (inclusive)
  final String status; // see StoreStatus
  final String? packageType; // legacy, no longer used by the UI
  final bool pricingApproved;
  final bool isArchived;
  final String? paymentInstructions;
  final String? declineReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeamStore({
    required this.id,
    required this.userId,
    required this.name,
    required this.slug,
    this.description,
    this.sport,
    this.logoPath,
    this.coverImagePath,
    this.orderDeadline,
    this.status = StoreStatus.pending,
    this.packageType,
    this.pricingApproved = false,
    this.isArchived = false,
    this.paymentInstructions,
    this.declineReason,
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
      sport: data['sport'],
      logoPath: data['logoPath'],
      coverImagePath: data['coverImagePath'],
      orderDeadline: (data['orderDeadline'] as Timestamp?)?.toDate(),
      status: data['status'] ?? StoreStatus.pending,
      packageType: data['packageType'],
      pricingApproved: data['pricingApproved'] ?? false,
      isArchived: data['isArchived'] ?? false,
      paymentInstructions: data['paymentInstructions'],
      declineReason: data['declineReason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'nameLower': name.toLowerCase(),
      'slug': slug,
      'description': description,
      'sport': sport,
      'logoPath': logoPath,
      'coverImagePath': coverImagePath,
      'orderDeadline': orderDeadline != null ? Timestamp.fromDate(orderDeadline!) : null,
      'status': status,
      'packageType': packageType,
      'pricingApproved': pricingApproved,
      'isArchived': isArchived,
      'paymentInstructions': paymentInstructions,
      'declineReason': declineReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ---- Lifecycle -----------------------------------------------------------

  bool get isPending => status == StoreStatus.pending;
  bool get isDeclined => status == StoreStatus.declined;
  bool get isApproved => status == StoreStatus.approved;
  bool get isLocked => status == StoreStatus.submittedToAdmin;

  /// Orders are accepted through the whole deadline day (local time).
  DateTime? get deadlineCutoff => orderDeadline == null
      ? null
      : DateTime(orderDeadline!.year, orderDeadline!.month, orderDeadline!.day)
          .add(const Duration(days: 1));

  bool isDeadlinePassedAt(DateTime now) =>
      deadlineCutoff != null && !now.isBefore(deadlineCutoff!);

  bool get isDeadlinePassed => isDeadlinePassedAt(DateTime.now());

  /// Days left until the cutoff (0 on the last day), null if no deadline.
  int? get daysLeft {
    final cutoff = deadlineCutoff;
    if (cutoff == null) return null;
    final diff = cutoff.difference(DateTime.now());
    if (diff.isNegative) return 0;
    return diff.inHours ~/ 24;
  }

  bool get isLive =>
      isApproved && pricingApproved && !isArchived && !isDeadlinePassed;

  /// Machine-readable reason the store is closed, or null if open.
  String? get closedReason {
    if (isArchived) return 'archived';
    if (isLocked) return 'submitted_to_admin';
    if (!isApproved) return 'not_active';
    if (!pricingApproved) return 'pricing_review';
    if (isDeadlinePassed) return 'deadline_passed';
    return null;
  }

  /// Customer-facing explanation for [closedReason].
  String? get closedMessage {
    switch (closedReason) {
      case 'archived':
        return 'This store is no longer available.';
      case 'submitted_to_admin':
        return 'Ordering is closed — the team order has been sent to production.';
      case 'not_active':
        return 'This store is not open yet.';
      case 'pricing_review':
        return 'This store is under review and will open soon.';
      case 'deadline_passed':
        return 'The ordering deadline for this store has passed.';
      default:
        return null;
    }
  }

  bool get isAcceptingOrders => closedReason == null;

  static String generateSlug(String name) => Fmt.slug(name);

  TeamStore copyWith({
    String? id,
    String? userId,
    String? name,
    String? slug,
    String? description,
    String? sport,
    String? logoPath,
    String? coverImagePath,
    DateTime? orderDeadline,
    bool clearDeadline = false,
    String? status,
    String? packageType,
    bool? pricingApproved,
    bool? isArchived,
    String? paymentInstructions,
    String? declineReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeamStore(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      sport: sport ?? this.sport,
      logoPath: logoPath ?? this.logoPath,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      orderDeadline: clearDeadline ? null : (orderDeadline ?? this.orderDeadline),
      status: status ?? this.status,
      packageType: packageType ?? this.packageType,
      pricingApproved: pricingApproved ?? this.pricingApproved,
      isArchived: isArchived ?? this.isArchived,
      paymentInstructions: paymentInstructions ?? this.paymentInstructions,
      declineReason: declineReason ?? this.declineReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'TeamStore($id, $name, status=$status)';
}
