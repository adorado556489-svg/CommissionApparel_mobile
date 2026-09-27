import 'dart:io';

void main() {
  var file = File('lib/services/content_service.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('\r\n', '\n');

  content = content.replaceAll(
    "    } catch (_) {\n      final notifs = dummyNotifications.where((n) => n.userId == userId).toList();\n      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));\n      return notifs;\n    }",
    "    } catch (e) {\n      _handleError(e, 'ContentService');\n      return [];\n    }"
  );
  
  content = content.replaceAll(
    "    } catch (_) {}\n    return dummyNotifications.where((n) => n.userId == userId).toList();",
    "    } catch (e) {\n      _handleError(e, 'ContentService');\n      return [];\n    }"
  );

  content = content.replaceAll(
    "    try {\n      final dummyIndex = dummyNotifications.indexWhere((n) => n.id == notificationId);\n      if (dummyIndex != -1) {\n        dummyNotifications[dummyIndex] = dummyNotifications[dummyIndex].copyWith(isRead: true);\n      }\n    } catch (_) {}",
    ""
  );

  file.writeAsStringSync(content);
}
