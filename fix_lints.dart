import 'dart:io';

void main() {
  // Fix admin_dashboard_screen.dart
  final adminFile = File('lib/screens/admin/admin_dashboard_screen.dart');
  String adminText = adminFile.readAsStringSync();
  final oldAdminText = """  Future<void> _markBatchAddressed(String batchId, bool isDirect) async {
    final admin = context.read<AuthService>().currentUser!;
    if (isDirect) {
      await AdminService.markDirectBatchAddressed(context.read<FirebaseFirestore>(), admin, batchId);
    } else {
      await AdminService.markStoreBatchAddressed(context.read<FirebaseFirestore>(), admin, batchId);
    }
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master Order Batch marked as addressed and archived.')),
    );
  }""";

  final newAdminText = """  Future<void> _markBatchAddressed(String batchId, bool isDirect) async {
    final admin = context.read<AuthService>().currentUser!;
    final firestore = context.read<FirebaseFirestore>();
    if (isDirect) {
      await AdminService.markDirectBatchAddressed(firestore, admin, batchId);
    } else {
      await AdminService.markStoreBatchAddressed(firestore, admin, batchId);
    }
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Master Order Batch marked as addressed and archived.')),
    );
  }""";

  if (adminText.contains(oldAdminText)) {
    adminFile.writeAsStringSync(adminText.replaceFirst(oldAdminText, newAdminText));
    print('admin_dashboard_screen.dart fixed');
  } else {
    print('Could not find text in admin_dashboard_screen.dart');
  }

  // Fix coach_catalog_tab.dart
  final coachFile = File('lib/screens/coach/widgets/coach_catalog_tab.dart');
  String coachText = coachFile.readAsStringSync();
  final oldCoachText = """  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final items = await CatalogService.getCoachDesignCatalog(firestore, context.read<AuthService>().currentUser!.id);
    final cols = await CatalogService.getCoachDesignCollections(firestore, context.read<AuthService>().currentUser!.id);
    if (mounted) {
      setState(() {
        _catalogItems = items;
        _collections = cols;
      });
    }
  }""";

  final newCoachText = """  Future<void> _loadData() async {
    final firestore = context.read<FirebaseFirestore>();
    final userId = context.read<AuthService>().currentUser!.id;
    final items = await CatalogService.getCoachDesignCatalog(firestore, userId);
    final cols = await CatalogService.getCoachDesignCollections(firestore, userId);
    if (mounted) {
      setState(() {
        _catalogItems = items;
        _collections = cols;
      });
    }
  }""";

  if (coachText.contains(oldCoachText)) {
    coachFile.writeAsStringSync(coachText.replaceFirst(oldCoachText, newCoachText));
    print('coach_catalog_tab.dart fixed');
  } else {
    print('Could not find text in coach_catalog_tab.dart');
  }
}
