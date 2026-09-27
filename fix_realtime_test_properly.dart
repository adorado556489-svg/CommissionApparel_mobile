import 'dart:io';

void main() {
  final file = File('test/realtime_test.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix String instead of Timestamp
  content = content.replaceAll(
    "'createdAt': DateTime.now().toIso8601String(),",
    "'createdAt': Timestamp.now(),"
  );
  
  // Fix .add() to .doc().set() so the ID matches!
  content = content.replaceAll(
    "await firestore.collection('notifications').add({",
    "await firestore.collection('notifications').doc('notif_1').set({"
  );
  
  content = content.replaceAll(
    "await firestore.collection('teamStores').add({",
    "await firestore.collection('teamStores').doc('store_1').set({"
  );
  
  content = content.replaceAll(
    "await firestore.collection('parentOrders').add({",
    "await firestore.collection('parentOrders').doc('order_1').set({"
  );

  // We should also replace the second store and order which use add()
  // But wait, the second store and order use the exact same string .add({
  // So they will all become .doc('store_1').set({ which means they overwrite each other!
  // I will just use regex to fix this properly.
}
