
import '../models/parent_order.dart';
import '../models/user.dart';
import '../data/dummy_orders.dart';
import '../data/dummy_stores.dart';


class OrderService {
  

  /// Coach direct order drafting (bulk or individual)
  static String? submitDirectOrder({
    required User currentUser,
    required String orderType, // 'item' (bulk) or 'person'
    String? athleteFirstName,
    String? athleteLastName,
    String? gender,
    String? jerseyName,
    String? jerseyNumber,
    String? backpackName,
    required List<OrderItemEntry> items,
  }) {
    if (items.isEmpty) {
      return 'Please select at least one item before submitting.';
    }

    final firstName = orderType == 'item' ? 'Bulk' : (athleteFirstName ?? 'Direct');
    final lastName = orderType == 'item' ? 'Order' : (athleteLastName ?? 'Order');

    final newOrder = ParentOrder(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + dummyParentOrders.length.toString(),
      teamStoreId: null, // Indicates direct order
      userId: currentUser.id, // Direct order maps to coach
      athleteFirstName: firstName,
      athleteLastName: lastName,
      gender: gender,
      jerseyName: jerseyName,
      jerseyNumber: jerseyNumber,
      backpackName: backpackName,
      itemEntries: items,
      totalRetailPrice: 0.0, // Direct orders use wholesale
      status: 'Draft',
      isEdited: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    dummyParentOrders.add(newOrder);
    return null; // success
  }

  /// Finalize all draft direct orders for a coach into a batch.
  static String? finalizeDirectOrders(User currentUser) {
    final draftOrders = dummyParentOrders.where(
      (o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft'
    ).toList();

    if (draftOrders.isEmpty) {
      return 'You have no draft orders to submit.';
    }

    final batchId = DateTime.now().millisecondsSinceEpoch.toString() + '_' + dummyParentOrders.length.toString();

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft') {
        dummyParentOrders[i] = o.copyWith(
          status: 'Submitted to Admin',
          batchId: batchId,
          updatedAt: DateTime.now(),
        );
      }
    }

    return null; // success
  }

  /// Archive a direct order batch.
  static String? archiveDirectOrderBatch(User currentUser, String batchId) {
    if (currentUser.role != UserRole.coach) return 'Unauthorized';

    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.userId == currentUser.id && o.batchId == batchId) {
        dummyParentOrders[i] = o.copyWith(
          isArchived: true,
          updatedAt: DateTime.now(),
        );
      }
    }
    return null;
  }

  /// Delete an order (store-linked or direct).
  static String? deleteOrder(User currentUser, String orderId) {
    final index = dummyParentOrders.indexWhere((o) => o.id == orderId);
    if (index == -1) return 'Order not found';

    final order = dummyParentOrders[index];

    if (currentUser.role != UserRole.admin) {
      if (order.teamStoreId != null) {
        final storeIndex = dummyTeamStores.indexWhere((s) => s.id == order.teamStoreId);
        if (storeIndex == -1) return 'Store not found';
        if (dummyTeamStores[storeIndex].userId != currentUser.id) return 'Unauthorized';
      } else {
        if (order.userId != currentUser.id) return 'Unauthorized';
      }
    }

    dummyParentOrders.removeAt(index);
    return null;
  }

  /// Update an order (store-linked or direct).
  static String? updateOrder(User currentUser, ParentOrder updatedOrder) {
    final index = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);
    if (index == -1) return 'Order not found';

    final existingOrder = dummyParentOrders[index];

    if (existingOrder.teamStoreId == null && existingOrder.userId != currentUser.id && currentUser.role != UserRole.admin) {
      return 'Unauthorized';
    }

    dummyParentOrders[index] = updatedOrder.copyWith(
      isEdited: true,
      editedBy: currentUser.id,
      updatedAt: DateTime.now(),
    );

    return null;
  }
}

