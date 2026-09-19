/// Store item model matching the Laravel `StoreItem` Eloquent model.
///
/// Represents a product in a team store, linked to a design catalog entry.
/// Coaches set retail prices (must be ≥ wholesale). Items can be packages
/// containing sub-component items.
class StoreItem {
  final String id;
  final String teamStoreId; // FK → TeamStore
  final String? designCatalogId; // FK → DesignCatalog
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

  // ── Computed Properties ─────────────────────────────────────────────────

  /// Whether this item is a package containing multiple sub-components.
  bool get isPackage => componentIds.isNotEmpty;

  /// The primary display image (first from imagePaths, fallback to imageUrl).
  String? get displayImage =>
      imagePaths.isNotEmpty ? imagePaths.first : imageUrl;

  /// Profit margin per unit (retail - wholesale).
  double get marginPerUnit => retailPrice - wholesalePrice;

  /// Whether the retail price is validly set (≥ wholesale).
  bool get hasValidPricing => retailPrice >= wholesalePrice;

  StoreItem copyWith({
    String? id,
    String? teamStoreId,
    String? designCatalogId,
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
