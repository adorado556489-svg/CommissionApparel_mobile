/// Parent order model matching the Laravel `ParentOrder` Eloquent model.
///
/// Represents a parent's order for a specific athlete in a team store.
/// The order contains athlete info, selected items with sizes/quantities
/// in a structured [itemEntries] list, and pricing totals.
///
/// Key workflow: Orders are created by parents → approved by coaches →
/// batched (grouped by batchId) → submitted to admin for processing.
class ParentOrder {
  final String id;
  final String teamStoreId; // FK → TeamStore
  final String? userId; // FK → User (parent, null for direct orders)
  final String athleteFirstName;
  final String athleteLastName;
  final String? gender;
  final String? jerseyName; // name printed on jersey
  final String? jerseyNumber;
  final String? backpackName; // name on backpack
  final List<OrderItemEntry> itemEntries; // structured items data
  final String? specialNotes;
  final String status; // 'Pending Coach Approval', 'Submitted to Admin', etc
  final bool isEdited;
  final String? editedBy; // user ID who last edited
  final double totalRetailPrice;
  final String? batchId; // UUID grouping finalized orders
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParentOrder({
    required this.id,
    required this.teamStoreId,
    this.userId,
    required this.athleteFirstName,
    required this.athleteLastName,
    this.gender,
    this.jerseyName,
    this.jerseyNumber,
    this.backpackName,
    this.itemEntries = const [],
    this.specialNotes,
    this.status = 'Pending Coach Approval',
    this.isEdited = false,
    this.editedBy,
    this.totalRetailPrice = 0.0,
    this.batchId,
    this.isArchived = false,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Computed Properties ─────────────────────────────────────────────────

  /// Full athlete name.
  String get athleteName => '$athleteFirstName $athleteLastName';

  /// Whether this is a direct order placed by admin/coach (no parent user).
  bool get isDirectOrder => userId == null;

  /// Whether the order has been batched for submission.
  bool get isBatched => batchId != null;

  /// Whether this order is still editable (before batch submission).
  bool get isEditable =>
      status == 'Pending Coach Approval' && !isBatched && !isArchived;

  /// Total number of individual items across all entries.
  int get totalItemCount {
    int count = 0;
    for (final entry in itemEntries) {
      count += entry.quantity;
    }
    return count;
  }

  /// Recalculate total retail price from item entries and their retail prices.
  double calculateTotalRetail(Map<String, double> retailPrices) {
    double total = 0;
    for (final entry in itemEntries) {
      final price = retailPrices[entry.storeItemId] ?? 0;
      total += price * entry.quantity;
    }
    return total;
  }

  // ── Batch Financials (matching Laravel static method) ───────────────────

  /// Calculate aggregate financial summary for a batch of orders.
  ///
  /// [orders] — list of orders in the batch.
  /// [retailPrices] — map of storeItemId → retail price.
  /// [wholesalePrices] — map of storeItemId → wholesale price.
  static BatchFinancials calculateBatchFinancials({
    required List<ParentOrder> orders,
    required Map<String, double> retailPrices,
    required Map<String, double> wholesalePrices,
  }) {
    double totalSales = 0;
    double totalWholesaleCost = 0;
    int totalItemsSold = 0;

    for (final order in orders) {
      totalSales += order.totalRetailPrice;
      for (final entry in order.itemEntries) {
        final wholesale = wholesalePrices[entry.storeItemId] ?? 0;
        totalWholesaleCost += wholesale * entry.quantity;
        totalItemsSold += entry.quantity;
      }
    }

    return BatchFinancials(
      totalSales: totalSales,
      totalWholesaleCost: totalWholesaleCost,
      netProceeds: totalSales - totalWholesaleCost,
      totalItemsSold: totalItemsSold,
      orderCount: orders.length,
      averageOrderValue:
          orders.isEmpty ? 0 : totalSales / orders.length,
    );
  }

  ParentOrder copyWith({
    String? id,
    String? teamStoreId,
    String? userId,
    String? athleteFirstName,
    String? athleteLastName,
    String? gender,
    String? jerseyName,
    String? jerseyNumber,
    String? backpackName,
    List<OrderItemEntry>? itemEntries,
    String? specialNotes,
    String? status,
    bool? isEdited,
    String? editedBy,
    double? totalRetailPrice,
    String? batchId,
    bool? isArchived,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentOrder(
      id: id ?? this.id,
      teamStoreId: teamStoreId ?? this.teamStoreId,
      userId: userId ?? this.userId,
      athleteFirstName: athleteFirstName ?? this.athleteFirstName,
      athleteLastName: athleteLastName ?? this.athleteLastName,
      gender: gender ?? this.gender,
      jerseyName: jerseyName ?? this.jerseyName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      backpackName: backpackName ?? this.backpackName,
      itemEntries: itemEntries ?? this.itemEntries,
      specialNotes: specialNotes ?? this.specialNotes,
      status: status ?? this.status,
      isEdited: isEdited ?? this.isEdited,
      editedBy: editedBy ?? this.editedBy,
      totalRetailPrice: totalRetailPrice ?? this.totalRetailPrice,
      batchId: batchId ?? this.batchId,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ParentOrder($id, $athleteName, status=$status, \$$totalRetailPrice)';
}

/// A single item entry in a parent order.
///
/// Maps to one element in the Laravel `items_json` array.
/// For packages, [components] contains the sub-component items.
class OrderItemEntry {
  final String storeItemId; // FK → StoreItem
  final String name; // denormalized item name
  final List<String> types; // garment types: ['Jersey', 'Shorts']
  final Map<String, String> sizes; // type → selected size, e.g. {'Jersey': 'L'}
  final int quantity;
  final List<OrderItemComponent> components; // sub-items for packages

  const OrderItemEntry({
    required this.storeItemId,
    required this.name,
    this.types = const [],
    this.sizes = const {},
    this.quantity = 1,
    this.components = const [],
  });

  /// Whether this entry is for a package item with components.
  bool get isPackage => components.isNotEmpty;
}

/// A sub-component within a package order item entry.
///
/// Represents individual garments within a package (e.g., the "Shorts"
/// component within a "Basketball Package" entry).
class OrderItemComponent {
  final String storeItemId; // FK → StoreItem (component)
  final String name; // e.g. 'Shorts'
  final Map<String, String> sizes; // type → size

  const OrderItemComponent({
    required this.storeItemId,
    required this.name,
    this.sizes = const {},
  });
}

/// Aggregate financial summary for a batch of orders.
///
/// Returned by [ParentOrder.calculateBatchFinancials].
class BatchFinancials {
  final double totalSales;
  final double totalWholesaleCost;
  final double netProceeds;
  final int totalItemsSold;
  final int orderCount;
  final double averageOrderValue;

  const BatchFinancials({
    required this.totalSales,
    required this.totalWholesaleCost,
    required this.netProceeds,
    required this.totalItemsSold,
    required this.orderCount,
    required this.averageOrderValue,
  });

  @override
  String toString() =>
      'BatchFinancials(sales=\$$totalSales, net=\$$netProceeds, '
      'items=$totalItemsSold, orders=$orderCount)';
}
