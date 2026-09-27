import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix Checkpoint E arguments for finalizeDirectOrders and archiveDirectOrderBatch
  content = content.replaceFirst(
    '''final error = await OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);''',
    '''final error = await OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);'''
  ); // Wait, if I already replaced it?
  
  content = content.replaceAll(
    'final error = await OrderService.finalizeDirectOrders(user);',
    'final error = await OrderService.finalizeDirectOrders(context.read<FirebaseFirestore>(), user);'
  );
  content = content.replaceAll(
    'await OrderService.archiveDirectOrderBatch(user, e.key);',
    'await OrderService.archiveDirectOrderBatch(context.read<FirebaseFirestore>(), user, e.key);'
  );
  
  file.writeAsStringSync(content);
}
