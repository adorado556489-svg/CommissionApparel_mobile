import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/parent_order.dart';
import '../../data/dummy_orders.dart';
import '../../widgets/app_scaffold.dart';

class AdminBatchShowScreen extends StatefulWidget {
  final String batchId;
  const AdminBatchShowScreen({super.key, required this.batchId});

  @override
  State<AdminBatchShowScreen> createState() => _AdminBatchShowScreenState();
}

class _AdminBatchShowScreenState extends State<AdminBatchShowScreen> {
  late List<ParentOrder> _orders;
  bool _isDirect = false;
  bool _isArchived = false;
  String _status = '';

  @override
  void initState() {
    super.initState();
    _loadBatch();
  }

  void _loadBatch() {
    _orders = dummyParentOrders.where((o) => o.batchId == widget.batchId).toList();
    if (_orders.isNotEmpty) {
      _isDirect = _orders.first.teamStoreId == null;
      _isArchived = _orders.first.isArchived;
      _status = _orders.first.status;
    }
  }

  Future<void> _markAddressed() async {
    final admin = context.read<AuthService>().currentUser!;
    final firestore = context.read<FirebaseFirestore>();
    String? error;
    if (_isDirect) {
      error = await AdminService.markDirectBatchAddressed(firestore, admin, widget.batchId);
    } else {
      error = await AdminService.markStoreBatchAddressed(firestore, admin, widget.batchId);
    }

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Batch marked as addressed and archived.')));
      setState(() {
        _loadBatch();
      });
    }
  }

  Future<void> _deleteBatch() async {
    final admin = context.read<AuthService>().currentUser!;
    final firestore = context.read<FirebaseFirestore>();
    final error = await AdminService.deleteArchivedOrderBatch(firestore, admin, widget.batchId);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Archived order batch has been permanently deleted.')));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orders.isEmpty) {
      return const AppScaffold(title: 'Batch Details', body: Center(child: Text('Batch not found or empty.')));
    }

    final totalValue = _orders.fold<double>(0, (acc, o) => acc + o.totalRetailPrice);
    final isAddressed = _isArchived && _status == 'Processing';

    return AppScaffold(
      title: 'Batch: ${widget.batchId.split('-').last}',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Batch Financials & Status', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 16),
                      Text('Type: ${_isDirect ? 'Direct Orders' : 'Store Orders'}'),
                      Text('Total Orders: ${_orders.length}'),
                      if (!_isDirect) Text('Total Retail Value: \$${totalValue.toStringAsFixed(2)}'),
                      Text('Current Status: $_status', style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      if (!isAddressed)
                        ElevatedButton.icon(
                          icon: const Icon(Icons.check),
                          label: const Text('Mark Addressed'),
                          onPressed: _markAddressed,
                        )
                      else ...[
                        const Text('This batch has been marked as addressed and archived.', style: TextStyle(color: Colors.green)),
                        const SizedBox(height: 16),
                        TextButton.icon(
                          onPressed: _deleteBatch,
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text('Permanently Delete Batch', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Orders in this Batch', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              ..._orders.map((o) => _buildOrderRow(o)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderRow(ParentOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text('${order.athleteFirstName} ${order.athleteLastName}'),
        subtitle: Text(order.itemEntries.map((e) => e.name).join(', ')),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () async {
            // Admin editing
            await Navigator.of(context).pushNamed('/coach/order/edit', arguments: order.id);
            if (!mounted) return;
            setState(() {
              _loadBatch();
            });
          },
        ),
      ),
    );
  }
}


