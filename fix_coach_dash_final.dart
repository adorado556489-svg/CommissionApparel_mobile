import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix _loadData dummy data usage:
  content = content.replaceFirst(
    '''  void _loadData() {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;

    // Find active store
    try {
      _activeStore = dummyTeamStores.firstWhere(
        (s) => s.userId == user.id && !s.isArchived,
      );
    } catch (_) {
      _activeStore = null;
    }

    if (_activeStore != null) {
      _storeItems = dummyStoreItems.where((i) => i.teamStoreId == _activeStore!.id).toList();
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    } else {
      _storeItems = [];
      _unbatchedOrders = [];
    }

    // Assume first 3 are assigned to coach
    _assignedDesigns = dummyDesignCatalog.take(3).toList();
    
    setState(() {
      _isLoading = false;
    });
  }''',
  
    '''  Future<void> _loadData() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    final firestore = context.read<FirebaseFirestore>();

    try {
      final qs = await firestore.collection('teamStores').where('userId', isEqualTo: user.id).where('isArchived', isEqualTo: false).get();
      if (qs.docs.isNotEmpty) {
        _activeStore = TeamStore.fromFirestore(qs.docs.first);
      } else {
        _activeStore = null;
      }
    } catch (_) {
      _activeStore = null;
    }

    if (_activeStore != null) {
      _storeItems = await StoreService.getStoreItems(firestore, _activeStore!.id);
      // Removed _unbatchedOrders from here, we will stream it below.
    } else {
      _storeItems = [];
    }
    
    setState(() {
      _isLoading = false;
    });
  }'''
  );

  // We need to add back `import '../../services/storage_service.dart';`
  if (!content.contains('storage_service.dart')) {
    content = content.replaceFirst("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport '../../services/storage_service.dart';\nimport '../../widgets/managed_image.dart';");
  }

  // Cover image storage refactor
  content = content.replaceFirst(
    '''  Future<void> _pickCoverImage() async {
    if (_activeStore == null) return;
    
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      // Mock saving image path
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
    }
  }''',
    '''  Future<void> _pickCoverImage() async {
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
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cover image updated.')));
        }
      } catch (e) {}
    }
  }'''
  );

  // Logo storage refactor
  content = content.replaceFirst(
    '''  Future<void> _updateLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await context.read<AuthService>().updateProfileLogo(image.path);
      setState(() {});
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile logo updated.')));
    }
  }''',
    '''  Future<void> _updateLogo() async {
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
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile logo updated.')));
        }
      } catch (e) {}
    }
  }'''
  );

  content = content.replaceAll("FileImage(File(user.logoPath!))", "ManagedImage.getProvider(user.logoPath!)");

  // Fix _submitMasterOrder
  content = content.replaceFirst(
    '''  Future<void> _submitMasterOrder() async {
    if (_activeStore == null || _unbatchedOrders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot submit an empty roster.')),
      );
      return;
    }

    final batchId = 'batch-\${Random().nextInt(10000)}';

    setState(() {
      final updatedStore = _activeStore!.copyWith(status: 'submitted_to_admin');
      final storeIdx = dummyTeamStores.indexWhere((s) => s.id == _activeStore!.id);
      if (storeIdx != -1) dummyTeamStores[storeIdx] = updatedStore;
      _activeStore = updatedStore;

      for (var order in _unbatchedOrders) {
        final idx = dummyParentOrders.indexWhere((o) => o.id == order.id);
        if (idx != -1) {
          dummyParentOrders[idx] = order.copyWith(
            status: 'Submitted to Admin',
            batchId: batchId,
          );
        }
      }
      
      _unbatchedOrders = dummyParentOrders.where((o) => o.teamStoreId == _activeStore!.id && o.batchId == null).toList();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master order submitted successfully!')),
    );
  }''',
    '''  Future<void> _submitMasterOrder() async {
    final storeId = _activeStore?.id;
    if (storeId == null) return;
    
    final batchId = 'batch-\${DateTime.now().millisecondsSinceEpoch}';
    await OrderService.submitStoreOrdersToAdmin(context.read<FirebaseFirestore>(), context.read<AuthService>().currentUser!, storeId, batchId);
    await StoreService.updateStoreStatus(context.read<FirebaseFirestore>(), storeId, 'submitted_to_admin');
    await _loadData();
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Master order submitted successfully!')));
  }'''
  );
  
  // Fix Unbatched Orders in Overview
  content = content.replaceFirst(
    '''          Text('Unbatched Orders: \${_unbatchedOrders.length}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: store.isLocked ? null : _submitMasterOrder,
            child: const Text('SUBMIT MASTER ORDER'),
          ),''',
    '''          StreamBuilder<List<ParentOrder>>(
            stream: OrderService.getUnbatchedOrdersForStoreStream(context.read<FirebaseFirestore>(), store.id),
            builder: (context, snapshot) {
              final unbatched = snapshot.data ?? [];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unbatched Orders: \${unbatched.length}', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: store.isLocked || unbatched.isEmpty ? null : _submitMasterOrder,
                    child: const Text('SUBMIT MASTER ORDER'),
                  ),
                ],
              );
            }
          ),'''
  );

  file.writeAsStringSync(content);
}
