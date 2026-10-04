import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants/statuses.dart';

/// A parent's order for one athlete in a team store.
///
/// Workflow: placed (Pending) -> coach marks paid -> coach submits master
/// order (Submitted, batched by [batchId]) -> admin moves through
/// In Production -> Shipped -> Delivered. Every transition is appended to
/// [statusHistory].
class ParentOrder {
  final String id;
  final String? teamStoreId; // FK -> TeamStore
  final String? storeName; // denormalised for order history
  final String? userId; // FK -> User (parent)
  final String athleteFirstName;
  final String athleteLastName;
  final String? gender;
  final String? jerseyName; // name printed on jersey
  final String? jerseyNumber;
  final String? backpackName; // legacy
  final String? contactPhone; // parent contact for the coach
  final List<OrderItemEntry> itemEntries; // structured items data
  final String? specialNotes;
  final String status; // see OrderStatus
  final List<StatusEvent> statusHistory;
  final String? trackingNumber;
  final bool isEdited;
  final String? editedBy; // user ID who last edited
  final double totalRetailPrice;
  final String? batchId; // groups orders of one master order
  final bool isArchived;
  final bool isPaid; // coach has collected payment
  final DateTime createdAt;
  final DateTime updatedAt;

  const ParentOrder({
    required this.id,
    this.teamStoreId,
    this.storeName,
    this.userId,
    required this.athleteFirstName,
    required this.athleteLastName,
    this.gender,
    this.jerseyName,
    this.jerseyNumber,
    this.backpackName,
    this.contactPhone,
    this.itemEntries = const [],
    this.specialNotes,
    this.status = OrderStatus.pending,
    this.statusHistory = const [],
    this.trackingNumber,
    this.isEdited = false,
    this.editedBy,
    this.totalRetailPrice = 0.0,
    this.batchId,
    this.isArchived = false,
    this.isPaid = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ParentOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ParentOrder(
      id: doc.id,
      teamStoreId: data['teamStoreId'],
      storeName: data['storeName'],
      userId: data['userId'],
      athleteFirstName: data['athleteFirstName'] ?? '',
      athleteLastName: data['athleteLastName'] ?? '',
      gender: data['gender'],
      jerseyName: data['jerseyName'],
      jerseyNumber: data['jerseyNumber'],
      backpackName: data['backpackName'],
      contactPhone: data['contactPhone'],
      itemEntries: (data['itemEntries'] as List<dynamic>? ?? [])
          .map((item) => OrderItemEntry.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList(),
      specialNotes: data['specialNotes'],
      status: data['status'] ?? OrderStatus.pending,
      statusHistory: (data['statusHistory'] as List<dynamic>? ?? [])
          .map((e) => StatusEvent.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      trackingNumber: data['trackingNumber'],
      isEdited: data['isEdited'] ?? false,
      editedBy: data['editedBy'],
      totalRetailPrice: (data['totalRetailPrice'] as num?)?.toDouble() ?? 0.0,
      batchId: data['batchId'],
      isArchived: data['isArchived'] ?? false,
      isPaid: data['isPaid'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'teamStoreId': teamStoreId,
      'storeName': storeName,
      'userId': userId,
      'athleteFirstName': athleteFirstName,
      'athleteLastName': athleteLastName,
      'gender': gender,
      'jerseyName': jerseyName,
      'jerseyNumber': jerseyNumber,
      'backpackName': backpackName,
      'contactPhone': contactPhone,
      'itemEntries': itemEntries.map((e) => e.toMap()).toList(),
      'specialNotes': specialNotes,
      'status': status,
      'statusHistory': statusHistory.map((e) => e.toMap()).toList(),
      'trackingNumber': trackingNumber,
      'isEdited': isEdited,
      'editedBy': editedBy,
      'totalRetailPrice': totalRetailPrice,
      'batchId': batchId,
      'isArchived': isArchived,
      'isPaid': isPaid,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // ---- Computed -----------------------------------------------------------

  String get athleteName => '$athleteFirstName $athleteLastName';

  bool get isDirectOrder => teamStoreId == null;

  bool get isBatched => batchId != null;

  bool get isCancelled => status == OrderStatus.cancelled;

  bool get isEditable =>
      status == OrderStatus.pending && !isBatched && !isArchived;

  /// Parent may cancel only before the coach has collected payment.
  bool get isCancellable => isEditable && !isPaid;

  String get statusLabel => OrderStatus.label(status);

  int get totalItemCount =>
      itemEntries.fold(0, (sum, entry) => sum + entry.quantity);

  /// Retail total recomputed from immutable line snapshots.
  double get snapshotRetailTotal =>
      itemEntries.fold(0.0, (sum, e) => sum + e.retailPrice * e.quantity);

  /// Platform base-cost total from immutable line snapshots.
  double get snapshotBaseTotal =>
      itemEntries.fold(0.0, (sum, e) => sum + e.wholesalePrice * e.quantity);

  /// Best available retail total (snapshots first, stored total as fallback).
  double get effectiveRetailTotal =>
      snapshotRetailTotal > 0 ? snapshotRetailTotal : totalRetailPrice;

  /// Coach earnings for this order: retail - base cost.
  double get coachEarnings => effectiveRetailTotal - snapshotBaseTotal;

  double calculateTotalRetail(Map<String, double> retailPrices) {
    double total = 0;
    for (final entry in itemEntries) {
      final price = retailPrices[entry.storeItemId] ?? 0;
      total += price * entry.quantity;
    }
    return total;
  }

  /// Aggregates financials for a set of orders using the price snapshots
  /// stored on each order line (immune to later price edits).
  static BatchFinancials calculateBatchFinancials({
    required List<ParentOrder> orders,
    Map<String, double>? retailPrices, // Legacy fallback
    Map<String, double>? wholesalePrices, // Legacy fallback
  }) {
    double totalSales = 0;
    double totalWholesaleCost = 0;
    int totalItemsSold = 0;

    final counted = orders.where((o) => !o.isCancelled).toList();
    for (final order in counted) {
      totalSales += order.effectiveRetailTotal;
      for (final entry in order.itemEntries) {
        final wholesale = entry.wholesalePrice > 0
            ? entry.wholesalePrice
            : (wholesalePrices?[entry.storeItemId] ?? 0);
        totalWholesaleCost += wholesale * entry.quantity;
        totalItemsSold += entry.quantity;
      }
    }

    return BatchFinancials(
      totalSales: totalSales,
      totalWholesaleCost: totalWholesaleCost,
      netProceeds: totalSales - totalWholesaleCost,
      totalItemsSold: totalItemsSold,
      orderCount: counted.length,
      averageOrderValue: counted.isEmpty ? 0 : totalSales / counted.length,
    );
  }

  ParentOrder copyWith({
    String? id,
    String? teamStoreId,
    String? storeName,
    String? userId,
    String? athleteFirstName,
    String? athleteLastName,
    String? gender,
    String? jerseyName,
    String? jerseyNumber,
    String? backpackName,
    String? contactPhone,
    List<OrderItemEntry>? itemEntries,
    String? specialNotes,
    String? status,
    List<StatusEvent>? statusHistory,
    String? trackingNumber,
    bool? isEdited,
    String? editedBy,
    double? totalRetailPrice,
    String? batchId,
    bool clearBatchId = false,
    bool? isArchived,
    bool? isPaid,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ParentOrder(
      id: id ?? this.id,
      teamStoreId: teamStoreId ?? this.teamStoreId,
      storeName: storeName ?? this.storeName,
      userId: userId ?? this.userId,
      athleteFirstName: athleteFirstName ?? this.athleteFirstName,
      athleteLastName: athleteLastName ?? this.athleteLastName,
      gender: gender ?? this.gender,
      jerseyName: jerseyName ?? this.jerseyName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      backpackName: backpackName ?? this.backpackName,
      contactPhone: contactPhone ?? this.contactPhone,
      itemEntries: itemEntries ?? this.itemEntries,
      specialNotes: specialNotes ?? this.specialNotes,
      status: status ?? this.status,
      statusHistory: statusHistory ?? this.statusHistory,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      isEdited: isEdited ?? this.isEdited,
      editedBy: editedBy ?? this.editedBy,
      totalRetailPrice: totalRetailPrice ?? this.totalRetailPrice,
      batchId: clearBatchId ? null : (batchId ?? this.batchId),
      isArchived: isArchived ?? this.isArchived,
      isPaid: isPaid ?? this.isPaid,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'ParentOrder($id, $athleteName, status=$status, \$$totalRetailPrice)';
}

/// One entry of an order's status timeline.
class StatusEvent {
  final String status;
  final DateTime at;
  final String? by; // user id
  final String? note;

  const StatusEvent({required this.status, required this.at, this.by, this.note});

  factory StatusEvent.fromMap(Map<String, dynamic> map) => StatusEvent(
        status: map['status'] ?? '',
        at: (map['at'] as Timestamp?)?.toDate() ?? DateTime.now(),
        by: map['by'],
        note: map['note'],
      );

  Map<String, dynamic> toMap() => {
        'status': status,
        'at': Timestamp.fromDate(at),
        'by': by,
        'note': note,
      };
}

/// A single item entry in a parent order.
///
/// [retailPrice] and [wholesalePrice] are immutable snapshots taken at order
/// time so later price edits never change historical totals.
/// For packages, [components] contains the sub-component items.
class OrderItemEntry {
  final String storeItemId; // FK -> StoreItem
  final String name; // denormalized item name
  final List<String> types; // garment types: ['Jersey', 'Shorts']
  final Map<String, String> sizes; // type -> selected size, e.g. {'Jersey': 'L'}
  final int quantity;
  final double retailPrice;
  final double wholesalePrice;
  final String? imageUrl; // denormalized thumbnail
  final List<OrderItemComponent> components; // sub-items for packages

  const OrderItemEntry({
    required this.storeItemId,
    required this.name,
    this.types = const [],
    this.sizes = const {},
    this.quantity = 1,
    this.retailPrice = 0.0,
    this.wholesalePrice = 0.0,
    this.imageUrl,
    this.components = const [],
  });

  factory OrderItemEntry.fromMap(Map<String, dynamic> map) {
    return OrderItemEntry(
      storeItemId: map['storeItemId'] ?? '',
      name: map['name'] ?? '',
      types: List<String>.from(map['types'] ?? []),
      sizes: Map<String, String>.from(map['sizes'] ?? {}),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      retailPrice: (map['retailPrice'] as num?)?.toDouble() ?? 0.0,
      wholesalePrice: (map['wholesalePrice'] as num?)?.toDouble() ?? 0.0,
      imageUrl: map['imageUrl'],
      components: (map['components'] as List<dynamic>? ?? [])
          .map((c) => OrderItemComponent.fromMap(Map<String, dynamic>.from(c as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeItemId': storeItemId,
      'name': name,
      'types': types,
      'sizes': sizes,
      'quantity': quantity,
      'retailPrice': retailPrice,
      'wholesalePrice': wholesalePrice,
      'imageUrl': imageUrl,
      'components': components.map((c) => c.toMap()).toList(),
    };
  }

  bool get isPackage => components.isNotEmpty;

  double get lineTotal => retailPrice * quantity;

  String get sizeSummary =>
      sizes.entries.map((e) => sizes.length == 1 ? e.value : '${e.key}: ${e.value}').join(', ');
}

/// A sub-component within a package order item entry.
class OrderItemComponent {
  final String storeItemId; // FK -> StoreItem (component)
  final String name; // e.g. 'Shorts'
  final Map<String, String> sizes; // type -> size

  const OrderItemComponent({
    required this.storeItemId,
    required this.name,
    this.sizes = const {},
  });

  factory OrderItemComponent.fromMap(Map<String, dynamic> map) {
    return OrderItemComponent(
      storeItemId: map['storeItemId'] ?? '',
      name: map['name'] ?? '',
      sizes: Map<String, String>.from(map['sizes'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeItemId': storeItemId,
      'name': name,
      'sizes': sizes,
    };
  }
}

/// Aggregate financial summary for a batch of orders.
class BatchFinancials {
  final double totalSales;
  final double totalWholesaleCost; // platform revenue (base cost)
  final double netProceeds; // coach earnings
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

  static const empty = BatchFinancials(
    totalSales: 0,
    totalWholesaleCost: 0,
    netProceeds: 0,
    totalItemsSold: 0,
    orderCount: 0,
    averageOrderValue: 0,
  );

  @override
  String toString() =>
      'BatchFinancials(sales=$totalSales, base=$totalWholesaleCost, net=$netProceeds, '
      'items=$totalItemsSold, orders=$orderCount)';
}
