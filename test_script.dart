import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/services/auth_service.dart';

void main() async {
  final firestore = FakeFirebaseFirestore();
  await firestore.collection('users').doc('coach-2').set(
        User(id: 'coach-2', email: 'test2@test.com', firstName: 'A', lastName: 'B', role: UserRole.coach, logoPath: 'test_logo.png', password: '', updatedAt: DateTime.now(), createdAt: DateTime.now()).toFirestore()
      );
  final doc = await firestore.collection('users').doc('coach-2').get();
  print(doc.data());
  final auth = AuthService(firestore: firestore);
  final user = await auth.getUserById('coach-2');
  print('User: ${user?.logoPath}');
}
