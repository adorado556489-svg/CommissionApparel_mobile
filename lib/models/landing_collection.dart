/// Landing collection model matching the Laravel `LandingCollection` model.
///
/// Represents the featured sport/category tabs shown on the public landing
/// page hero section. Admin manages these via site settings.
class LandingCollection {
  final String id;
  final String tabName;
  final String title;
  final String? description;
  final String? imagePath;
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LandingCollection({
    required this.id,
    required this.tabName,
    required this.title,
    this.description,
    this.imagePath,
    this.sortOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  LandingCollection copyWith({
    String? id,
    String? tabName,
    String? title,
    String? description,
    String? imagePath,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LandingCollection(
      id: id ?? this.id,
      tabName: tabName ?? this.tabName,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
