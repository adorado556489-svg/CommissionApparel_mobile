import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_order_edit_screen.dart');
  var code = file.readAsStringSync();
  
  var oldCheck = """      // Verify RBAC
      if (_order.teamStoreId != null) {
        final store = dummyTeamStores.firstWhere((s) => s.id == _order.teamStoreId);
        if (store.userId != user.id && user.role != UserRole.admin) throw Exception('Unauthorized');
      } else {
        if (_order.userId != user.id && user.role != UserRole.admin) throw Exception('Unauthorized');
      }""";
      
  var newCheck = """      // Verify RBAC
      if (_order.teamStoreId != null) {
        final store = await StoreService.getStore(context.read<FirebaseFirestore>(), _order.teamStoreId!);
        if (store == null || (store.userId != user.id && user.role != UserRole.admin)) throw Exception('Unauthorized');
      } else {
        if (_order.userId != user.id && user.role != UserRole.admin) throw Exception('Unauthorized');
      }""";

  // Also StoreService import if not there
  if (!code.contains("import '../../services/store_service.dart';")) {
     code = code.replaceFirst("import '../../services/order_service.dart';", "import '../../services/order_service.dart';\nimport '../../services/store_service.dart';");
  }
  
  if (code.contains(oldCheck)) {
    code = code.replaceAll(oldCheck, newCheck);
    file.writeAsStringSync(code);
    print("coach_order_edit_screen updated.");
  } else {
    print("coach_order_edit_screen pattern not found.");
  }
}
