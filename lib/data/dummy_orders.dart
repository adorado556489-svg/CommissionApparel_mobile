import '../models/parent_order.dart';

/// Dummy parent orders for testing order workflows.
final List<ParentOrder> dummyParentOrders = [
  // ── Order 1: Pending, placed by parent Jennifer Martinez ────────────────
  ParentOrder(
    id: 'order-1',
    teamStoreId: 'store-1',
    userId: 'user-parent-1',
    athleteFirstName: 'Carlos',
    athleteLastName: 'Martinez',
    gender: 'Mens',
    jerseyName: 'C. MARTINEZ',
    jerseyNumber: '23',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'item-1-pkg',
        name: 'Game Day Package',
        types: ['Jersey', 'Shorts'],
        sizes: {'Jersey': 'L', 'Shorts': 'M'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
        components: [
          OrderItemComponent(
            storeItemId: 'item-1-jersey',
            name: 'Riverside Basketball Jersey',
            sizes: {'Jersey': 'L'},
          ),
          OrderItemComponent(
            storeItemId: 'item-1-shorts',
            name: 'Riverside Basketball Shorts',
            sizes: {'Shorts': 'M'},
          ),
        ],
      ),
      OrderItemEntry(
        storeItemId: 'item-1-hoodie',
        name: 'Riverside Team Hoodie',
        types: ['Hoodie'],
        sizes: {'Hoodie': 'L'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
    ],
    totalRetailPrice: 150.00, // 85 (package) + 65 (hoodie)
    status: 'Pending Coach Approval',
    createdAt: DateTime(2024, 7, 1),
    updatedAt: DateTime(2024, 7, 1),
  ),

  // ── Order 2: Pending, placed by parent John Smith ───────────────────────
  ParentOrder(
    id: 'order-2',
    teamStoreId: 'store-1',
    userId: 'user-parent-2',
    athleteFirstName: 'Emily',
    athleteLastName: 'Smith',
    gender: 'Womens',
    jerseyName: 'E. SMITH',
    jerseyNumber: '7',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'item-1-pkg',
        name: 'Game Day Package',
        types: ['Jersey', 'Shorts'],
        sizes: {'Jersey': 'M', 'Shorts': 'S'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
        components: [
          OrderItemComponent(
            storeItemId: 'item-1-jersey',
            name: 'Riverside Basketball Jersey',
            sizes: {'Jersey': 'M'},
          ),
          OrderItemComponent(
            storeItemId: 'item-1-shorts',
            name: 'Riverside Basketball Shorts',
            sizes: {'Shorts': 'S'},
          ),
        ],
      ),
    ],
    totalRetailPrice: 85.00,
    status: 'Pending Coach Approval',
    createdAt: DateTime(2024, 7, 5),
    updatedAt: DateTime(2024, 7, 5),
  ),

  // ── Order 3: Batched / Submitted, from previous cycle ───────────────────
  ParentOrder(
    id: 'order-3',
    teamStoreId: 'store-1',
    userId: 'user-parent-3',
    athleteFirstName: 'Diego',
    athleteLastName: 'Garcia',
    gender: 'Mens',
    jerseyName: 'D. GARCIA',
    jerseyNumber: '11',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'item-1-pkg',
        name: 'Game Day Package',
        types: ['Jersey', 'Shorts'],
        sizes: {'Jersey': 'XL', 'Shorts': 'L'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
        components: [
          OrderItemComponent(
            storeItemId: 'item-1-jersey',
            name: 'Riverside Basketball Jersey',
            sizes: {'Jersey': 'XL'},
          ),
          OrderItemComponent(
            storeItemId: 'item-1-shorts',
            name: 'Riverside Basketball Shorts',
            sizes: {'Shorts': 'L'},
          ),
        ],
      ),
      OrderItemEntry(
        storeItemId: 'item-1-hoodie',
        name: 'Riverside Team Hoodie',
        types: ['Hoodie'],
        sizes: {'Hoodie': 'XL'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
      OrderItemEntry(
        storeItemId: 'item-1-shooting',
        name: 'Riverside Shooting Shirt',
        types: ['T-Shirt'],
        sizes: {'T-Shirt': 'L'},
        quantity: 2,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
    ],
    totalRetailPrice: 240.00, // 85 + 65 + (45 × 2)
    status: 'Submitted to Admin',
    batchId: 'batch-2024-06-001',
    createdAt: DateTime(2024, 6, 1),
    updatedAt: DateTime(2024, 6, 20),
  ),

  // ── Order 4: Direct order placed by coach ───────────────────────────────
  ParentOrder(
    id: 'order-4',
    teamStoreId: 'store-1',
    userId: null, // Direct order — no parent user
    athleteFirstName: 'Tyler',
    athleteLastName: 'Washington',
    gender: 'Mens',
    jerseyName: 'T. WASHINGTON',
    jerseyNumber: '1',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'item-1-jersey',
        name: 'Riverside Basketball Jersey',
        types: ['Jersey'],
        sizes: {'Jersey': 'M'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
    ],
    totalRetailPrice: 55.00,
    status: 'Pending Coach Approval',
    isEdited: true,
    editedBy: 'user-coach-1',
    createdAt: DateTime(2024, 7, 10),
    updatedAt: DateTime(2024, 7, 12),
  ),

  // ── Order 5: Archived completed order ───────────────────────────────────
  ParentOrder(
    id: 'order-5',
    teamStoreId: 'store-3',
    userId: 'user-parent-1',
    athleteFirstName: 'Carlos',
    athleteLastName: 'Martinez',
    gender: 'Mens',
    jerseyName: 'MARTINEZ',
    jerseyNumber: '23',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'item-1-jersey',
        name: 'Summer Camp Jersey',
        types: ['Jersey'],
        sizes: {'Jersey': 'L'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
    ],
    totalRetailPrice: 55.00,
    status: 'Submitted to Admin',
    batchId: 'batch-2024-07-001',
    isArchived: true,
    createdAt: DateTime(2024, 5, 15),
    updatedAt: DateTime(2024, 7, 20),
  ),

  // Order 6: Draft Direct Order
  ParentOrder(
    id: 'order-6',
    teamStoreId: null,
    userId: 'user-coach-1',
    athleteFirstName: 'Bulk',
    athleteLastName: 'Order',
    gender: 'Mens',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'design-bball-pkg', // Maps to designId
        name: 'Basketball Player Package',
        types: ['Jersey', 'Shorts'],
        sizes: {'Jersey': 'L', 'Shorts': 'L'},
        quantity: 5,
      ),
    ],
    totalRetailPrice: 0.0,
    status: 'Draft',
    createdAt: DateTime(2024, 7, 10),
    updatedAt: DateTime(2024, 7, 10),
  ),

  // Order 7: Submitted Direct Order Batch
  ParentOrder(
    id: 'order-7',
    teamStoreId: null,
    userId: 'user-coach-1',
    athleteFirstName: 'Tyler',
    athleteLastName: 'Washington',
    gender: 'Mens',
    itemEntries: const [
      OrderItemEntry(
        storeItemId: 'design-bball-jersey', // Maps to designId
        name: 'Basketball Jersey',
        types: ['Jersey'],
        sizes: {'Jersey': 'M'},
        quantity: 1,
        retailPrice: 40.0,
        wholesalePrice: 20.0,
      ),
    ],
    totalRetailPrice: 0.0,
    status: 'Submitted to Admin',
    batchId: 'batch-direct-1',
    createdAt: DateTime(2024, 7, 11),
    updatedAt: DateTime(2024, 7, 11),
  ),
];

// ── Convenience lookups ───────────────────────────────────────────────────

/// Orders for a specific store.
List<ParentOrder> ordersForStore(String storeId) =>
    dummyParentOrders.where((o) => o.teamStoreId == storeId).toList();

/// Orders in a specific batch.
List<ParentOrder> ordersInBatch(String batchId) =>
    dummyParentOrders.where((o) => o.batchId == batchId).toList();

/// Active (non-archived) orders.
List<ParentOrder> get activeOrders =>
    dummyParentOrders.where((o) => !o.isArchived).toList();

/// Direct orders (no parent user).
List<ParentOrder> get directOrders =>
    dummyParentOrders.where((o) => o.isDirectOrder).toList();
