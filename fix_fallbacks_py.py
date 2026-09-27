import re

with open('lib/services/order_service.dart', 'r') as f:
    content = f.read()

# 1. finalizeDirectOrders
content = re.sub(
    r"(\s+final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: currentUser\.id\)\.where\('status', isEqualTo: 'Draft'\)\.get\(\);\n\s+)draftOrders = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\(d\)\)\.toList\(\);",
    r"\1if (qs.docs.isEmpty) {\n          draftOrders = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.status == 'Draft').toList();\n        } else {\n          draftOrders = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();\n        }",
    content
)

# 2. submitStoreOrdersToAdmin
content = re.sub(
    r"(\s+final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isEqualTo: storeId\)\.where\('batchId', isNull: true\)\.get\(\);\n\s+)unbatched = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\(d\)\)\.toList\(\);",
    r"\1if (qs.docs.isEmpty) {\n          unbatched = dummyParentOrders.where((o) => o.teamStoreId == storeId && o.batchId == null).toList();\n        } else {\n          unbatched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();\n        }",
    content
)

# 3. archiveDirectOrderBatch
content = re.sub(
    r"(\s+final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: currentUser\.id\)\.where\('batchId', isEqualTo: batchId\)\.where\('isArchived', isEqualTo: false\)\.get\(\);\n\s+)batched = qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\(d\)\)\.toList\(\);",
    r"\1if (qs.docs.isEmpty) {\n          batched = dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == currentUser.id && o.batchId == batchId && !o.isArchived).toList();\n        } else {\n          batched = qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();\n        }",
    content
)

# 4. getDirectOrdersForCoach
content = re.sub(
    r"(\s+final qs = await firestore\.collection\(_collectionPath\)\.where\('teamStoreId', isNull: true\)\.where\('userId', isEqualTo: coachId\)\.get\(\);\n\s+)return qs\.docs\.map\(\(d\) => ParentOrder\.fromFirestore\(d\)\)\.toList\(\);",
    r"\1if (qs.docs.isEmpty) {\n        return dummyParentOrders.where((o) => o.teamStoreId == null && o.userId == coachId).toList();\n      }\n      return qs.docs.map((d) => ParentOrder.fromFirestore(d)).toList();",
    content
)

with open('lib/services/order_service.dart', 'w') as f:
    f.write(content)
