import 'dart:io';

void main() {
  var file = File('lib/services/order_service.dart');
  var content = file.readAsStringSync();
  
  var method = """  static Future<List<ParentOrder>> getUnbatchedOrders(FirebaseFirestore firestore, String storeId) async {
    final querySnapshot = await firestore
        .collection(FirestorePaths.parentOrders)
        .where('teamStoreId', isEqualTo: storeId)
        .where('batchId', isNull: true)
        .get();
    
    // In dummy mode this returns empty usually, but fallback will happen here if you need it.
    // Wait, the dummy fallback logic is in getAllOrders. We can just use the query.
    return querySnapshot.docs.map((doc) => ParentOrder.fromMap(doc.data(), doc.id)).toList();
  }

""";
  
  content = content.replaceFirst("class OrderService {", "class OrderService {\n" + method);
  
  file.writeAsStringSync(content);
}
