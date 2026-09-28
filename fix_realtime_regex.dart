import 'dart:io';

void main() {
  final path = 'test/realtime_test.dart';
  var content = File(path).readAsStringSync();
  
  // Replace the teamStores logic
  content = content.replaceFirst(RegExp(r"await firestore\.collection\('teamStores'\)\.doc\('store_1'\)\.set\(\{[\s\S]*?\}\);"), "final store1 = rawdummyTeamStores.firstWhere((s) => s.id == 'store-4').copyWith(id: 'store_1', status: 'pending'); await firestore.collection('teamStores').doc('store_1').set(store1.toFirestore());");

  content = content.replaceFirst(RegExp(r"await firestore\.collection\('teamStores'\)\.doc\('store_2'\)\.set\(\{[\s\S]*?\}\);"), "final store2 = rawdummyTeamStores.firstWhere((s) => s.id == 'store-4').copyWith(id: 'store_2', status: 'approved'); await firestore.collection('teamStores').doc('store_2').set(store2.toFirestore());");

  content = content.replaceFirst(RegExp(r"await firestore\.collection\('parentOrders'\)\.doc\('order_1'\)\.set\(\{[\s\S]*?\}\);"), "final order1 = rawdummyParentOrders.first.copyWith(id: 'order_1', teamStoreId: 'store1', batchId: null, status: 'Submitted'); await firestore.collection('parentOrders').doc('order_1').set(order1.toFirestore());");

  content = content.replaceFirst(RegExp(r"await firestore\.collection\('parentOrders'\)\.doc\('order_2'\)\.set\(\{[\s\S]*?\}\);"), "final order2 = rawdummyParentOrders.first.copyWith(id: 'order_2', teamStoreId: 'store1', batchId: 'batch1'); await firestore.collection('parentOrders').doc('order_2').set(order2.toFirestore());");

  content = content.replaceFirst(RegExp(r"await firestore\.collection\('parentOrders'\)\.doc\('order_3'\)\.set\(\{[\s\S]*?\}\);"), "final order3 = rawdummyParentOrders.first.copyWith(id: 'order_3', teamStoreId: 'store2', batchId: null, status: 'Submitted'); await firestore.collection('parentOrders').doc('order_3').set(order3.toFirestore());");

  File(path).writeAsStringSync(content);
  print('Done regex fix');
}
