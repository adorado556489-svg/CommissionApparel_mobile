import 'package:commission_apparel_flutter/models/user.dart';
import 'package:commission_apparel_flutter/models/parent_order.dart';
import 'package:commission_apparel_flutter/models/team_store.dart';
import 'package:commission_apparel_flutter/models/store_item.dart';
import 'package:commission_apparel_flutter/models/store_item_comment.dart';
import 'package:commission_apparel_flutter/models/design_catalog.dart';
import 'package:commission_apparel_flutter/models/design_collection.dart';
import 'package:commission_apparel_flutter/models/landing_collection.dart';
import 'package:commission_apparel_flutter/models/testimonial.dart';
import 'package:commission_apparel_flutter/models/quote_request.dart';
import 'package:commission_apparel_flutter/models/site_setting.dart';
import 'package:commission_apparel_flutter/models/notification_item.dart';

List<User> dummyUsers = [];
List<ParentOrder> dummyParentOrders = [];
List<TeamStore> dummyTeamStores = [];
List<StoreItem> dummyStoreItems = [];
List<DesignCatalog> dummyDesignCatalog = [];
List<DesignCollection> dummyDesignCollections = [];
List<LandingCollection> dummyLandingCollections = [];
List<Testimonial> dummyTestimonials = [];
List<QuoteRequest> dummyQuoteRequests = [];
List<SiteSetting> dummySiteSettings = [];
List<Map<String, dynamic>> dummyPasswordResetLogs = [];
List<NotificationItem> dummyNotifications = [];
List<StoreItemComment> dummyStoreItemComments = [];

List<User> dummyCoaches = [];
List<User> dummyParents = [];


User dummyAdmin = User(id: 'admin', email: 'admin@example.com', firstName: 'Admin', lastName: 'Admin', role: UserRole.admin, password: '', createdAt: DateTime.now(), updatedAt: DateTime.now());
