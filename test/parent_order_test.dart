import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:commission_apparel_flutter/screens/public/parent_order_form_screen.dart';

import 'package:commission_apparel_flutter/services/auth_service.dart';

import 'package:commission_apparel_flutter/data/dummy_orders.dart';


void main() {
  late AuthService authService;

  setUp(() {
    authService = AuthService();
  });

  Widget createFormScreen(String storeId) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
      ],
      child: MaterialApp(
        home: ParentOrderFormScreen(storeId: storeId),
      ),
    );
  }

  testWidgets('Unavailable store shows closed screen (status, pricing, archived)', (WidgetTester tester) async {
    // store-4 is pending
    await tester.pumpWidget(createFormScreen('store-4'));
    
    expect(find.text('Store Closed'), findsOneWidget);
    expect(find.textContaining('This store is not accepting orders:'), findsOneWidget);
  });

  testWidgets('Active store can accept an order (renders form)', (WidgetTester tester) async {
    // store-1 is an active, approved, pricing_approved store with items
    await tester.pumpWidget(createFormScreen('store-1'));
    
    expect(find.text('Place Order'), findsOneWidget);
    expect(find.text('Athlete Information'), findsOneWidget);
    expect(find.text('SUBMIT ORDER'), findsOneWidget);
  });

  testWidgets('Required athlete information validation', (WidgetTester tester) async {
    await tester.pumpWidget(createFormScreen('store-1'));
    
    // Tap submit without filling anything
    await tester.ensureVisible(find.text('SUBMIT ORDER'));
    await tester.tap(find.text('SUBMIT ORDER'));
    await tester.pump();
    
    expect(find.text('Required'), findsWidgets); // First/Last name
  });

  testWidgets('Required gender validation', (WidgetTester tester) async {
    await tester.pumpWidget(createFormScreen('store-1'));
    
    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    
    // Submit without gender
    await tester.ensureVisible(find.text('SUBMIT ORDER'));
    await tester.tap(find.text('SUBMIT ORDER'));
    await tester.pump();
    
    // Form validation will show 'Required' under gender dropdown
    expect(find.text('Required'), findsOneWidget);
  });

  testWidgets('Item selection validation (must pick at least one)', (WidgetTester tester) async {
    await tester.pumpWidget(createFormScreen('store-1'));
    
    await tester.enterText(find.byType(TextFormField).at(0), 'John');
    await tester.enterText(find.byType(TextFormField).at(1), 'Doe');
    
    // Select Gender
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Male').last);
    await tester.pumpAndSettle();

    // Submit without picking items
    await tester.ensureVisible(find.text('SUBMIT ORDER'));
    await tester.tap(find.text('SUBMIT ORDER'));
    await tester.pump();
    
    expect(find.text('Please select at least one item.'), findsOneWidget);
  });

  testWidgets('Successful order creation and data preservation', (WidgetTester tester) async {
    final initialOrderCount = dummyParentOrders.length;

    await tester.pumpWidget(createFormScreen('store-1'));
    
    // 1. Athlete Info
    await tester.enterText(find.byType(TextFormField).at(0), 'Jane'); // First
    await tester.enterText(find.byType(TextFormField).at(1), 'Smith'); // Last
    
    // 2. Gender
    await tester.tap(find.byType(DropdownButtonFormField<String>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Female').last);
    await tester.pumpAndSettle();

    // 3. Optional Details
    await tester.enterText(find.byType(TextFormField).at(2), 'SMITH'); // Jersey Name
    await tester.enterText(find.byType(TextFormField).at(3), '42'); // Jersey Number
    
    // 4. Select Item (tap the ExpansionTile to select and expand it)
    final firstItemTile = find.byType(ExpansionTile).first;
    await tester.ensureVisible(firstItemTile);
    await tester.tap(firstItemTile);
    await tester.pumpAndSettle();

    // Fill all size dropdowns for the selected item
    final dropdownCount = find.byType(DropdownButtonFormField<String>).evaluate().length;
    for (int i = 1; i < dropdownCount; i++) {
      final finder = find.byType(DropdownButtonFormField<String>).at(i);
      await tester.ensureVisible(finder);
      await tester.tap(finder);
      await tester.pumpAndSettle();
      await tester.tap(find.text('M').last);
      await tester.pumpAndSettle();
    }

    // 5. Submit
    await tester.ensureVisible(find.text('SUBMIT ORDER'));
    await tester.tap(find.text('SUBMIT ORDER'));
    await tester.pumpAndSettle();

    // Check if there are validation errors on screen
    expect(find.text('Required'), findsNothing);
    expect(find.textContaining('Please complete sizing'), findsNothing);

    // Verify Success Dialog
    expect(find.text('Order Submitted'), findsOneWidget);
    
    // Verify Data Preservation
    expect(dummyParentOrders.length, initialOrderCount + 1);
    final newOrder = dummyParentOrders.last;
    expect(newOrder.athleteFirstName, 'Jane');
    expect(newOrder.athleteLastName, 'Smith');
    expect(newOrder.gender, 'Female');
    expect(newOrder.jerseyName, 'SMITH');
    expect(newOrder.jerseyNumber, '42');
    expect(newOrder.teamStoreId, 'store-1');
    expect(newOrder.itemEntries.isNotEmpty, true);
    
    // Cleanup
    dummyParentOrders.removeLast();
  });
}
