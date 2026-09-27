import 'dart:io';

void replace(String file, String from, String to) {
  var f = File(file);
  var s = f.readAsStringSync();
  f.writeAsStringSync(s.replaceAll(from, to));
}

void main() {
  replace('lib/services/order_service.dart',
    "    } catch (_) {\n      unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'OrderService');\n    }"
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {\n      draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'OrderService');\n    }"
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {\n      batchOrders = dummyParentOrders.where((o) => o.userId == currentUser.id && o.batchId == batchId).toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'OrderService');\n    }"
  );
  replace('lib/services/order_service.dart',
    "    try {\n      final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n      if (storeIndex != -1) {\n        return dummyTeamStores[storeIndex].userId == currentUser.id;\n      }\n    } catch (_) {}\n    return false;",
    "    return false;"
  );
  replace('lib/services/order_service.dart',
    "    final storeIndex = dummyTeamStores.indexWhere((s) => s.id == storeId);\n    if (storeIndex != -1) {\n      return dummyTeamStores[storeIndex].userId == currentUser.id;\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    dummyParentOrders.add(newOrder);",
    ""
  );
  replace('lib/services/order_service.dart',
    "    try {\n      return dummyParentOrders.firstWhere((o) => o.id == orderId);\n    } catch (_) {\n      return null;\n    }",
    "    return null;"
  );
  replace('lib/services/order_service.dart',
    "      } catch (e) { _handleError(e, \"OrderService\");  }\n      return dummyParentOrders.toList();",
    "        return [];\n      } catch (e) { _handleError(e, \"OrderService\"); return []; }"
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.userId == coachId && o.status == 'Draft') {\n        dummyParentOrders[i] = o.copyWith(status: 'Submitted to Admin', batchId: batchId, updatedAt: DateTime.now());\n      }\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {\n      return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();\n    }",
    "    } catch (e) {\n      _handleError(e, 'OrderService'); return [];\n    }"
  );
  replace('lib/services/order_service.dart',
    "    try {\n      dummyParentOrders.add(newOrder);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {}\n    return dummyParentOrders.where((o) => o.status == 'Submitted to Admin').toList();",
    "    } catch (e) {\n      _handleError(e, 'OrderService'); return [];\n    }"
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.batchId == batchId && o.status == 'Submitted to Admin') {\n        dummyParentOrders[i] = o.copyWith(\n          status: 'Processing',\n          isArchived: true,\n          updatedAt: DateTime.now(),\n        );\n      }\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    } catch (_) {}\n    return dummyParentOrders.where((o) => o.batchId == batchId).toList();",
    "    } catch (e) {\n      _handleError(e, 'OrderService'); return [];\n    }"
  );
  replace('lib/services/order_service.dart',
    "    for (var i = 0; i < dummyParentOrders.length; i++) {\n      final o = dummyParentOrders[i];\n      if (o.batchId == batchId && o.status == 'Submitted to Admin') {\n        dummyParentOrders[i] = o.copyWith(\n          status: 'Processing',\n          isArchived: true,\n          updatedAt: DateTime.now(),\n        );\n      }\n    }",
    ""
  ); // dup
  replace('lib/services/order_service.dart',
    "    try {\n      final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == order.id);\n      if (dummyIndex != -1) dummyParentOrders[dummyIndex] = order;\n    } catch (_) {}",
    ""
  );
  replace('lib/services/order_service.dart',
    "    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == orderId);\n    if (dummyIndex != -1) dummyParentOrders.removeAt(dummyIndex);",
    ""
  );
  replace('lib/services/order_service.dart',
    "    try {\n      dummyParentOrders.removeWhere((o) => o.id == orderId);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/order_service.dart',
    "    final dummyIndex = dummyParentOrders.indexWhere((o) => o.id == updatedOrder.id);\n    if (dummyIndex != -1) {\n      dummyParentOrders[dummyIndex] = newOrder;\n    }",
    ""
  );
  replace('lib/services/order_service.dart',
    "    dummyParentOrders.add(order); // fallback",
    ""
  );
  
  // Wipe imports
  replace('lib/services/order_service.dart', "import '../data/dummy_orders.dart';", "");
  replace('lib/services/order_service.dart', "import '../data/dummy_stores.dart';", "");
}
