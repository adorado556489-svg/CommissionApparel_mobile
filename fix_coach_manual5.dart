import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(RegExp(r"  void _updateItemMarkup\(StoreItem item, double newRetail\) \{[\s\S]+?\}\);\r?\n  \}"),
"""  Future<void> _updateItemMarkup(StoreItem item, double newRetail) async {
    if (newRetail < item.wholesalePrice) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Retail price cannot be less than wholesale price.')),
      );
      return;
    }
    final firestore = context.read<FirebaseFirestore>();
    await StoreService.updateStoreItem(firestore, item.copyWith(retailPrice: newRetail));
    await _loadData();
  }""");

  file.writeAsStringSync(content);
}
