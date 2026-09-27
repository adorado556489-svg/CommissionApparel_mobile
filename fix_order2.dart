import 'dart:io';

void replace(String file, String from, String to) {
  var f = File(file);
  var s = f.readAsStringSync();
  f.writeAsStringSync(s.replaceAll(from, to));
}

void main() {
  replace('lib/services/order_service.dart',
    "    dummyParentOrders.add(order); // fallback",
    ""
  );
  replace('lib/services/order_service.dart',
    "    dummyParentOrders.add(newOrder);",
    ""
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.teamStoreId == storeId && o.batchId == null) {\n        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());\n      }\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft') {\n        dummyParentOrders[i] = o.copyWith(\n          status: 'Submitted to Admin',\n          batchId: batchId,\n          updatedAt: DateTime.now(),\n        );\n      }\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.userId == currentUser.id && o.batchId == batchId) {\n        dummyParentOrders[i] = o.copyWith(\n          isArchived: true,\n          updatedAt: DateTime.now(),\n        );\n      }\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);\n    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);",
    ""
  );
  replace('lib/services/order_service.dart',
    "    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);\n    if (dummyIndex != -1) {\n      dummyParentOrders[dummyIndex] = newOrder;\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n    if (storeIndex != -1) {\n      return dummyTeamStores[storeIndex].userId == currentUser.id;\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "import '../data/dummy_orders.dart';",
    ""
  );
  replace('lib/services/order_service.dart',
    "import '../data/dummy_stores.dart';",
    ""
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {\n      return dummyParentOrders.toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'OrderService.getAllOrders');\n      return [];\n    }"
  );
  replace('lib/services/order_service.dart',
    "      } catch (e) { _handleError(e, \"OrderService\");  }\n      return dummyParentOrders.toList();",
    "      } catch (e) { _handleError(e, \"OrderService\");  }\n      return [];"
  );
  replace('lib/services/order_service.dart',
    "    return dummyParentOrders.toList();",
    "    return [];"
  );
}
