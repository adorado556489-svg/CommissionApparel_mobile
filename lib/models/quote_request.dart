/// Quote request model matching the Laravel `QuoteRequest` Eloquent model.
///
/// Submitted by visitors on the public landing page. Admin reviews and
/// responds to quote requests.
class QuoteRequest {
  final String id;
  final String firstName;
  final String lastName;
  final String? positionTitle;
  final String email;
  final String? phone;
  final String organizationName;
  final String? apparelCategory;
  final String? estimatedQuantity;
  final String? packageType;
  final DateTime? targetDeliveryDate;
  final String? designVision;
  final String status; // 'new', 'addressed'
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuoteRequest({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.positionTitle,
    required this.email,
    this.phone,
    required this.organizationName,
    this.apparelCategory,
    this.estimatedQuantity,
    this.packageType,
    this.targetDeliveryDate,
    this.designVision,
    this.status = 'new',
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  bool get isNew => status == 'new';
  bool get isAddressed => status == 'addressed';

  QuoteRequest copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? positionTitle,
    String? email,
    String? phone,
    String? organizationName,
    String? apparelCategory,
    String? estimatedQuantity,
    String? packageType,
    DateTime? targetDeliveryDate,
    String? designVision,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuoteRequest(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      positionTitle: positionTitle ?? this.positionTitle,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      organizationName: organizationName ?? this.organizationName,
      apparelCategory: apparelCategory ?? this.apparelCategory,
      estimatedQuantity: estimatedQuantity ?? this.estimatedQuantity,
      packageType: packageType ?? this.packageType,
      targetDeliveryDate: targetDeliveryDate ?? this.targetDeliveryDate,
      designVision: designVision ?? this.designVision,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
