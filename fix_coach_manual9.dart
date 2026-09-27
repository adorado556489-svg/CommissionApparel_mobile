import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var lines = file.readAsLinesSync();
  
  var newLines = <String>[];
  var insideSubmit = false;
  
  for (var line in lines) {
    if (line.contains('Future<void> _submitMasterOrder() async {')) {
      insideSubmit = true;
      newLines.add("""  Future<void> _submitMasterOrder() async {
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
      continue;
    }
    
    if (insideSubmit) {
      if (line == '  }') {
        insideSubmit = false;
      }
      continue;
    }
    
    newLines.add(line);
  }
  
  file.writeAsStringSync(newLines.join('\n'));
}
