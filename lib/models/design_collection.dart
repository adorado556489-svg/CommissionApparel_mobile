/// Design collection model matching the Laravel `DesignCollection` model.
///
/// Groups related [DesignCatalog] items by collection (e.g., "Basketball",
/// "Football"). Admin manages collections via the catalog management UI.
class DesignCollection {
  final String id;
  final String name;
  final String? imagePath;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DesignCollection({
    required this.id,
    required this.name,
    this.imagePath,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  DesignCollection copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DesignCollection(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'DesignCollection($id, $name)';
}
