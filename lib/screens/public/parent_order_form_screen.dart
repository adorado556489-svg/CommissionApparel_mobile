import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../widgets/app_scaffold.dart';
import '../../data/dummy_stores.dart';
import '../../data/dummy_orders.dart';
import '../../models/store_item.dart';
import '../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/parent_order.dart';
import '../../models/design_catalog.dart';
import '../../services/auth_service.dart';

class ParentOrderFormScreen extends StatefulWidget {
  final String storeId;

  const ParentOrderFormScreen({super.key, required this.storeId});

  @override
  State<ParentOrderFormScreen> createState() => _ParentOrderFormScreenState();
}

class _ParentOrderFormScreenState extends State<ParentOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _jerseyNameController = TextEditingController();
  final _jerseyNumberController = TextEditingController();
  final _backpackNameController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _gender;

  // Track selected items and their configurations.
  // StoreItemId -> Entry state
  final Map<String, _OrderItemState> _itemStates = {};

  late final dynamic store;
  late final List<StoreItem> storeItems;

  @override
  void initState() {
    super.initState();
    store = dummyTeamStores.firstWhere(
      (s) => s.id == widget.storeId,
      orElse: () => dummyTeamStores.first,
    );
    storeItems = dummyStoreItems.where((i) => i.teamStoreId == store.id).toList();

    // Initialize state for each available item (unselected by default)
    for (final item in storeItems) {
      _itemStates[item.id] = _OrderItemState(item: item);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _jerseyNameController.dispose();
    _jerseyNumberController.dispose();
    _backpackNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_gender == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a gender.')));
      return;
    }

    final selectedStates = _itemStates.values.where((s) => s.selected).toList();
    if (selectedStates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select at least one item.')));
      return;
    }

    // Validate all sizes are filled for selected items
    for (final state in selectedStates) {
      if (!state.isValid(storeItems)) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please complete sizing for ${state.item.name}.')));
        return;
      }
    }

    // Build the order items
    final List<OrderItemEntry> entries = [];
    double retailTotal = 0;

    for (final state in selectedStates) {
      retailTotal += state.item.retailPrice * state.qty;

      if (state.item.isPackage) {
        final List<OrderItemComponent> comps = [];
        final pkgComps = storeItems.where((i) => state.item.componentIds.contains(i.id)).toList();
        for (final comp in pkgComps) {
            comps.add(OrderItemComponent(
              storeItemId: comp.id,
              name: comp.name,
              sizes: Map.from(state.componentSizes[comp.id] ?? {}),
            ));
        }
        entries.add(OrderItemEntry(
          storeItemId: state.item.id,
          name: state.item.name,
          types: state.item.types,
          quantity: state.qty,
          components: comps,
        ));
      } else {
        entries.add(OrderItemEntry(
          storeItemId: state.item.id,
          name: state.item.name,
          types: state.item.types,
          sizes: Map.from(state.sizes),
          quantity: state.qty,
        ));
      }
    }

    final authUser = context.read<AuthService>().currentUser;
    final parentUserId = authUser?.id;

    final newOrder = ParentOrder(
      id: 'order-${DateTime.now().millisecondsSinceEpoch}',
      teamStoreId: store.id,
      userId: parentUserId,
      athleteFirstName: _firstNameController.text.trim(),
      athleteLastName: _lastNameController.text.trim(),
      gender: _gender,
      jerseyName: _jerseyNameController.text.trim().isEmpty ? null : _jerseyNameController.text.trim(),
      jerseyNumber: _jerseyNumberController.text.trim().isEmpty ? null : _jerseyNumberController.text.trim(),
      backpackName: _backpackNameController.text.trim().isEmpty ? null : _backpackNameController.text.trim(),
      specialNotes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      itemEntries: entries,
      totalRetailPrice: retailTotal,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await OrderService.createOrder(context.read<FirebaseFirestore>(), newOrder);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Order Submitted'),
        content: Text('Successfully placed order for ${newOrder.athleteFirstName} ${newOrder.athleteLastName}!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop(); // close dialog
              Navigator.of(context).pop(); // pop back to store detail
            },
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!store.isAcceptingOrders) {
      return AppScaffold(
        title: 'Store Closed',
        currentNavIndex: 2,
        body: Center(
          child: Text('This store is not accepting orders: ${store.closedReason}'),
        ),
      );
    }

    return AppScaffold(
      title: 'Place Order',
      currentNavIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Athlete Information', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(labelText: 'First Name *', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      decoration: const InputDecoration(labelText: 'Last Name *', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender *', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (val) => setState(() => _gender = val),
                validator: (val) => val == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              Text('Optional Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _jerseyNameController,
                      decoration: const InputDecoration(labelText: 'Jersey Name', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _jerseyNumberController,
                      decoration: const InputDecoration(labelText: 'Jersey Number', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _backpackNameController,
                decoration: const InputDecoration(labelText: 'Backpack Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              Text('Select Items', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              ...storeItems.map((item) => _buildItemCard(item)),

              const SizedBox(height: 24),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Special Notes', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              
              _buildTotalBar(),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitOrder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('SUBMIT ORDER', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(StoreItem item) {
    final state = _itemStates[item.id]!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: state.selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: state.selected ? AppTheme.primary : AppTheme.borderSubtle, width: state.selected ? 2 : 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: state.selected,
          onExpansionChanged: (expanded) {
            setState(() {
              state.selected = expanded;
            });
          },
          leading: Checkbox(
            value: state.selected,
            onChanged: (val) {
              setState(() {
                state.selected = val ?? false;
              });
            },
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('\$${item.retailPrice.toStringAsFixed(2)}'),
          children: [
            if (state.selected)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Text('Quantity: ', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () {
                            if (state.qty > 1) {
                              setState(() => state.qty--);
                            }
                          },
                        ),
                        Text('${state.qty}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            setState(() => state.qty++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (item.isPackage)
                      ...storeItems.where((i) => item.componentIds.contains(i.id)).toList().map((comp) {
                        return _buildSizeSelectorsForComponent(comp, state);
                      })
                    else
                      _buildSizeSelectorsForItem(item, state),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildSizeSelectorsForItem(StoreItem item, _OrderItemState state) {
    final types = item.types;
    final sizedTypes = types.where((t) => DesignCatalog.sizedTypes().contains(t)).toList();
    if (sizedTypes.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sizedTypes.map((t) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: DropdownButtonFormField<String>(
            value: state.sizes[t],
            decoration: InputDecoration(labelText: 'Size for ${t.replaceAll('_', ' ')}', border: const OutlineInputBorder()),
            items: DesignCatalog.allSizes().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => state.sizes[t] = val!),
            validator: (val) => val == null ? 'Required' : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSizeSelectorsForComponent(StoreItem comp, _OrderItemState state) {
    final types = comp.types;
    final sizedTypes = types.where((t) => DesignCatalog.sizedTypes().contains(t)).toList();
    if (sizedTypes.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(comp.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textMuted)),
        ),
        ...sizedTypes.map((t) {
          state.componentSizes[comp.id] ??= {};
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: DropdownButtonFormField<String>(
              value: state.componentSizes[comp.id]![t],
              decoration: InputDecoration(labelText: 'Size for ${t.replaceAll('_', ' ')}', border: const OutlineInputBorder()),
              items: DesignCatalog.allSizes().map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => setState(() => state.componentSizes[comp.id]![t] = val!),
              validator: (val) => val == null ? 'Required' : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTotalBar() {
    double total = 0;
    for (final state in _itemStates.values) {
      if (state.selected) {
        total += state.item.retailPrice * state.qty;
      }
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Retail Total:', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text('\$${total.toStringAsFixed(2)}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppTheme.success, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _OrderItemState {
  final StoreItem item;
  bool selected = false;
  int qty = 1;
  final Map<String, String> sizes = {};
  final Map<String, Map<String, String>> componentSizes = {};

  _OrderItemState({required this.item});

  bool isValid(List<StoreItem> storeItems) {
    if (item.isPackage) {
      final comps = storeItems.where((i) => item.componentIds.contains(i.id)).toList();
      for (final comp in comps) {
        final types = comp.types;
        final sizedTypes = types.where((t) => DesignCatalog.sizedTypes().contains(t)).toList();
        for (final t in sizedTypes) {
          if (componentSizes[comp.id]?[t] == null) return false;
        }
      }
    } else {
      final types = item.types;
      final sizedTypes = types.where((t) => DesignCatalog.sizedTypes().contains(t)).toList();
      for (final t in sizedTypes) {
        if (sizes[t] == null) return false;
      }
    }
    return true;
  }
}


