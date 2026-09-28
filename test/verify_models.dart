import 'package:flutter_test/flutter_test.dart';
import 'fixtures/dummy_data.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/models/site_setting.dart';
import 'package:commission_apparel_flutter/models/design_catalog.dart';

void main() {
  group('Phase 2 — Model & Data Verification', () {
    test('Users: correct counts and computed properties', () {
      expect(rawdummyUsers.length, 7);
      expect(dummyAdmin.isAdmin, true);
      expect(dummyAdmin.isApproved, true);
      expect(dummyAdmin.fullName, 'Commission Apparel Admin');
      expect(rawdummyCoaches.length, 3);
      expect(rawdummyCoaches[0].isCoach, true);
      expect(rawdummyCoaches[0].organization, 'Riverside Academy');
      expect(rawdummyParents.length, 3);
      expect(rawdummyParents[0].isParent, true);
    });

    test('Design Catalog: collections and designs', () {
      expect(rawdummyDesignCollections.length, 3);
      expect(rawdummyDesignCatalog.length, 12);

      final packages = rawdummyDesignCatalog.where((d) => d.isPackage).toList();
      final individuals = rawdummyDesignCatalog.where((d) => !d.isPackage).toList();
      expect(packages.length, 2);
      expect(individuals.length, 10);

      expect(packages[0].categoryLabel, 'Package A');
      expect(packages[1].categoryLabel, 'Package B');
    });

    test('Design Catalog: static methods', () {
      expect(DesignCatalog.sizedTypes(), contains('Jersey'));
      expect(DesignCatalog.sizedTypes(), contains('Hoodie'));
      expect(DesignCatalog.sizeChart().keys, containsAll(['Youth', 'Adult']));
      expect(DesignCatalog.allSizes().length, 10);
    });

    test('Team Stores: lifecycle computed properties', () {
      expect(rawdummyTeamStores.where((s) => s.id.startsWith('store-')).length, 3);

      // Store 1: approved + pricing approved + not archived = live
      final store1 = rawdummyTeamStores[0];
      expect(store1.isLive, true);
      expect(store1.isAcceptingOrders, true);
      expect(store1.closedReason, null);

      // Store 2: approved but pricing NOT approved = not live
      final store2 = rawdummyTeamStores[1];
      expect(store2.isLive, false);
      expect(store2.closedReason, 'pricing_review');

      // Store 3: archived = not live
      final store3 = rawdummyTeamStores[2];
      expect(store3.isLive, false);
      expect(store3.closedReason, 'archived');
    });

    test('Store Items: pricing and package detection', () {
      expect(rawdummyStoreItems.where((i) => i.id.startsWith('item-')).length, 9);
      final store1Items = itemsForStore('store-1');
      expect(store1Items.length, 5);

      // Package item
      final pkg = store1Items.firstWhere((i) => i.id == 'item-1-pkg');
      expect(pkg.isPackage, true);
      expect(pkg.componentIds.length, 2);
      expect(pkg.marginPerUnit, 30.00); // 85 - 55
      expect(pkg.hasValidPricing, true);

      // Individual item
      final hoodie = store1Items.firstWhere((i) => i.id == 'item-1-hoodie');
      expect(hoodie.isPackage, false);
      expect(hoodie.marginPerUnit, 25.00); // 65 - 40
    });

    test('Store Item Comments: exist and have data', () {
      expect(dummyStoreItemComments.length, 2);
      expect(dummyStoreItemComments[0].storeItemId, 'item-1-jersey');
    });

    test('Parent Orders: status and computed properties', () {
      expect(rawdummyParentOrders.length, 5);
      expect(activeOrders.length, 4);
      expect(directOrders.length, 1);

      // Order 1: pending, editable
      final order1 = rawdummyParentOrders[0];
      expect(order1.athleteName, 'Carlos Martinez');
      expect(order1.totalRetailPrice, 150.00);
      expect(order1.isEditable, true);
      expect(order1.isDirectOrder, false);
      expect(order1.totalItemCount, 2);

      // Order 3: batched
      final order3 = rawdummyParentOrders[2];
      expect(order3.isBatched, true);
      expect(order3.batchId, 'batch-2024-06-001');
      expect(order3.totalItemCount, 4); // 1 pkg + 1 hoodie + 2 shirts

      // Order 4: direct order
      final order4 = rawdummyParentOrders[3];
      expect(order4.isDirectOrder, true);
      expect(order4.userId, null);
    });

    test('Parent Orders: package entry has components', () {
      final order1 = rawdummyParentOrders[0];
      final pkgEntry = order1.itemEntries[0];
      expect(pkgEntry.isPackage, true);
      expect(pkgEntry.components.length, 2);
      expect(pkgEntry.components[0].name, 'Riverside Basketball Jersey');
      expect(pkgEntry.sizes['Jersey'], 'L');
    });

    test('Batch Financials: calculates correctly', () {
      final batchOrders = ordersInBatch('batch-2024-06-001');
      expect(batchOrders.length, 1);

      final store1Items = itemsForStore('store-1');
      final retailMap = buildRetailPriceMap(store1Items);
      final wholesaleMap = buildWholesalePriceMap(store1Items);

      final financials = ParentOrder.calculateBatchFinancials(
        orders: batchOrders,
        retailPrices: retailMap,
        wholesalePrices: wholesaleMap,
      );

      expect(financials.orderCount, 1);
      expect(financials.totalSales, 240.00);
      expect(financials.totalItemsSold, 4);
      expect(financials.totalWholesaleCost, greaterThan(0));
      expect(financials.netProceeds, greaterThan(0));
    });

    test('Landing Collections: active content', () {
      expect(rawdummyLandingCollections.length, 4);
      expect(
        rawdummyLandingCollections.every((c) => c.isActive),
        true,
      );
    });

    test('Testimonials: active content', () {
      expect(rawdummyTestimonials.length, 3);
      expect(rawdummyTestimonials.every((t) => t.isActive), true);
    });

    test('Site Settings: lookup helpers', () {
      expect(
        SiteSetting.getValue(rawdummySiteSettings, 'hero_title'),
        'CUSTOM TEAM APPAREL MADE EASY',
      );
      expect(
        SiteSetting.getValue(rawdummySiteSettings, 'contact_email'),
        'info@commissionapparel.com',
      );
      expect(
        SiteSetting.getValueOr(rawdummySiteSettings, 'missing_key', 'fallback'),
        'fallback',
      );
    });

    test('Quote Requests: status checks', () {
      expect(rawdummyQuoteRequests.length, 3);
      expect(rawdummyQuoteRequests.where((q) => q.isNew).length, 2);
      expect(rawdummyQuoteRequests.where((q) => q.isAddressed).length, 1);
      expect(rawdummyQuoteRequests[0].fullName, 'Michael Thompson');
    });

    test('Notifications: read/unread state', () {
      expect(rawdummyNotifications.length, 9);
      expect(unreadNotificationsForUser('user-admin-1').length, 2);
      expect(notificationsForUser('user-coach-1').length, 4);
      expect(unreadNotificationsForUser('user-coach-1').length, 2);

      // Mark as read
      final notif = rawdummyNotifications.firstWhere((n) => n.isUnread);
      final readNotif = notif.markAsRead();
      expect(readNotif.isRead, true);
      expect(readNotif.readAt, isNotNull);
    });
  });
}

