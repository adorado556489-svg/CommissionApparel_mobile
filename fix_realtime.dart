import 'dart:io';

void main() {
  final path = 'test/realtime_test.dart';
  var content = File(path).readAsStringSync();
  
  content = content.replaceFirst(
    '''      await firestore.collection('teamStores').doc('store_1').set({
        'id': 'store_1',
        'name': 'Store 1',
        'status': 'pending',
        'userId': 'coach_1',
        'slug': 'store-1',
        'isArchived': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });''',
    '''      final store1 = rawdummyTeamStores.firstWhere((s) => s.id == 'store-4').copyWith(id: 'store_1', status: 'pending');
      await firestore.collection('teamStores').doc('store_1').set(store1.toFirestore());'''
  );

  content = content.replaceFirst(
    '''      await firestore.collection('teamStores').doc('store_2').set({
        'id': 'store_2',
        'name': 'Store 2',
        'status': 'approved',
        'userId': 'coach_1',
        'slug': 'store-2',
        'isArchived': false,
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });''',
    '''      final store2 = rawdummyTeamStores.firstWhere((s) => s.id == 'store-4').copyWith(id: 'store_2', status: 'approved');
      await firestore.collection('teamStores').doc('store_2').set(store2.toFirestore());'''
  );

  content = content.replaceFirst(
    '''      await firestore.collection('parentOrders').doc('order_1').set({
        'id': 'order_1',
        'teamStoreId': 'store1',
        'userId': 'parent1',
        'batchId': null,
        'status': 'Submitted',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });''',
    '''      final order1 = rawdummyParentOrders.first.copyWith(id: 'order_1', teamStoreId: 'store1', batchId: null, status: 'Submitted');
      await firestore.collection('parentOrders').doc('order_1').set(order1.toFirestore());'''
  );

  content = content.replaceFirst(
    '''      await firestore.collection('parentOrders').doc('order_2').set({
        'id': 'order_2',
        'teamStoreId': 'store1',
        'userId': 'parent1',
        'batchId': 'batch1',
        'status': 'Submitted to Admin',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });''',
    '''      final order2 = rawdummyParentOrders.first.copyWith(id: 'order_2', teamStoreId: 'store1', batchId: 'batch1');
      await firestore.collection('parentOrders').doc('order_2').set(order2.toFirestore());'''
  );

  content = content.replaceFirst(
    '''      await firestore.collection('parentOrders').doc('order_3').set({
        'id': 'order_3',
        'teamStoreId': 'store2',
        'userId': 'parent1',
        'batchId': null,
        'status': 'Submitted',
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
        'itemEntries': [],
        'athleteFirstName': 'Test',
        'athleteLastName': 'Test',
        'gender': 'Mens',
        'totalRetailPrice': 0.0,
      });''',
    '''      final order3 = rawdummyParentOrders.first.copyWith(id: 'order_3', teamStoreId: 'store2', batchId: null, status: 'Submitted');
      await firestore.collection('parentOrders').doc('order_3').set(order3.toFirestore());'''
  );

  File(path).writeAsStringSync(content);
  print('Done fixing realtime_test.dart');
}
