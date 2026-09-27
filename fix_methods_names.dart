import 'dart:io';

void main() {
  final file = File('lib/screens/coach/coach_dashboard_screen.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  // Fix updateStoreDeadline
  content = content.replaceAll(
    'await StoreService.updateStoreDeadline(context.read<FirebaseFirestore>(), _activeStore!.id, date);',
    'await StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(orderDeadline: date));'
  );

  // Fix updateStorePricingStatus
  content = content.replaceAll(
    'await StoreService.updateStorePricingStatus(context.read<FirebaseFirestore>(), _activeStore!.id, true);',
    'await StoreService.updateStore(context.read<FirebaseFirestore>(), _activeStore!.copyWith(pricingApproved: true));'
  );
  
  // Fix addStoreItem
  content = content.replaceAll(
    'await StoreService.addStoreItem(',
    'await StoreService.createStoreItem('
  );
  
  // Fix removeStoreItem
  content = content.replaceAll(
    'await StoreService.removeStoreItem(',
    'await StoreService.deleteStoreItem('
  );
  
  // Fix updateItemMarkup
  content = content.replaceAll(
    'await StoreService.updateItemMarkup(context.read<FirebaseFirestore>(), item.id, item.retailPrice + amount);',
    'await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), item.copyWith(retailPrice: item.retailPrice + amount));'
  );
  content = content.replaceAll(
    'await StoreService.updateItemMarkup(context.read<FirebaseFirestore>(), item.id, retailPrice);',
    'await StoreService.updateStoreItem(context.read<FirebaseFirestore>(), item.copyWith(retailPrice: retailPrice));'
  );

  // Fix updateStoreStatus
  content = content.replaceAll(
    "await StoreService.updateStoreStatus(firestore, _activeStore!.id, 'submitted_to_admin');",
    "await StoreService.updateStore(firestore, _activeStore!.copyWith(status: 'submitted_to_admin'));"
  );
  
  // Fix basePrice -> wholesalePrice
  content = content.replaceAll('design.basePrice', 'design.wholesalePrice');

  file.writeAsStringSync(content);
}
