import 'package:cloud_firestore/cloud_firestore.dart';

/// A product in a team store, created by the coach from an admin blank
/// ([designCatalogId]). The coach controls name, design image, retail price,
/// description and collection; [wholesalePrice] (base cost) is copied from
/// the blank and is not editable by the coach.
class StoreItem {
  final String id;
  final String teamStoreId; // FK -> TeamStore
  final String? designCatalogId; // FK -> DesignCatalog (admin blank)
  final String? collectionId; // FK -> DesignCollection (coach collection)
  final String name;
  final String? description;
  final List<String> types; // garment types, e.g. ['Jersey', 'Shorts']
  final String? imageUrl; // legacy single image
  final List<String> imagePaths; // design/product images (HTTPS)
  final double wholesalePrice; // base cost (platform)
  final double retailPrice; // coach price
  final bool hasNameField; // personalised name printed
  final bool hasNumberField; // personalised number printed
  final List<String> availableSizes; // empty = default size chart
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Package support: IDs of component StoreItems in this package
  final List<String> componentIds;

  const StoreItem({
    required this.id,
    required this.teamStoreId,
    this.designCatalogId,
    this.collectionId,
    required this.name,
    this.description,
    this.types = const [],
    this.imageUrl,
    this.imagePaths = const [],
    this.wholesalePrice = 0.0,
    this.retailPrice = 0.0,
    this.hasNameField = false,
    this.hasNumberField = false,
    this.availableSizes = const [],
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
    this.componentIds = const [],
  });

  factory StoreItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StoreItem(
      id: doc.id,
      teamStoreId: data['teamStoreId'] ?? '',
      designCatalogId: data['designCatalogId'],
      collectionId: data['collectionId'],
      name: data['name'] ?? '',
      description: data['description'],
      types: List<String>.from(data['types'] ?? []),
      imageUrl: data['imageUrl'],
      imagePaths: List<String>.from(data['imagePaths'] ?? []),
      wholesalePrice: (data['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (data['retailPrice'] as num?)?.toDouble() ?? 0.0,
      hasNameField: data['hasNameField'] ?? false,
      hasNumberField: data['hasNumberField'] ?? false,
      availableSizes: List<String>.from(data['availableSizes'] ?? []),
      sortOrder: (data['sortOrder'] as num?)?.toInt() ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      componentIds: List<String>.from(data['componentIds'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamStoreId': teamStoreId,
      'designCatalogId': designCatalogId,
      'collectionId': collectionId,
      'name': name,
      'description': description,
      'types': types,
      'imageUrl': imageUrl,
      'imagePaths': imagePaths,
      'wholesalePrice': wholesalePrice,
      'retailPrice': retailPrice,
      'hasNameField': hasNameField,
      'hasNumberField': hasNumberField,
      'availableSizes': availableSizes,
      'sortOrder': sortOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'componentIds': componentIds,
    };
  }

  // Computed Properties

  bool get isPackage => componentIds.isNotEmpty;

  String? get displayImage =>
      imagePaths.isNotEmpty ? imagePaths.first : imageUrl;

  double get marginPerUnit => retailPrice - wholesalePrice;

  bool get hasValidPricing => retailPrice >= wholesalePrice;

  /// Whether the order form must collect a personalisation for this item.
  bool get needsPersonalisation => hasNameField || hasNumberField;

  StoreItem copyWith({
    String? id,
    String? teamStoreId,
    String? designCatalogId,
    String? collectionId,
    bool clearCollection = false,
    String? name,
    String? description,
    List<String>? types,
    String? imageUrl,
    List<String>? imagePaths,
    double? wholesalePrice,
    double? retailPrice,
    bool? hasNameField,
    bool? hasNumberField,
    List<String>? availableSizes,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? componentIds,
  }) {
    return StoreItem(
      id: id ?? this.id,
      teamStoreId: teamStoreId ?? this.teamStoreId,
      designCatalogId: designCatalogId ?? this.designCatalogId,
      collectionId: clearCollection ? null : (collectionId ?? this.collectionId),
      name: name ?? this.name,
      description: description ?? this.description,
      types: types ?? this.types,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePaths: imagePaths ?? this.imagePaths,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      hasNameField: hasNameField ?? this.hasNameField,
      hasNumberField: hasNumberField ?? this.hasNumberField,
      availableSizes: availableSizes ?? this.availableSizes,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      componentIds: componentIds ?? this.componentIds,
    );
  }

  @override
  String toString() => 'StoreItem($id, $name, \$$retailPrice)';
}
