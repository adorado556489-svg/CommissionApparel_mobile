import 'dart:io';

void main() {
  var file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "Text(_activeStore!.name, style: Theme.of(context).textTheme.headlineSmall),",
    "if (_activeStore == null) const Text('No Active Store') else ...[\nText(_activeStore!.name, style: Theme.of(context).textTheme.headlineSmall),"
  );
  content = content.replaceAll(
    "Text(_activeStore!.isLive ? 'LIVE' : _activeStore!.isLocked ? 'LOCKED' : _activeStore!.status.toUpperCase()),\n              if (_activeStore!.status == 'submitted_to_admin') const Text('MASTER ORDER SUBMITTED'),\n            ]\n          ),\n          const SizedBox(height: 24),\n          StreamBuilder<List<ParentOrder>>(",
    "Text(_activeStore!.isLive ? 'LIVE' : _activeStore!.isLocked ? 'LOCKED' : _activeStore!.status.toUpperCase()),\n              if (_activeStore!.status == 'submitted_to_admin') const Text('MASTER ORDER SUBMITTED'),\n            ],\n          ],\n          const SizedBox(height: 24),\n          if (_activeStore != null) StreamBuilder<List<ParentOrder>>("
  );
  
  // Wait, I need to make sure the if structure closes properly.
}
