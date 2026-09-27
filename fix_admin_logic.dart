import 'dart:io';

void main() {
  var file = File('lib/services/admin_service.dart');
  var content = file.readAsStringSync();
  
  // Replace markDirectBatchAddressed dummy fallback
  content = content.replaceFirst(RegExp(r'var found = false;[\s\S]*?return found \? null : .Batch not found\..;'), 'return null;');
  
  // Replace markStoreBatchAddressed dummy fallback
  content = content.replaceFirst(RegExp(r'var found = false;[\s\S]*?return found \? null : .Batch not found\..;'), 'return null;');
  
  // Replace deleteArchivedOrderBatch dummy fallback
  content = content.replaceFirst(RegExp(r'final initialLength = dummyParentOrders\.length;[\s\S]*?return dummyParentOrders\.length < initialLength \? null : .Archived order batch not found\..;'), 'return null;');

  // Replace deleteCoach dummy fallback
  content = content.replaceFirst(RegExp(r'final index = dummyUsers\.indexWhere\(\(u\) => u\.id == coachId\);[\s\S]*?if \(index == -1\) return .Coach not found.;'), '');
  content = content.replaceFirst(RegExp(r'final coachStoreIds = dummyTeamStores\.where[\s\S]*?dummyUsers\.removeAt\(index\);'), '');
  
  file.writeAsStringSync(content);
}
