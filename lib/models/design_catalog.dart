import 'package:cloud_firestore/cloud_firestore.dart';

/// Admin-managed blank product ("blank canvas") with a platform base cost.
/// Coaches turn blanks into [StoreItem]s by adding their design and price.
///
/// [coachId] is a legacy field: master blanks have `coachId == null`.
class DesignCatalog {
  final String id;
  final String? coachId; // legacy: non-null = coach-owned design
  final String? designCollectionId; // legacy grouping
  final String name;
  final String? description;
  final String? sport;
  final String? type; // legacy single type
  final List<String> types; // garment types: ['Jersey', 'Shorts']
  final String category; // individual, package_a, package_b, package_c
  final String? imageUrl; // legacy single image
  final List<String> imagePaths; // blank mockup images
  final double wholesalePrice; // base cost
  final bool hasNameField; // supports printed player name
  final bool hasNumberField; // supports printed player number
  final List<String> availableSizes; // empty = full default chart
  final bool isActive; // inactive blanks are hidden from coaches
  final String? notes;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DesignCatalog({
    this.coachId,
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
    this.availableSizes = const [],
    this.isActive = true,
    this.notes,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DesignCatalog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return DesignCatalog(
      id: doc.id,
      coachId: data['coachId'],
      designCollectionId: data['designCollectionId'],
      name: data['name'] ?? '',
      description: data['description'],
      sport: data['sport'],
      type: data['type'],
      types: List<String>.from(data['types'] ?? []),
      category: data['category'] ?? 'individual',
      imageUrl: data['imageUrl'],
      imagePaths: List<String>.from(data['imagePaths'] ?? []),
      wholesalePrice: (data['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
      hasNameField: data['hasNameField'] ?? false,
      hasNumberField: data['hasNumberField'] ?? false,
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      isActive: data['isActive'] ?? true,
      notes: data['notes'],
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'coachId': coachId,
      'designCollectionId': designCollectionId,
      'name': name,
      'description': description,
      'sport': sport,
      'type': type,
      'types': types,
      'category': category,
      'imageUrl': imageUrl,
      'imagePaths': imagePaths,
      'wholesalePrice': wholesalePrice,
      'hasNameField': hasNameField,
      'hasNumberField': hasNumberField,
      'availableSizes': availableSizes,
      'isActive': isActive,
      'notes': notes,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Computed Properties

  bool get isMasterBlank => coachId == null;

  bool get isPackage => category != 'individual';

  String? get displayImage =>
      imagePaths.isNotEmpty ? imagePaths.first : imageUrl;

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

  String get typeLabel {
    if (types.isNotEmpty) return types.join(', ');
    return type ?? 'Apparel';
  }

  /// Sizes offered for this blank (falls back to the full chart).
  List<String> get sizes => availableSizes.isNotEmpty ? availableSizes : allSizes();

  static List<String> garmentTypes() => const [
        'Jersey', 'Shorts', 'Hoodie', 'T-Shirt', 'Jacket', 'Pants',
        'Warmup Top', 'Warmup Bottom', 'Backpack', 'Accessory',
      ];

  static List<String> sizedTypes() => [
    'Jersey',
    'Shorts',
    'Hoodie',
    'T-Shirt',
    'Jacket',
    'Pants',
  ];

  static Map<String, List<String>> sizeChart() => {
    'Youth': ['YS', 'YM', 'YL'],
    'Adult': ['XS', 'S', 'M', 'L', 'XL', '2XL', '3XL'],
  };

  static List<String> allSizes() => [
    'YS', 'YM', 'YL', 'XS', 'S', 'M', 'L', 'XL', '2XL', '3XL',
  ];

  /// Maps any gender/division label (e.g. 'Mens', 'Womens', 'Boys', 'Youth')
  /// to a size-chart group. Never returns null, so callers can't crash.
  static String sizeGroupFor(String? gender) {
    final g = (gender ?? '').toLowerCase();
    const youthMarkers = ['youth', 'boy', 'girl', 'kid', 'child'];
    return youthMarkers.any(g.contains) ? 'Youth' : 'Adult';
  }

  /// Sizes for a gender/division, intersected with an item's offered sizes
  /// (if any). Falls back to the group chart when the intersection is empty.
  static List<String> sizesFor(String? gender, {List<String> offered = const []}) {
    final group = sizeChart()[sizeGroupFor(gender)]!;
    if (offered.isEmpty) return group;
    final filtered = group.where(offered.contains).toList();
    return filtered.isEmpty ? offered : filtered;
  }

  DesignCatalog copyWith({
    String? id,
    String? coachId,
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
    List<String>? availableSizes,
    bool? isActive,
    String? notes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool clearCollectionId = false,
  }) {
    return DesignCatalog(
      id: id ?? this.id,
      coachId: coachId ?? this.coachId,
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
      availableSizes: availableSizes ?? this.availableSizes,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() => 'DesignCatalog($id, $name, $category)';
}
