import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() async {
  final fs = FakeFirebaseFirestore();
  await fs.collection('stores').add({'userId': '1', 'status': 'pending'});
  final qs = await fs.collection('stores').where('userId', isEqualTo: '1').where('status', isNotEqualTo: 'archived').get();
  print('Found: \${qs.docs.length}');
}
