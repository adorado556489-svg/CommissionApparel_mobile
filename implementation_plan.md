# Firebase Implementation Plan (Planning Phase)

## 1. Current Architecture
The application is a pure Flutter frontend that mirrors the Laravel business logic using static in-memory data structures. State is managed via `ChangeNotifier` (e.g., `AuthService`), and data mutations are handled by singleton-like service classes (`AdminService`, `OrderService`) acting on arrays in `dummy_*.dart` files. Media relies on `image_picker` local paths. There is no active network backend.

## 2. Firebase Architecture Overview
We will replace the in-memory arrays and local paths with a serverless Firebase architecture:
- **Firebase Authentication**: Will act as the system of record for identity and session management, replacing the dummy `currentUser`.
- **Cloud Firestore**: Will replace all `dummy_*.dart` arrays. Top-level collections will store documents, matching the flattened relational structure of the Laravel MySQL database.
- **Firebase Storage**: Will hold all uploaded media (logos, hero images, design catalog images), replacing local file paths with remote download URLs.

## 3. Authentication Plan
- **Primary Auth**: `FirebaseAuth.instance` will handle Email/Password login, registration, and logout.
- **Role Management**: User roles (Admin, Coach, Parent) will be stored as fields in the `users` Firestore document rather than using Custom Claims, keeping implementation simple and queryable for the Admin dashboard.
- **Password Reset Flow**: 
  - *Risk/Mismatch*: Laravel uses a custom reset flow requiring Phone and Organization matches before allowing a password change in the app. Firebase Auth natively uses an email-link flow.
  - *Strategy*: We will implement a hybrid approach. The app will verify the Phone and Organization against the `users` Firestore document. Upon success, an audit log is written to `passwordResetLogs`, and the app will trigger Firebase's `sendPasswordResetEmail()`. We will avoid a Cloud Function (which would be required to silently change the password client-side) to minimize external dependencies.

## 4. Firestore Schema & Data Model
*We will use top-level collections with String ID references instead of deep subcollections to allow Admin global queries.*

| Collection | Document ID | Key Fields & Types |
| :--- | :--- | :--- |
| `users` | `uid` (from Auth) | email, firstName, lastName, role, status, phone, organization, createdAt |
| `teamStores` | auto-ID | userId (string), name, slug, orderDeadline (Timestamp), status, isArchived |
| `storeItems` | auto-ID | teamStoreId (string), designCatalogId (string), retailPrice (double), isPackage (bool), packageComponentIds (Array of strings) |
| `parentOrders` | auto-ID | teamStoreId (nullable string), userId (nullable string for direct orders), athleteName, items (Array of Maps), status, isArchived, batchId |
| `designCatalog` | auto-ID | name, collectionId (string), multiType, sport, wholesalePrice, imagePath |
| `designCollections`| auto-ID | name, sortOrder (int) |
| `landingCollections`| auto-ID | title, subtitle, isActive, imagePath, sortOrder |
| `coachUploads` | auto-ID | userId (string), imagePath, description |
| `quoteRequests` | auto-ID | name, email, phone, organization, details, status |
| `testimonials` | auto-ID | clientName, organization, review, imagePath, isActive |
| `siteSettings` | auto-ID | key (string), value (string) |
| `notifications` | auto-ID | userId (string), title, body, readAt (nullable Timestamp) |

## 5. Relationship Migration
- **Document ID References**: Most relationships (User -> Stores, Store -> Orders) will use stored String IDs (e.g., `teamStoreId: "xyz"`) rather than `DocumentReference` objects. This makes JSON serialization cleaner.
- **Arrays vs Pivot Tables**: Laravel's `package_store_items` pivot table will be replaced by a simple Array field `packageComponentIds` on the `storeItems` document. 
- **Array of Maps**: Laravel's `ParentOrder` JSON items column will seamlessly translate to an Array of Maps in Firestore (`items: [{id: 1, qty: 2, sizes: {}}]`).

## 6. Cascade / Delete Behavior
Firestore lacks MySQL's foreign-key cascade capability.
- *Strategy*: We will reproduce the Phase 9 cleanup logic using **Firestore Batched Writes**.
- *Example (Deleting a Coach)*: 
  1. The `AdminService` queries all `teamStores` where `userId == coachId`.
  2. It queries all `parentOrders` tied to those stores, plus direct orders tied to the coach.
  3. It batches the deletion of the orders, stores, and the user document.
  *(Note: Cloud Functions with `onDelete` triggers are the enterprise solution, but Batched Writes keep the project purely in Dart).*
- *Storage Deletion*: Deleting a document with an image (e.g., Testimonial) must explicitly call `FirebaseStorage.instance.refFromURL().delete()` before deleting the document.

## 7. Storage Structure
Paths will be strictly categorized:
- `/hero_media/{docId}.jpg`
- `/coach_logos/{uid}.jpg`
- `/store_covers/{storeId}.jpg`
- `/catalog/{designId}.jpg`
- `/testimonials/{testimonialId}.jpg`

## 8. Security Model (Firestore Rules Strategy)
- **`users`**: Read by authenticated. Write by Admin, or self (excluding `role` edits).
- **`teamStores`**: Read by public. Create/Update by Admin, or owning Coach.
- **`parentOrders`**: Read by Admin, or owning Coach (via `teamStoreId`/`userId`). Create by public/authenticated. Update/Delete by Admin, or owning Coach.
- **`designCatalog` / `testimonials`**: Read by public. Write by Admin.
- **Validation**: Rules must enforce that users cannot escalate their own `role` field.

## 9. Search Strategy
- **Laravel Behavior**: Uses relational SQL queries for store names, coaches, sports.
- **Firebase Approach**: Since the number of Active Stores is relatively small, we will fetch active stores and perform string-matching/filtering in Dart client-side. This avoids the cost/complexity of Algolia or trigram index maps.

## 10. Realtime Strategy
- **One-time reads (`Future<Get>`)**: Catalog, Site Settings, Quotes, Testimonials.
- **Realtime Listeners (`snapshots()`)**: 
  - Admin Dashboard batches & pending stores.
  - Coach Dashboard incoming orders.
  - User Notifications.

## 11. Index Requirements
We will require composite indexes in `firestore.indexes.json` for:
- `teamStores`: `userId` (ASC) + `createdAt` (DESC)
- `parentOrders`: `teamStoreId` (ASC) + `createdAt` (DESC)
- `parentOrders`: `batchId` (ASC) + `isArchived` (ASC)

## 12. Dummy-Data Migration Strategy
- Create a temporary `DummySeederService` with a hidden developer button.
- The service will loop through `dummyUsers`, `dummyTeamStores`, etc., and execute `.set()` on Firestore using the *exact same string IDs* from the dummy files.
- This ensures all relational foreign keys remain perfectly intact upon migration. Once verified, `dummy_*.dart` files will be deleted.

## 13. Service & Model Migration
- **Models**: Add `factory Model.fromFirestore(DocumentSnapshot doc)` and `Map<String, dynamic> toFirestore()`. Handle `DateTime` to `Timestamp` conversions.
- **Services**: `AdminService`, `OrderService`, and `AuthService` will be injected with Firestore/FirebaseAuth instances, replacing array `.where` searches with `.where().get()` queries.

## 14. Testing Strategy
- The current 73 passing tests rely on synchronous memory arrays.
- *Strategy*: We will introduce the `fake_cloud_firestore` and `firebase_auth_mocks` packages. This allows our existing 73 tests to run synchronously against a local mocked Firestore instance, proving the Firestore Service layers without needing the cumbersome Firebase Local Emulator Suite.

## 15. Deferred Features & Risks
- **Hero Video**: Remains deferred. Firebase Storage can hold `.mp4` files, but it requires adding the `video_player` Flutter dependency which was previously rejected.
- **CSV Export**: Remains stubbed.
- **StoreItemComment**: Remains deferred (not in Laravel views).
- **Major Risk**: Batch limits (500 docs per batch). If a coach has >500 orders, client-side cascading deletes will require chunking. 

## 16. Proposed Implementation Phases
- **Phase A**: Add Firebase dependencies (`firebase_core`, `cloud_firestore`, `firebase_auth`, `firebase_storage`). Do not initialize yet.
- **Phase B**: Update Models with `fromFirestore` and `toFirestore`.
- **Phase C**: Transition Tests to `fake_cloud_firestore`.
- **Phase D**: Migrate `AuthService` to Firebase Auth.
- **Phase E**: Migrate `AdminService` and `OrderService` to Firestore.
- **Phase F**: Migrate local image pickers to Firebase Storage.
- **Phase G**: Run Dummy Seeder, wipe dummy files, configure Security Rules.
