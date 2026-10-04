import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../constants/statuses.dart';
import '../../../models/team_store.dart';
import '../../../services/storage_service.dart';
import '../../../services/store_service.dart';
import '../../../utils/formatters.dart';
import '../../../widgets/glass_panel.dart';
import '../../../widgets/managed_image.dart';
import '../../../widgets/status_chip.dart';

/// Coach "STORE" tab: branding, ordering deadline, store details and the
/// open / locked state of the storefront.
class CoachStoreTab extends StatefulWidget {
  final TeamStore store;

  /// Called after any change so the parent can reload the store.
  final VoidCallback onChanged;

  const CoachStoreTab({super.key, required this.store, required this.onChanged});

  @override
  State<CoachStoreTab> createState() => _CoachStoreTabState();
}

class _CoachStoreTabState extends State<CoachStoreTab>
    with AutomaticKeepAliveClientMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _paymentCtrl;

  final Set<String> _busy = {};

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.store.name);
    _descCtrl = TextEditingController(text: widget.store.description ?? '');
    _paymentCtrl = TextEditingController(text: widget.store.paymentInstructions ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _paymentCtrl.dispose();
    super.dispose();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  /// Runs [action] once at a time per [key]; shows its error or [success].
  Future<void> _run(String key, Future<String?> Function() action, String success) async {
    if (_busy.contains(key)) return;
    setState(() => _busy.add(key));
    String? error;
    try {
      error = await action();
    } catch (e) {
      debugPrint('CoachStoreTab[$key] failed: $e');
      error = 'Something went wrong. Please try again.';
    }
    if (!mounted) return;
    setState(() => _busy.remove(key));
    _toast(error ?? success);
    if (error == null) widget.onChanged();
  }

  Future<String?> _uploadImage(String folder, String field) async {
    final url = await StorageService().pickAndUpload(folder: 'stores/${widget.store.id}/$folder');
    if (url == null) return 'cancelled';
    if (!mounted) return null;
    return StoreService.updateStoreFields(
      context.read<FirebaseFirestore>(),
      widget.store.id,
      {field: url},
    );
  }

  Future<void> _changeImage(String folder, String field, String label) async {
    if (_busy.contains(folder)) return;
    setState(() => _busy.add(folder));
    String? error;
    try {
      error = await _uploadImage(folder, field);
    } catch (e) {
      debugPrint('CoachStoreTab upload $folder failed: $e');
      error = 'Upload failed. Check your connection and try again.';
    }
    if (!mounted) return;
    setState(() => _busy.remove(folder));
    if (error == 'cancelled') return;
    _toast(error ?? '$label updated.');
    if (error == null) widget.onChanged();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final current = widget.store.orderDeadline;
    final initial = (current != null && !current.isBefore(today))
        ? current
        : today.add(const Duration(days: 14));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 730)),
      helpText: 'LAST DAY TO ORDER',
    );
    if (picked == null || !mounted) return;
    await _run(
      'deadline',
      () => StoreService.updateStoreFields(
        context.read<FirebaseFirestore>(),
        widget.store.id,
        {'orderDeadline': picked},
      ),
      'Order deadline set to ${Fmt.date(picked)}.',
    );
  }

  Future<void> _clearDeadline() async {
    await _run(
      'deadline',
      () => StoreService.updateStoreFields(
        context.read<FirebaseFirestore>(),
        widget.store.id,
        {'orderDeadline': null},
      ),
      'Order deadline removed.',
    );
  }

  Future<void> _saveDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    final fields = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'paymentInstructions': _paymentCtrl.text.trim(),
    };
    await _run(
      'details',
      () => StoreService.updateStoreFields(
        context.read<FirebaseFirestore>(),
        widget.store.id,
        fields,
      ),
      'Store details saved.',
    );
  }

  Future<void> _reopen() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Re-open store?'),
        content: const Text(
          'Customers will be able to order again. Orders already sent to production are not affected; new orders will go into your next master order.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('RE-OPEN')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _run(
      'reopen',
      () => StoreService.setStoreStatus(
        context.read<FirebaseFirestore>(),
        widget.store.id,
        StoreStatus.approved,
      ),
      'Store re-opened for orders.',
    );
  }

  /// Coach-facing explanation of why customers cannot order (null = open).
  String? _closedNotice(TeamStore s) {
    switch (s.closedReason) {
      case 'submitted_to_admin':
        return 'Your master order was sent to production. Customers cannot order until you re-open the store.';
      case 'pricing_review':
        return 'Pricing approval is still pending, so customers cannot order yet.';
      case 'deadline_passed':
        return 'The order deadline has passed. Set a new deadline to accept orders again.';
      case 'not_active':
        return 'This store is not open to customers.';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final store = widget.store;
    final notice = _closedNotice(store);
    final isOpen = notice == null;
    final days = store.daysLeft;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _LogoButton(
                url: store.logoPath,
                busy: _busy.contains('logo'),
                onTap: () => _changeImage('logo', 'logoPath', 'Logo'),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatusChip(
                          label: isOpen ? 'Open for orders' : (store.isLocked ? 'Order submitted' : 'Closed'),
                          color: isOpen ? Colors.green : (store.isLocked ? Colors.blue : Colors.orange),
                          icon: isOpen ? Icons.lock_open : Icons.lock_outline,
                        ),
                        if (isOpen && days != null)
                          StatusChip(
                            label: days == 0 ? 'Last day to order' : '$days days left',
                            color: days <= 3 ? Colors.red : Colors.blueGrey,
                            icon: Icons.schedule,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (notice != null) ...[
          const SizedBox(height: 12),
          _Notice(message: notice),
        ],
        const SizedBox(height: 16),
        _SectionTitle('Storefront images'),
        GlassPanel(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: (store.coverImagePath ?? '').isEmpty
                      ? Container(
                          color: Colors.black12,
                          alignment: Alignment.center,
                          child: const Text('No cover image yet'),
                        )
                      : AppImage(store.coverImagePath!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _busy.contains('cover')
                        ? null
                        : () => _changeImage('cover', 'coverImagePath', 'Cover image'),
                    icon: _busy.contains('cover')
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.image_outlined),
                    label: Text((store.coverImagePath ?? '').isEmpty ? 'ADD COVER' : 'CHANGE COVER'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy.contains('logo')
                        ? null
                        : () => _changeImage('logo', 'logoPath', 'Logo'),
                    icon: const Icon(Icons.account_circle_outlined),
                    label: Text((store.logoPath ?? '').isEmpty ? 'ADD LOGO' : 'CHANGE LOGO'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Ordering deadline'),
        GlassPanel(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const Icon(Icons.event),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  store.orderDeadline == null
                      ? 'No deadline - orders stay open until you submit.'
                      : 'Last day to order: ${Fmt.date(store.orderDeadline)}',
                ),
              ),
              if (store.orderDeadline != null)
                IconButton(
                  tooltip: 'Remove deadline',
                  onPressed: _busy.contains('deadline') ? null : _clearDeadline,
                  icon: const Icon(Icons.close),
                ),
              TextButton(
                onPressed: _busy.contains('deadline') ? null : _pickDeadline,
                child: Text(store.orderDeadline == null ? 'SET DATE' : 'CHANGE DATE'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionTitle('Store details'),
        GlassPanel(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Store name'),
                  validator: (v) =>
                      (v == null || v.trim().length < 3) ? 'Enter at least 3 characters.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Welcome message',
                    helperText: 'Shown to customers at the top of your store.',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _paymentCtrl,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Payment instructions',
                    helperText: 'How customers pay you (e.g. bank or e-wallet details).',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _busy.contains('details') ? null : _saveDetails,
                  icon: _busy.contains('details')
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: const Text('SAVE DETAILS'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/store/detail', arguments: store.id),
              icon: const Icon(Icons.visibility_outlined),
              label: const Text('VIEW AS CUSTOMER'),
            ),
            if (store.isLocked)
              ElevatedButton.icon(
                onPressed: _busy.contains('reopen') ? null : _reopen,
                icon: const Icon(Icons.lock_open),
                label: const Text('RE-OPEN STORE'),
              ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      );
}

class _Notice extends StatelessWidget {
  final String message;
  const _Notice({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class _LogoButton extends StatelessWidget {
  final String? url;
  final bool busy;
  final VoidCallback onTap;

  const _LogoButton({required this.url, required this.busy, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Change store logo',
      child: InkWell(
        onTap: busy ? null : onTap,
        borderRadius: BorderRadius.circular(40),
        child: SizedBox(
          width: 72,
          height: 72,
          child: ClipOval(
            child: busy
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : ((url ?? '').isEmpty
                    ? Container(
                        color: Colors.black12,
                        child: const Icon(Icons.add_a_photo_outlined),
                      )
                    : AppImage(url!, fit: BoxFit.cover, width: 72, height: 72)),
          ),
        ),
      ),
    );
  }
}
