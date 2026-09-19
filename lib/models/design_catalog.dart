/// Design catalog model matching the Laravel `DesignCatalog` Eloquent model.
///
/// Represents a product template in the master catalog that admin manages.
/// Coaches add catalog items to their stores as [StoreItem]s.
class DesignCatalog {
  final String id;
  final String? designCollectionId; // FK → DesignCollection
  final String name;
  final String? description;
  final String? sport;
  final String? type; // legacy single type
  final List<String> types; // garment types: ['Jersey', 'Shorts']
  final String category; // individual, package_a, package_b, package_c
  final String? imageUrl; // legacy single image
  final List<String> imagePaths; // multiple images
  final double wholesalePrice;
  final bool hasNameField; // does this item accept player name
  final bool hasNumberField; // does this item accept player number
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DesignCatalog({
    required this.id,
    this.designCollectionId,
    required this.name,
    this.description,
    this.sport,
    this.type,
    this.types = const [],
    this.category = 'individual',
    this.imageUrl,
    this.imagePaths = const [],
    this.wholesalePrice = 0.0,
    this.hasNameField = false,
    this.hasNumberField = false,
    this.notes,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Computed Properties ─────────────────────────────────────────────────

  /// Whether this is a package (bundle of multiple garment types).
  bool get isPackage => category != 'individual';

  /// The primary display image.
  String? get displayImage =>
      imagePaths.isNotEmpty ? imagePaths.first : imageUrl;

  /// Human-readable category label.
  String get categoryLabel {
    switch (category) {
      case 'package_a':
        return 'Package A';
      case 'package_b':
        return 'Package B';
      case 'package_c':
        return 'Package C';
      default:
        return 'Individual';
    }
  }

  /// Human-readable type label (from types list or legacy type field).
  String get typeLabel {
    if (types.isNotEmpty) return types.join(', ');
    return type ?? 'Apparel';
  }

  // ── Static Methods (matching Laravel DesignCatalog statics) ─────────────

  /// Garment types that require size selection in order forms.
  static List<String> sizedTypes() => [
    'Jersey',
    'Shorts',
    'Hoodie',
    'T-Shirt',
    'Jacket',
    'Pants',
  ];

  /// Size chart organized by size group.
  static Map<String, List<String>> sizeChart() => {
    'Youth': ['YS', 'YM', 'YL'],
    'Adult': ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'],
  };

  /// All available sizes in a flat list.
  static List<String> allSizes() => [
    'YS', 'YM', 'YL', 'XS', 'S', 'M', 'L', 'XL', '2XL', '3XL',
  ];

  DesignCatalog copyWith({
    String? id,
    String? designCollectionId,
    String? name,
    String? description,
    String? sport,
    String? type,
    List<String>? types,
    String? category,
    String? imageUrl,
    List<String>? imagePaths,
    double? wholesalePrice,
    bool? hasNameField,
    bool? hasNumberField,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCollectionId = false,
  }) {
    return DesignCatalog(
      id: id ?? this.id,
      designCollectionId: clearCollectionId ? null : (designCollectionId ?? this.designCollectionId),
      name: name ?? this.name,
      description: description ?? this.description,
      sport: sport ?? this.sport,
      type: type ?? this.type,
      types: types ?? this.types,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePaths: imagePaths ?? this.imagePaths,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      hasNameField: hasNameField ?? this.hasNameField,
      hasNumberField: hasNumberField ?? this.hasNumberField,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'DesignCatalog($id, $name, $category)';
}


