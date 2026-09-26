import 'dart:io';

void main() {
  final file = File('lib/screens/admin/admin_dashboard_screen.dart');
  var code = file.readAsStringSync();
  
  final approveOldRegex = RegExp(r"void\s+_approveStore\(TeamStore\s+store\)\s*\{[\s\S]*?has\s+been\s+activated\.'\)\),\s*\);\s*\}");
  final approveNew = """Future<void> _approveStore(TeamStore store) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, store.copyWith(status: 'approved'));
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store "\${store.name}" has been activated.')));
  }""";
  
  if (code.contains(approveOldRegex)) {
    code = code.replaceAll(approveOldRegex, approveNew);
  }
  
  final declineOldRegex = RegExp(r"void\s+_declineStore\(TeamStore\s+store\)\s*\{[\s\S]*?has\s+been\s+declined\.'\)\),\s*\);\s*\}");
  final declineNew = """Future<void> _declineStore(TeamStore store) async {
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStore(firestore, store.copyWith(status: 'declined'));
    setState(() {});
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Store "\${store.name}" has been declined.')));
  }""";
  
  if (code.contains(declineOldRegex)) {
    code = code.replaceAll(declineOldRegex, declineNew);
  }
  
  file.writeAsStringSync(code);
}
