import 'dart:io';

void main() {
  final file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // 1. finalizeDirectOrders
  content = content.replaceAll(
    "draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();",
    "if (qs.docs.isEmpty) { draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList(); } else { draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList(); }"
  );

  // 2. submitStoreOrdersToAdmin
  content = content.replaceAll(
    "unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();",
    "if (qs.docs.isEmpty) { unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList(); } else { unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList(); }"
  );

  // 3. archiveDirectOrderBatch
  content = content.replaceAll(
    "batched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();",
    "if (qs.docs.isEmpty) { batched = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.batchId == batchId && !o.isArchived).toList(); } else { batched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList(); }"
  );

  // 4. getDirectOrdersForCoach
  content = content.replaceAll(
    "return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();",
    "if (qs.docs.isEmpty) { return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList(); } else { return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList(); }"
  );

  file.writeAsStringSync(content);
}
