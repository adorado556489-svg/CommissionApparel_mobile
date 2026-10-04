# B2B2C Architecture & Business Logic Analysis Report

This document provides a comprehensive analysis of the current CommissionApparel codebase to verify its adherence to the multi-vendor (B2B2C) SaaS e-commerce architecture requested. 

No code changes were made during this analysis phase.

---

## 1. Normal User (The Customer / Parent)
**Role Description**: The end consumer who browses stores, adds items to their cart, and submits orders.

| Feature Requirement | Current Implementation Status | Verification Notes |
| :--- | :--- | :--- |
| **Browse Stores & Catalogs** | ✅ Implemented | Users browse specific team stores via `UserDashboardScreen` and `StoreScreen`. The products displayed are strictly bound to the `teamStoreId`. |
| **Shopping Cart & Checkout** | ✅ Implemented | Orders are processed via `ParentOrderFormScreen` which strictly ties the purchase back to the specific store and user ID. |
| **Order History & Tracking** | ✅ Implemented | Users view history via `UserDashboardScreen` (Orders Tab), utilizing `OrderService.getUserOrders`. |
| **(Suggested) Direct Support** | ⏳ Not Implemented | Currently out of scope as a "suggested feature". No messaging protocol exists between User and Coach yet. |

---

## 2. Coach / Upgraded User (The Merchant / Creator)
**Role Description**: The entrepreneur running the team store, creating custom products from master blanks.

| Feature Requirement | Current Implementation Status | Verification Notes |
| :--- | :--- | :--- |
| **Store Management** | ✅ Implemented | `CoachDashboardScreen` (Store & Orders Tab) handles store cover images, metadata, and payment instructions. |
| **Product & Design Creation** | ✅ Implemented | `CoachCatalogTab` allows Coaches to browse Admin Blanks, upload custom artwork to Cloudinary, and save them as `DesignCatalog` items strictly bound by `coachId == currentUser.id`. |
| **Collection Management** | ✅ Implemented | `CoachCollectionsTab` supports grouping these custom designs into isolated `DesignCollection`s bound to the Coach's ID. |
| **Pricing & Commission Calculator** | ✅ Implemented | When adding a custom design to their store, the Coach sees the Admin's `wholesalePrice` (Base Cost) and inputs their `retailPrice`. The Coach Dashboard actively computes the margin (`retailPrice - wholesalePrice`). |
| **Customer Order Dashboard** | ✅ Implemented | Coaches review all unbatched `ParentOrder`s tied to their store, including tracking who is marked as `isPaid` before submitting the Master Roster. |
| **(Suggested) Financials / Wallet** | 🟨 Partially Implemented | A dedicated "Wallet" route does not exist, but the active commission calculations are visible on the Coach Dashboard overview. |

---

## 3. Admin (The Platform Operator / Factory)
**Role Description**: The overarching business owner who provides blanks, fulfills orders, and tracks platform revenue.

| Feature Requirement | Current Implementation Status | Verification Notes |
| :--- | :--- | :--- |
| **Store & Account Approvals** | ✅ Implemented | `AdminDashboardScreen` dynamically queries `StoreService.getPendingStores` allowing Admins to approve stores and automatically upgrade users to the `coach` role. |
| **Master Blank Catalog** | ✅ Implemented | Admins create global `DesignCatalog` items where `coachId == null`. These act as the immutable "Blank Products" for the platform. |
| **Master Order Fulfillment** | ✅ Implemented | Admins view "Submitted Master Orders" (batched). Pressing **"Mark Addressed"** updates statuses to `Processing`, archives the batch, and pushes Cloud Firestore Notifications to all associated parents. |
| **Financial / Commission Mgmt** | ✅ Implemented | `AdminDashboardScreen` utilizes `calculateBatchFinancials` to expose Gross Revenue, Platform Revenue, and Coach Commission per submitted batch. |
| **(Suggested) Global Analytics** | ⏳ Not Implemented | High-level data analysis views (e.g., charts, historical graphs) are out of scope as a "suggested feature". |

---

## 4. Data Analyst Considerations
**Requirement**: Capture historical snapshots of pricing so that future changes to the "Base Cost" of a blank do not corrupt the historical profit/commission margins of past orders.

- **Status**: ✅ **Securely Implemented**
- **Verification**: `OrderItemEntry` in `lib/models/parent_order.dart` was expanded to natively store `retailPrice` and `wholesalePrice`. When an order is placed, these fields snapshot the *exact* pricing values at that millisecond. 
- The financial calculator `ParentOrder.calculateBatchFinancials` was successfully re-routed to aggregate data exclusively from these historical snapshots rather than querying volatile live catalogs.

---

## 5. QA Considerations (Security & RBAC)
**Requirement**: Strict tenant isolation (Coaches cannot see other Coaches' data) and robust state management.

- **Status**: ✅ **Securely Implemented**
- **Verification**: 
  - **Tenant Isolation**: `CatalogService` enforces `where('coachId', isEqualTo: coachId)` preventing cross-contamination of custom designs. Firestore rules test suite (`firestore_rules_test.dart`) confirms strict document segregation.
  - **State Management**: Once a Coach submits a Master Roster, the store's state transitions to `submitted_to_admin` (locking further edits to the batch) and the Admin's fulfillment loop transitions the `ParentOrder` statuses to `Processing`.

---

### Final Verdict
The system correctly models a highly scalable B2B2C architecture. The codebase is thoroughly linted (`flutter analyze` returns 0 functional errors) and the unit testing suite passes. No critical flaws were found in the current structural implementation of these roles.
