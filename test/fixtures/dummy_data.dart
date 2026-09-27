/// Central registry for all dummy data.
///
/// Import this single file to access all temporary in-memory data.
/// Each data file can also be imported individually.
///
/// This module will be replaced by Firebase Firestore service calls
/// in a later phase.
library;

export 'dummy_users.dart';
export 'dummy_catalog.dart';
export 'dummy_stores.dart';
export 'dummy_orders.dart';
export 'dummy_content.dart';
export 'dummy_quotes.dart';
export 'dummy_notifications.dart';
