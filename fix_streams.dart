import 'dart:io';

void main() {
  // StoreService
  var storeFile = File('lib/services/store_service.dart');
  var storeContent = storeFile.readAsStringSync();
  storeContent = storeContent.replaceAll("firestore.collection('stores')", "firestore.collection(FirestorePaths.teamStores)");
  storeContent = storeContent.replaceAll("firestore.collection('teamStores')", "firestore.collection(FirestorePaths.teamStores)");
  storeFile.writeAsStringSync(storeContent);

  // OrderService
  var orderFile = File('lib/services/order_service.dart');
  var orderContent = orderFile.readAsStringSync();
  orderContent = orderContent.replaceAll("firestore.collection('orders')", "firestore.collection(FirestorePaths.parentOrders)");
  orderContent = orderContent.replaceAll("firestore.collection('parentOrders')", "firestore.collection(FirestorePaths.parentOrders)");
  orderFile.writeAsStringSync(orderContent);

  // ContentService
  var contentFile = File('lib/services/content_service.dart');
  var contentContent = contentFile.readAsStringSync();
  contentContent = contentContent.replaceFirst("""        .map((qs) {
          if (qs.docs.isEmpty) {
      return [];
          }
    return [];
        });""", """        .map((qs) {
          if (qs.docs.isEmpty) {
            return [];
          }
          return qs.docs.map((d) => NotificationItem.fromFirestore(d)).toList();
        });""");
  contentFile.writeAsStringSync(contentContent);
}
