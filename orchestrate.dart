import 'dart:io';

void replace(String file, String from, String to) {
  var f = File(file);
  var s = f.readAsStringSync();
  f.writeAsStringSync(s.replaceAll(from, to));
}

void main() {
  // StoreService
  replace('lib/services/store_service.dart',
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      try { return dummyTeamStores.firstWhere((s) => s.userId == coachId && !s.isArchived); } catch (_) { return null; }",
    "        return null;\n      } catch (e) { _handleError(e, \"StoreService\"); return null; }"
  );
  replace('lib/services/store_service.dart',
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'approved').toList();",
    "        return [];\n      } catch (e) { _handleError(e, \"StoreService\"); return []; }"
  );
  replace('lib/services/store_service.dart',
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyTeamStores.where((s) => !s.isArchived && s.status == 'campaign').toList();",
    "        return [];\n      } catch (e) { _handleError(e, \"StoreService\"); return []; }"
  );
  replace('lib/services/store_service.dart',
    "    } catch (e) { _handleError(e, \"StoreService\");  }\n    try { return dummyTeamStores.firstWhere((s) => s.id == storeId); } catch (_) { return null; }",
    "      return null;\n    } catch (e) { _handleError(e, \"StoreService\"); return null; }"
  );
  replace('lib/services/store_service.dart',
    "      if (snapshot.docs.isEmpty) {\n        return dummyTeamStores.where((s) => s.status == 'pending').toList();\n      }",
    "      if (snapshot.docs.isEmpty) return [];"
  );
  replace('lib/services/store_service.dart',
    "    } catch (_) {\n      return dummyTeamStores.where((s) => s.status == 'pending').toList();\n    }",
    "    } catch (e) { _handleError(e, \"StoreService\"); return []; }"
  );
  replace('lib/services/store_service.dart',
    "    try {\n      dummyTeamStores.add(store);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "    try {\n      final idx = dummyTeamStores.indexWhere((s) => s.id == store.id);\n      if (idx != -1) dummyTeamStores[idx] = store;\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "    try {\n      dummyTeamStores.removeWhere((s) => s.userId == coachId);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "      } catch (e) { _handleError(e, \"StoreService\");  }\n      return dummyStoreItems.where((i) => i.teamStoreId == storeId).toList();",
    "        return [];\n      } catch (e) { _handleError(e, \"StoreService\"); return []; }"
  );
  replace('lib/services/store_service.dart',
    "    try {\n      dummyStoreItems.add(item);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "    try {\n      final idx = dummyStoreItems.indexWhere((i) => i.id == item.id);\n      if (idx != -1) dummyStoreItems[idx] = item;\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "    try {\n      dummyStoreItems.removeWhere((i) => i.id == itemId);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/store_service.dart',
    "    try { return dummyUsers.firstWhere((u) => u.id == store.userId); } catch (_) { return null; }",
    "    return null;"
  );
  replace('lib/services/store_service.dart', "import '../data/dummy_stores.dart';", "");
  replace('lib/services/store_service.dart', "import '../data/dummy_users.dart';", "");

  // CatalogService
  replace('lib/services/catalog_service.dart',
    "    try { return dummyDesignCollections; } catch (_) { return []; }",
    "    return [];"
  );
  replace('lib/services/catalog_service.dart',
    "    try { return dummyDesignCatalog; } catch (_) { return []; }",
    "    return [];"
  );
  replace('lib/services/catalog_service.dart',
    "    try { return dummyDesignCatalog.firstWhere((d) => d.id == designId); } catch (_) { return null; }",
    "    return null;"
  );
  replace('lib/services/catalog_service.dart',
    "    } catch (_) {\n      return dummyDesignCatalog.where((d) => collection.designIds.contains(d.id)).toList();\n    }",
    "    } catch (e) { _handleError(e, 'CatalogService'); return []; }"
  );
  replace('lib/services/catalog_service.dart', "import '../data/dummy_catalog.dart';", "");
  
  // ContentService
  replace('lib/services/content_service.dart',
    "    } catch (_) {\n      final notifs = dummyNotifications.where((n) => n.userId == userId).toList();\n      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));\n      return notifs;\n    }",
    "    } catch (e) { _handleError(e, 'ContentService'); return []; }"
  );
  replace('lib/services/content_service.dart',
    "    } catch (_) {}\n    return dummyNotifications.where((n) => n.userId == userId).toList();",
    "    } catch (e) { _handleError(e, 'ContentService'); return []; }"
  );
  replace('lib/services/content_service.dart',
    "    try {\n      final dummyIndex = dummyNotifications.indexWhere((n) => n.id == notificationId);\n      if (dummyIndex != -1) {\n        dummyNotifications[dummyIndex] = dummyNotifications[dummyIndex].copyWith(isRead: true);\n      }\n    } catch (_) {}",
    ""
  );
  replace('lib/services/content_service.dart', "import '../data/dummy_notifications.dart';", "");
  replace('lib/services/content_service.dart', "import '../data/dummy_content.dart';", "");

  // AuthService
  replace('lib/services/auth_service.dart',
    "      } catch (e) {\n        _handleError(e, 'AuthService');\n        final index = dummyUsers.indexWhere(\n          (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),\n        );\n        _currentUser = index != -1 ? dummyUsers[index] : null;\n      }",
    "      } catch (e) {\n        _handleError(e, 'AuthService');\n        _currentUser = null;\n      }"
  );
  replace('lib/services/auth_service.dart',
    "      } else {\n        // Fallback to dummy data (Phase 5 migration compatibility)\n        final index = dummyUsers.indexWhere(\n          (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),\n        );\n        if (index != -1) {\n          _currentUser = dummyUsers[index];\n        } else {\n          _currentUser = null;\n        }\n      }",
    "      } else {\n        _currentUser = null;\n      }"
  );
  replace('lib/services/auth_service.dart',
    "    } catch (e) {\n      // Fallback for tests\n      final index = dummyUsers.indexWhere(\n        (u) => u.email.toLowerCase() == firebaseUser.email?.toLowerCase(),\n      );\n      _currentUser = index != -1 ? dummyUsers[index] : null;\n    }",
    "    } catch (e) {\n      _handleError(e, 'AuthService');\n      _currentUser = null;\n    }"
  );
  replace('lib/services/auth_service.dart',
    "      } else {\n        // Fallback to dummy users\n        final index = dummyUsers.indexWhere(\n          (u) => u.email.toLowerCase() == normalizedEmail,\n        );\n        if (index == -1) {\n          return 'Invalid email or password.';\n        }\n        if (dummyUsers[index].status == 'declined') {\n          return 'Your account has been declined. Please contact support.';\n        }\n      }",
    "      }"
  );
  replace('lib/services/auth_service.dart',
    "    } catch (e) {\n      // Fallback\n      final index = dummyUsers.indexWhere(\n        (u) => u.email.toLowerCase() == normalizedEmail,\n      );\n      if (index == -1) return 'Invalid email or password.';\n      if (dummyUsers[index].status == 'declined') {\n        return 'Your account has been declined. Please contact support.';\n      }\n    }",
    "    } catch (e) {\n      _handleError(e, 'AuthService.login');\n      return 'Invalid email or password.';\n    }"
  );
  replace('lib/services/auth_service.dart',
    "    try {\n      dummyUsers.add(newUser);\n    } catch (_) {}",
    ""
  );
  replace('lib/services/auth_service.dart',
    "      // Fallback lookup\n      final dummyIndex = dummyUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);\n      if (dummyIndex != -1) {\n        matchedUser = dummyUsers[dummyIndex];\n      }",
    ""
  );
  replace('lib/services/auth_service.dart',
    "    try {\n      dummyPasswordResetLogs.add(PasswordResetLog(\n        id: 'pwd-reset-${DateTime.now().millisecondsSinceEpoch}',\n        userId: matchedUser.id,\n        email: matchedUser.email,\n        requestedAt: DateTime.now(),\n        status: 'pending',\n      ));\n    } catch (_) {}",
    ""
  );
  replace('lib/services/auth_service.dart',
    "    } catch (_) {}\n\n    if (matchedUser == null) {\n      // Fallback lookup\n      final dummyIndex = dummyUsers.indexWhere((u) => u.email.toLowerCase() == normalizedEmail);\n      if (dummyIndex != -1) {\n        matchedUser = dummyUsers[dummyIndex];\n      }\n    }",
    "    } catch (e) {\n      _handleError(e, 'AuthService.resetPassword');\n    }"
  );
  replace('lib/services/auth_service.dart', "import '../data/dummy_users.dart';", "");
  replace('lib/services/auth_service.dart', "import '../data/dummy_logs.dart';", "");
  
  // TeamStoreService (coach/parent separate if exists)
  replace('lib/services/team_store_service.dart', "import '../data/dummy_stores.dart';", "");
  replace('lib/services/team_store_service.dart', "import '../data/dummy_users.dart';", "");
}
