/// Testimonial model matching the Laravel `Testimonial` Eloquent model.
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
