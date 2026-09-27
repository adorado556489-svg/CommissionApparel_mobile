import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();

  // updateCoach
  content = content.replaceFirst('''
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    dummyUsers[index] = dummyUsers[index].copyWith(
''', '''
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index != -1) {
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
''');
  // the old logic had a copyWith call that we just duplicated, so we need to remove the old copyWith.
  // Actually, let's just do regex replace for the whole block!
  var updateCoachPattern = RegExp(r"final index = dummyUsers\.indexWhere\(\(u\) => u\.id == coach\.id\);\s*if \(index == -1\) return 'Coach not found';\s*dummyUsers\[index\] = dummyUsers\[index\]\.copyWith\([\s\S]*?\);");
  content = content.replaceFirstMapped(updateCoachPattern, (match) {
    return '''
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index != -1) {
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
''';
  });

  // resetCoachPassword
  var resetCoachPattern = RegExp(r"final index = dummyUsers\.indexWhere\(\(u\) => u\.id == coach\.id\);\s*if \(index == -1\) return 'Coach not found';\s*dummyUsers\[index\] = dummyUsers\[index\]\.copyWith\([\s\S]*?\);");
  content = content.replaceFirstMapped(resetCoachPattern, (match) {
    return '''
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index != -1) {
      dummyUsers[index] = dummyUsers[index].copyWith(
        password: newPassword,
        updatedAt: DateTime.now(),
      );
    }
''';
  });

  // deleteCoach
  var deleteCoachPattern = RegExp(r"final index = dummyUsers\.indexWhere\(\(u\) => u\.id == coachId\);\s*if \(index == -1\) return 'Coach not found';\s*final coachStoreIds = dummyTeamStores\.where\(\(s\) => s\.userId == coachId\)\.map\(\(s\) => s\.id\)\.toSet\(\);\s*dummyParentOrders\.removeWhere\(\(o\) => o\.teamStoreId != null && coachStoreIds\.contains\(o\.teamStoreId\)\);\s*dummyParentOrders\.removeWhere\(\(o\) => o\.teamStoreId == null && o\.userId == coachId\);\s*dummyTeamStores\.removeWhere\(\(s\) => s\.userId == coachId\);\s*dummyUsers\.removeAt\(index\);");
  content = content.replaceFirstMapped(deleteCoachPattern, (match) {
    return '''
    final index = dummyUsers.indexWhere((u) => u.id == coachId);
    if (index != -1) {
      final coachStoreIds = dummyTeamStores.where((s) => s.userId == coachId).map((s) => s.id).toSet();
      dummyParentOrders.removeWhere((o) => o.teamStoreId != null && coachStoreIds.contains(o.teamStoreId));
      dummyParentOrders.removeWhere((o) => o.teamStoreId == null && o.userId == coachId);
      dummyTeamStores.removeWhere((s) => s.userId == coachId);
      dummyUsers.removeAt(index);
    }
''';
  });

  file.writeAsStringSync(content);
}
