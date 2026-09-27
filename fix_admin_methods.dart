import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();

  // updateCoach
  var updateCoachEnd = "return null;\n  }\n\n  static Future<String?> resetCoachPassword";
  var updateCoachFallback = '''
    final index = dummyUsers.indexWhere((u) => u.id == coach.id);
    if (index == -1) return 'Coach not found';

    dummyUsers[index] = dummyUsers[index].copyWith(
      firstName: firstName,
      lastName: lastName,
      email: email,
      organization: organization,
      phone: phone,
      sport: sport,
      isApproved: status == 'active',
      updatedAt: DateTime.now(),
    );
    return null;
''';
  // I need to be careful with replace.
  // Actually, updateCoach doesn't have `return null;` at the end! It's missing it!
  // It has:
  //      }
  //    }
  //  
  //    static Future<String?> resetCoachPassword
  var updateCoachPattern = RegExp(r"(\s*)\}\s*static Future<String\?> resetCoachPassword");
  content = content.replaceFirstMapped(updateCoachPattern, (match) {
    return "${updateCoachFallback}${match.group(1)}}\n\n  static Future<String?> resetCoachPassword";
  });

  // deleteCoach
  var deleteCoachFallback = '''
    final index = dummyUsers.indexWhere((u) => u.id == coachId);
    if (index == -1) return 'Coach not found';

    final coachStoreIds = dummyTeamStores.where((s) => s.userId == coachId).map((s) => s.id).toSet();
    dummyParentOrders.removeWhere((o) => o.teamStoreId != null && coachStoreIds.contains(o.teamStoreId));
    dummyParentOrders.removeWhere((o) => o.teamStoreId == null && o.userId == coachId);
    dummyTeamStores.removeWhere((s) => s.userId == coachId);
    dummyUsers.removeAt(index);
    return null;
''';
  // Currently deleteCoach has `return null;\n  }` at the end.
  //   static Future<String?> deleteCoach(...) async {
  //     if (admin.role != UserRole.admin) return 'Unauthorized';
  //     return null;
  //   }
  var deleteCoachPattern = RegExp(r"(static Future<String\?> deleteCoach[^\{]+\{.*?if\s*\(.*?return 'Unauthorized';)[\s\r\n]+return null;[\s\r\n]+\}", dotAll: true);
  content = content.replaceFirstMapped(deleteCoachPattern, (match) {
    return "${match.group(1)}\n${deleteCoachFallback}  }";
  });

  // markDirectBatchAddressed
  var markDirectFallback = '''
    var found = false;
    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.batchId == batchId && o.teamStoreId == null) {
        dummyParentOrders[i] = o.copyWith(status: 'Processing', isArchived: true);
        found = true;
      }
    }
    return found ? null : 'Batch not found.';
''';
  var markDirectPattern = RegExp(r"(static Future<String\?> markDirectBatchAddressed[^\{]+\{.*?)(return null;\s*\})", dotAll: true);
  content = content.replaceFirstMapped(markDirectPattern, (match) {
    return "${match.group(1)}\n${markDirectFallback}  }";
  });

  // markStoreBatchAddressed
  var markStoreFallback = '''
    var found = false;
    for (var i = 0; i < dummyParentOrders.length; i++) {
      final o = dummyParentOrders[i];
      if (o.batchId == batchId && o.teamStoreId != null) {
        dummyParentOrders[i] = o.copyWith(status: 'Processing', isArchived: true);
        found = true;
      }
    }
    return found ? null : 'Batch not found.';
''';
  var markStorePattern = RegExp(r"(static Future<String\?> markStoreBatchAddressed[^\{]+\{.*?)(return null;\s*\})", dotAll: true);
  content = content.replaceFirstMapped(markStorePattern, (match) {
    return "${match.group(1)}\n${markStoreFallback}  }";
  });

  // deleteArchivedOrderBatch
  var deleteArchivedFallback = '''
    final initialCount = dummyParentOrders.length;
    dummyParentOrders.removeWhere((o) => o.batchId == batchId && o.isArchived);
    return dummyParentOrders.length < initialCount ? null : 'Archived order batch not found.';
''';
  var deleteArchivedPattern = RegExp(r"(static Future<String\?> deleteArchivedOrderBatch[^\{]+\{.*?)(return null;\s*\})", dotAll: true);
  content = content.replaceFirstMapped(deleteArchivedPattern, (match) {
    return "${match.group(1)}\n${deleteArchivedFallback}  }";
  });

  file.writeAsStringSync(content);
}
