import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  final methods = '''
  Future<void> _setDeadline() async {
    final date = await showDatePicker(context: context, initialDate: DateTime.now().add(const Duration(days: 7)), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
    if (date != null && _activeStore != null) {
      final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (idx != -1) dummyTeamStores[idx] = dummyTeamStores[idx].copyWith(orderDeadline: date);
      await _loadData();
    }
  }

  Future<void> _approvePricing() async {
    if (_activeStore != null) {
      final idx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (idx != -1) dummyTeamStores[idx] = dummyTeamStores[idx].copyWith(pricingApproved: true);
      await _loadData();
    }
  }

  Future<void> _bulkMarkup(double amount) async {
    for (var item in _storeItems) {
      final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);
      if (idx != -1) dummyStoreItems[idx] = dummyStoreItems[idx].copyWith(coachMarkup: dummyStoreItems[idx].coachMarkup + amount);
    }
    await _loadData();
  }

  Future<void> _addStoreItem(DesignCatalog design) async {
    if (_activeStore == null) return;
    final item = StoreItem(
      id: 'item-\${DateTime.now().millisecondsSinceEpoch}',
      teamStoreId: _activeStore!.id,
      designCatalogId: design.id,
      productName: design.name,
      basePrice: design.basePrice,
      coachMarkup: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    dummyStoreItems.add(item);
    await _loadData();
  }

  Future<void> _removeStoreItem(String itemId) async {
    dummyStoreItems.removeWhere((i) => i.id == itemId);
    await _loadData();
  }

  Future<void> _updateItemMarkup(StoreItem item, double numVal) async {
    if (numVal < 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Retail price cannot be less than wholesale price.')));
      return;
    }
    final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);
    if (idx != -1) dummyStoreItems[idx] = dummyStoreItems[idx].copyWith(coachMarkup: numVal);
    await _loadData();
  }

  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final newUrl = await StorageService().replaceFile(
          'stores/\${_activeStore!.id}/cover_\${DateTime.now().millisecondsSinceEpoch}.jpg',
          File(image.path),
          _activeStore!.coverImagePath,
        );
        if (newUrl != null) {
          final firestore = context.read<FirebaseFirestore>();
          await firestore.collection('teamStores').doc(_activeStore!.id).update({'coverImagePath': newUrl});
          await _loadData();
        }
      } catch (e) {}
    }
  }

  Future<void> _updateLogo() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      try {
        final newUrl = await StorageService().replaceFile(
          'users/\${user.id}/logo_\${DateTime.now().millisecondsSinceEpoch}.png',
          File(image.path),
          user.logoPath,
        );
        if (newUrl != null) {
          await context.read<AuthService>().updateProfileLogo(newUrl);
          setState(() {});
        }
      } catch (e) {}
    }
  }
''';

  content = content.replaceFirst('  Widget _buildOverviewTab() {', methods + '\n  Widget _buildOverviewTab() {');
  
  // Make _loadData async!
  content = content.replaceFirst(
    'void _loadData() {',
    'Future<void> _loadData() async {'
  );

  file.writeAsStringSync(content);
}
