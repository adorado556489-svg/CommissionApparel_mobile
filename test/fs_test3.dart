import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'helpers/test_seeder.dart';

void main() {
  test('fs test', () async {
    final fs = FakeFirebaseFirestore();
    await TestSeeder.seedAll(fs);
    
    final qs1 = await fs.collection('teamStores').where('userId', isEqualTo: 'user-coach-1').get();
    expect(qs1.docs.isNotEmpty, isTrue);
    
    final qs2 = await fs.collection('teamStores')
              .where('userId', isEqualTo: 'user-coach-1')
              .where('isArchived', isEqualTo: false)
              .get();
    expect(qs2.docs.isNotEmpty, isTrue);
  });
}
