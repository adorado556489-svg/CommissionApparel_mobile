import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/design_catalog.dart';
import '../../models/parent_order.dart';
import '../../data/dummy_catalog.dart';
import '../../widgets/app_scaffold.dart';

class DirectOrderFormScreen extends StatefulWidget {
  const DirectOrderFormScreen({super.key});

  @override
  State<DirectOrderFormScreen> createState() => _DirectOrderFormScreenState();
}

class _DirectOrderFormScreenState extends State<DirectOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  String _orderType = 'person'; // 'person' or 'item'
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _genderCtrl = TextEditingController(text: 'Mens');
  final _jerseyNameCtrl = TextEditingController();
  final _jerseyNumberCtrl = TextEditingController();
  final _backpackNameCtrl = TextEditingController();

  final Map<String, _DesignSelection> _selections = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSelections();
    });
  }

  void _initSelections() {
    final user = context.read<AuthService>().currentUser;
    if (user == null || user.assignedDesignIds.isEmpty) return;

    for (var id in user.assignedDesignIds) {
      final design = dummyDesignCatalog.firstWhere((d) => d.id == id);
      _selections[id] = _DesignSelection(design: design);
    }
    setState(() {});
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

    final selectedItems = _selections.values.where((s) => s.isSelected).toList();
    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one item before submitting.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = context.read<AuthService>().currentUser!;

    final itemsToSubmit = <OrderItemEntry>[];
    for (var sel in selectedItems) {
      itemsToSubmit.add(OrderItemEntry(
        storeItemId: sel.design.id, // Direct orders map catalog ID here
        name: sel.design.name,
        types: sel.design.types ?? [],
        sizes: sel.sizes,
        quantity: sel.qty,
      ));
    }

    final error = await OrderService.submitDirectOrder(
      context.read<FirebaseFirestore>(),
      user,
      orderType: _orderType,
      athleteFirstName: _firstNameCtrl.text.isEmpty ? null : _firstNameCtrl.text,
      athleteLastName: _lastNameCtrl.text.isEmpty ? null : _lastNameCtrl.text,
      gender: _orderType == 'person' ? _genderCtrl.text : 'Mens',
      jerseyName: _jerseyNameCtrl.text,
      jerseyNumber: _jerseyNumberCtrl.text,
      backpackName: _backpackNameCtrl.text,
      items: itemsToSubmit,
    );

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order line added to your draft.')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Create Direct Order',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderTypeSelector(),
                const SizedBox(height: 24),
                if (_orderType == 'person') _buildAthleteInfo(),
                const SizedBox(height: 24),
                _buildCatalogSelection(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('SUBMIT TO DRAFT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Type', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('By Person (Athlete)'),
                    value: 'person',
                    groupValue: _orderType,
                    onChanged: (val) => setState(() => _orderType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('By Item (Bulk)'),
                    value: 'item',
                    groupValue: _orderType,
                    onChanged: (val) => setState(() => _orderType = val!),
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildCatalogSelection() {
    if (_selections.isEmpty) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assigned Catalog Items', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ..._selections.values.map((sel) {
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
                    CheckboxListTile(
                      title: Text(sel.design.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Wholesale: \$${sel.design.wholesalePrice?.toStringAsFixed(2) ?? '0.00'}'),
                      value: sel.isSelected,
                      onChanged: (val) => setState(() => sel.isSelected = val!),
                    ),
                    if (sel.isSelected)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                        child: Column(
                          children: [
                            if (_orderType == 'item')
                              Row(
                                children: [
                                  const Text('Quantity: '),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      initialValue: sel.qty.toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                      onChanged: (v) => sel.qty = int.tryParse(v) ?? 1,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 12),
                            if (sel.design.types != null)
                              ...sel.design.types!.where((t) => DesignCatalog.sizedTypes().contains(t)).map((type) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    children: [
                                      SizedBox(width: 80, child: Text('$type Size:')),
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: sel.sizes[type],
                                          decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
                                          items: DesignCatalog.sizeChart()[_genderCtrl.text]!
                                              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                              .toList(),
                                          onChanged: (val) => setState(() => sel.sizes[type] = val!),
                                          validator: (v) => v == null ? 'Required' : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
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

class _DesignSelection {
  final DesignCatalog design;
  bool isSelected;
  int qty;
  final Map<String, String> sizes;

  _DesignSelection({
    required this.design,
    this.isSelected = false,
    this.qty = 1,
  }) : sizes = {};
}

