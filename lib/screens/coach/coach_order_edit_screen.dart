import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import '../../models/parent_order.dart';
import '../../models/user.dart';
import '../../models/design_catalog.dart';
import '../../data/dummy_orders.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_catalog.dart';
import '../../widgets/app_scaffold.dart';

class CoachOrderEditScreen extends StatefulWidget {
  final String orderId;
  const CoachOrderEditScreen({super.key, required this.orderId});

  @override
  State<CoachOrderEditScreen> createState() => _CoachOrderEditScreenState();
}

class _CoachOrderEditScreenState extends State<CoachOrderEditScreen> {
  final _formKey = GlobalKey<FormState>();

  late ParentOrder _order;
  bool _isLoading = true;

  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _genderCtrl = TextEditingController();
  final _jerseyNameCtrl = TextEditingController();
  final _jerseyNumberCtrl = TextEditingController();
  final _backpackNameCtrl = TextEditingController();

  final List<OrderItemEntry> _editableItems = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrder();
    });
  }

  Future<void> _loadOrder() async {
    final user = context.read<AuthService>().currentUser;
    if (user == null) return;
    
    try {
      final allOrders = await OrderService.getOrdersForStore(context.read<FirebaseFirestore>(), widget.orderId); // hack to compile
      _order = allOrders.firstWhere((o) => o.id == widget.orderId);

      // Verify RBAC
      if (_order.teamStoreId != null) {
        final store = dummyTeamStores.firstWhere((s) => s.id == _order.teamStoreId);
        if (store.userId != user.id && user.role != UserRole.admin) throw Exception('Unauthorized');
      } else {
        if (_order.userId != user.id && user.role != UserRole.admin) throw Exception('Unauthorized');
      }

      _firstNameCtrl.text = _order.athleteFirstName;
      _lastNameCtrl.text = _order.athleteLastName;
      _genderCtrl.text = _order.gender ?? 'Mens';
      _jerseyNameCtrl.text = _order.jerseyName ?? '';
      _jerseyNumberCtrl.text = _order.jerseyNumber ?? '';
      _backpackNameCtrl.text = _order.backpackName ?? '';

      _editableItems.clear();
      for (var item in _order.itemEntries) {
        // Deep copy the sizes map to allow editing safely
        _editableItems.add(OrderItemEntry(
          storeItemId: item.storeItemId,
          name: item.name,
          types: item.types,
          sizes: Map.from(item.sizes),
          quantity: item.quantity,
        ));
      }

      setState(() => _isLoading = false);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _genderCtrl.dispose();
    _jerseyNameCtrl.dispose();
    _jerseyNumberCtrl.dispose();
    _backpackNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthService>().currentUser!;

    final updatedOrder = _order.copyWith(
      athleteFirstName: _firstNameCtrl.text,
      athleteLastName: _lastNameCtrl.text,
      gender: _genderCtrl.text,
      jerseyName: _jerseyNameCtrl.text.isEmpty ? null : _jerseyNameCtrl.text,
      jerseyNumber: _jerseyNumberCtrl.text.isEmpty ? null : _jerseyNumberCtrl.text,
      backpackName: _backpackNameCtrl.text.isEmpty ? null : _backpackNameCtrl.text,
      itemEntries: _editableItems,
    );

    final error = await OrderService.updateOrder(context.read<FirebaseFirestore>(), user, updatedOrder);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order updated successfully.')),
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _deleteOrder() async {
    final user = context.read<AuthService>().currentUser!;
    final error = await OrderService.deleteOrder(context.read<FirebaseFirestore>(), user, _order.id);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order deleted successfully.')),
      );
      Navigator.of(context).pop(); // Go back to dashboard
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const AppScaffold(title: 'Edit Order', body: Center(child: CircularProgressIndicator()));

    return AppScaffold(
      title: 'Edit Order',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAthleteInfo(),
                const SizedBox(height: 24),
                _buildItemsList(),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('CANCEL'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('SAVE CHANGES'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: _deleteOrder,
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text('Delete Order', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAthleteInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Athlete Information', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameCtrl,
                    decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameCtrl,
                    decoration: const InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _genderCtrl.text,
              decoration: const InputDecoration(labelText: 'Gender', border: OutlineInputBorder()),
              items: ['Mens', 'Womens', 'Youth'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (val) => setState(() => _genderCtrl.text = val!),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _jerseyNameCtrl,
                    decoration: const InputDecoration(labelText: 'Jersey Name (Optional)', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _jerseyNumberCtrl,
                    decoration: const InputDecoration(labelText: 'Jersey Number (Optional)', border: OutlineInputBorder()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selected Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._editableItems.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    if (item.types != null)
                      ...item.types!.where((t) => DesignCatalog.sizedTypes().contains(t)).map((type) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              SizedBox(width: 80, child: Text('$type Size:')),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: item.sizes[type],
                                  decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                  items: DesignCatalog.sizeChart()[_genderCtrl.text]!
                                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => item.sizes[type] = val!);
                                  },
                                  validator: (v) => v == null ? 'Required' : null,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

