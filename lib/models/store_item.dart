import 'package:cloud_firestore/cloud_firestore.dart';

/// Store item model matching the Laravel StoreItem Eloquent model.
///
/// Represents a product in a team store, linked to a design catalog entry.
/// Coaches set retail prices (must be >= wholesale). Items can be packages
/// containing sub-component items.
class StoreItem {
  final String id;
  final String teamStoreId; // FK -> TeamStore
  final String? designCatalogId; // FK -> DesignCatalog
  final String? collectionId; // FK -> DesignCollection (Coach custom collection)
  final String name;
  final List<String> types; // garment types, e.g. ['Jersey', 'Shorts']
  final String? imageUrl; // legacy single image
  final List<String> imagePaths; // multiple images
  final double wholesalePrice;
  final double retailPrice;
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
    this.types = const [],
    this.imageUrl,
    this.imagePaths = const [],
    this.wholesalePrice = 0.0,
    this.retailPrice = 0.0,
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
      types: List<String>.from(data['types'] ?? []),
      imageUrl: data['imageUrl'],
      imagePaths: List<String>.from(data['imagePaths'] ?? []),
      wholesalePrice: (data['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
      retailPrice: (data['retailPrice'] as num?)?.toDouble() ?? 0.0,
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
      'types': types,
      'imageUrl': imageUrl,
      'imagePaths': imagePaths,
      'wholesalePrice': wholesalePrice,
      'retailPrice': retailPrice,
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

  StoreItem copyWith({
    String? id,
    String? teamStoreId,
    String? designCatalogId,
    String? collectionId,
    String? name,
    List<String>? types,
    String? imageUrl,
    List<String>? imagePaths,
    double? wholesalePrice,
    double? retailPrice,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? componentIds,
  }) {
    return StoreItem(
      id: id ?? this.id,
      teamStoreId: teamStoreId ?? this.teamStoreId,
      designCatalogId: designCatalogId ?? this.designCatalogId,
      collectionId: collectionId ?? this.collectionId,
      name: name ?? this.name,
      types: types ?? this.types,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePaths: imagePaths ?? this.imagePaths,
      wholesalePrice: wholesalePrice ?? this.wholesalePrice,
      retailPrice: retailPrice ?? this.retailPrice,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      componentIds: componentIds ?? this.componentIds,
    );
  }

  @override
  String toString() => 'StoreItem($id, $name, \$$retailPrice)';
}
