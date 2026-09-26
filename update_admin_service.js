const fs = require('fs');
const path = 'lib/services/admin_service.dart';
let code = fs.readFileSync(path, 'utf8');

const updateCoachOld = `  static String? updateCoach(User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    // check email uniqueness
    if (dummyUsers.any((u) => u.email == email && u.id != coach.id)) {
      return 'Email already in use.';
    }

    dummyUsers[index] = dummyUsers[index].copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      organization: organization,
      phone: phone,
      sport: sport,
      status: status,
      updatedAt: DateTime.now(),
    );
    return null;
  }`;

const updateCoachNew = `  static Future<String?> updateCoach(FirebaseFirestore firestore, User admin, User coach, {
    required String firstName,
    required String lastName,
    required String email,
    required String organization,
    required String phone,
    required String sport,
    required String status,
  }) async {
    if (admin.role != UserRole.admin) return 'Unauthorized';
    
    // Check email uniqueness in Firestore if possible
    try {
      final qs = await firestore.collection('users').where('email', isEqualTo: email).get();
      if (qs.docs.isNotEmpty && qs.docs.first.id != coach.id) {
        return 'Email already in use.';
      }
      
      final doc = await firestore.collection('users').doc(coach.id).get();
      if (doc.exists) {
        await firestore.collection('users').doc(coach.id).update({
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'organization': organization,
          'phone': phone,
          'sport': sport,
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } on FirebaseException catch (e) {
      if (e.code != 'not-found' && e.code != 'unimplemented') {
        print('CRITICAL FIRESTORE ERROR [AdminService.updateCoach]: \${e.message}');
        throw e;
      }
    }

    // Dummy fallback logic
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index != -1) {
      if (dummyUsers.any((u) => u.email == email && u.id != coach.id)) {
        return 'Email already in use.';
      }
      dummyUsers[index] = dummyUsers[index].copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        organization: organization,
        phone: phone,
        sport: sport,
        status: status,
        updatedAt: DateTime.now(),
      );
    }
    return null;
  }`;

const deleteCoachOld = `      final stores = await firestore.collection('teamStores').where('userId', isEqualTo: coachId).get();
      for (var storeDoc in stores.docs) {
        final storeOrders = await firestore.collection('parentOrders').where('teamStoreId', isEqualTo: storeDoc.id).get();
        for (var doc in storeOrders.docs) { batch.delete(doc.reference); }
      }
      // Note: we don't delete stores or coach user from firestore here because Checkpoint D is only ParentOrder data.
      await batch.commit();`;

const deleteCoachNew = `      final stores = await firestore.collection('teamStores').where('userId', isEqualTo: coachId).get();
      for (var storeDoc in stores.docs) {
        final storeOrders = await firestore.collection('parentOrders').where('teamStoreId', isEqualTo: storeDoc.id).get();
        for (var doc in storeOrders.docs) { batch.delete(doc.reference); }
        batch.delete(storeDoc.reference);
      }
      batch.delete(firestore.collection('users').doc(coachId));
      await batch.commit();`;

if (code.includes(updateCoachOld)) {
    code = code.replace(updateCoachOld, updateCoachNew);
} else {
    console.error("Could not find updateCoachOld in admin_service.dart");
}

if (code.includes(deleteCoachOld)) {
    code = code.replace(deleteCoachOld, deleteCoachNew);
} else {
    console.error("Could not find deleteCoachOld in admin_service.dart");
}

fs.writeFileSync(path, code, 'utf8');
console.log("Updated AdminService.dart");
