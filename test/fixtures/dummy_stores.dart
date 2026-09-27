import 'package:commission_apparel_flutter/services/dummy_fallbacks.dart' as f;
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/store_item.dart';
import 'package:commission_apparel_flutter/models/store_item_comment.dart';

/// Dummy team stores: one active, one pending pricing, one archived.
final List<TeamStore> rawdummyTeamStores = [
  TeamStore(
    id: 'store-1',
    userId: 'user-coach-1',
    name: 'Riverside Academy Basketball',
    slug: 'riverside-academy-basketball',
    description: '2024-2025 season basketball gear for Riverside Academy.',
    orderDeadline: DateTime.now().add(const Duration(days: 30)),
    status: 'approved',
    packageType: 'package_a',
    pricingApproved: true,
    createdAt: DateTime(2024, 3, 1),
    updatedAt: DateTime(2024, 6, 15),
  ),
  TeamStore(
    id: 'store-2',
    userId: 'user-coach-2',
    name: 'Northview Football Program',
    slug: 'northview-football-program',
    description: 'Northview High School football uniforms and team gear.',
    orderDeadline: DateTime.now().add(const Duration(days: 45)),
    status: 'approved',
    packageType: 'package_b',
    pricingApproved: false,
    createdAt: DateTime(2024, 4, 10),
    updatedAt: DateTime(2024, 7, 1),
  ),
  TeamStore(
    id: 'store-3',
    userId: 'user-coach-1',
    name: 'Summer Hoops Camp 2024',
    slug: 'summer-hoops-camp-2024',
    description: 'Summer basketball camp apparel - event has concluded.',
    orderDeadline: DateTime(2024, 7, 15),
    status: 'approved',
    packageType: 'individual',
    pricingApproved: true,
    isArchived: true,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 8, 1),
  ),
  TeamStore(
    id: 'store-4',
    userId: 'user-coach-2',
    name: 'Pending School Store',
    slug: 'pending-school-store',
    description: 'Awaiting admin approval.',
    orderDeadline: DateTime.now().add(const Duration(days: 14)),
    status: 'pending',
    packageType: 'individual',
    pricingApproved: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  TeamStore(
    id: 'store-5',
    userId: 'user-admin-1',
    name: 'TCA Fall Campaign',
    slug: 'tca-fall-campaign',
    description: 'Official Commission Apparel Campaign.',
    orderDeadline: DateTime.now().add(const Duration(days: 60)),
    status: 'approved',
    packageType: 'individual',
    pricingApproved: true,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

final List<StoreItem> rawdummyStoreItems = [
  StoreItem(
    id: 'item-1-pkg',
    teamStoreId: 'store-1',
    designCatalogId: 'cat-1',
    name: 'Game Day Package',
    types: const ['Jersey', 'Shorts'],
    imagePaths: const ['assets/images/placeholder.png'],
    wholesalePrice: 65.0,
    retailPrice: 85.0,
    sortOrder: 1,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
    componentIds: const ['item-1-jersey', 'item-1-shorts'],
  ),
  StoreItem(
    id: 'item-1-jersey',
    teamStoreId: 'store-1',
    designCatalogId: 'cat-2',
    name: 'Riverside Basketball Jersey',
    types: const ['Jersey'],
    imagePaths: const ['assets/images/placeholder.png'],
    wholesalePrice: 40.0,
    retailPrice: 50.0,
    sortOrder: 2,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
    componentIds: const [],
  ),
  StoreItem(
    id: 'item-1-shorts',
    teamStoreId: 'store-1',
    designCatalogId: 'cat-3',
    name: 'Riverside Basketball Shorts',
    types: const ['Shorts'],
    imagePaths: const ['assets/images/placeholder.png'],
    wholesalePrice: 25.0,
    retailPrice: 35.0,
    sortOrder: 3,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
    componentIds: const [],
  ),
  StoreItem(
    id: 'item-1-hoodie',
    teamStoreId: 'store-1',
    designCatalogId: 'cat-4',
    name: 'Riverside Team Hoodie',
    types: const ['Hoodie'],
    imagePaths: const ['assets/images/placeholder.png'],
    wholesalePrice: 50.0,
    retailPrice: 65.0,
    sortOrder: 4,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
    componentIds: const [],
  ),
  StoreItem(
    id: 'item-1-shooting',
    teamStoreId: 'store-1',
    designCatalogId: 'cat-5',
    name: 'Riverside Shooting Shirt',
    types: const ['T-Shirt'],
    imagePaths: const ['assets/images/placeholder.png'],
    wholesalePrice: 35.0,
    retailPrice: 45.0,
    sortOrder: 5,
    createdAt: DateTime(2024, 5, 1),
    updatedAt: DateTime(2024, 5, 1),
    componentIds: const [],
  ),
];

final List<StoreItemComment> rawdummyStoreItemComments = [
  StoreItemComment(
    id: 'comment-1',
    storeItemId: 'item-1-jersey',
    userId: 'user-coach-1',
    comment: 'Can we make the team logo slightly larger on the chest?',
    createdAt: DateTime(2024, 5, 5, 10, 30),
  ),
  StoreItemComment(
    id: 'comment-2',
    storeItemId: 'item-1-jersey',
    userId: 'user-admin-1',
    comment: 'Yes, we have adjusted the proof. Please review.',
    createdAt: DateTime(2024, 5, 6, 14, 15),
  ),
];

List<StoreItem> itemsForStore(String storeId) =>
    dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();

Map<String, double> buildRetailPriceMap(List<StoreItem> items) {
  return {for (final item in items) item.id: item.retailPrice};
}

Map<String, double> buildWholesalePriceMap(List<StoreItem> items) {
  return {for (final item in items) item.id: item.wholesalePrice};
}

List<TeamStore> get dummyTeamStores => f.dummyTeamStores;

List<StoreItem> get dummyStoreItems => f.dummyStoreItems;

List<StoreItemComment> get dummyStoreItemComments => f.dummyStoreItemComments;
