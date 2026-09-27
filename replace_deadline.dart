import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    """  void _setDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activeStore?.orderDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      setState(() {
        _activeStore = _activeStore!.copyWith(orderDeadline: picked);
      });
    }
  }""",
    """  Future<void> _setDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _activeStore?.orderDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && mounted) {
      await StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(orderDeadline: picked));
      await _loadData();
    }
  }"""
  );
  file.writeAsStringSync(content);
}
