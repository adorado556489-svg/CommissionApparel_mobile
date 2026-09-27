import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  
  content = content.replaceAll(
    """  void _createStore(String name, String desc, String packageType) {
    final user = context.read<AuthService>().currentUser;
    if (user == null || _activeStore != null) return;

    final newStore = TeamStore(
      id: 'store-${Random().nextInt(10000)}',
      userId: user.id,
      name: name,
      slug: TeamStore.generateSlug(name),
      description: desc,
      packageType: packageType,
      status: 'pending',
      pricingApproved: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setState(() {
      dummyTeamStores.add(newStore);
      _activeStore = newStore;
    });
  }""",
    """  Future<void> _createStore(String name, String desc, String packageType) async {
    final user = context.read<AuthService>().currentUser;
    if (user == null || _activeStore != null) return;

    final firestore = context.read<FirebaseFirestore>();
    final newStore = TeamStore(
      id: 'store-\${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      name: name,
      slug: TeamStore.generateSlug(name),
      description: desc,
      packageType: packageType,
      status: 'pending',
      pricingApproved: false,
      isArchived: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await StoreService.createStore(firestore, newStore);
    await _loadData();
  }"""
  );
  file.writeAsStringSync(content);
}
