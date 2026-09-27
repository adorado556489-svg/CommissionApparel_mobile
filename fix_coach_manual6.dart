import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"  void _submitMasterOrder\(\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final firestore = context.read<FirebaseFirestore>();
    final user = context.read<AuthService>().currentUser!;
    final batchId = 'batch-\${DateTime.now().millisecondsSinceEpoch}';
    
    await OrderService.submitStoreOrdersToAdmin(firestore, user, _activeStore!.id, batchId);
    await _loadData();
    
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }""");

  file.writeAsStringSync(content);
}
