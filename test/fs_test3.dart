import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/test/helpers/test_seeder.dart';

void main() {
  test('fs test', () async {
    final fs = FakeFirebaseFirestore();
    await TestSeeder.seedAll(fs);
    
    final qs1 = await fs.collection('teamStores').where('userId', isEqualTo: 'user-coach-1').get();
    print('Found with 1 where: \${qs1.docs.length}');
    
    final qs2 = await fs.collection('teamStores')
              .where('userId', isEqualTo: 'user-coach-1')
              .where('isArchived', isEqualTo: false)
              .get();
    print('Found with 2 wheres: \${qs2.docs.length}');
  });
}
