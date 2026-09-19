/// Site setting model matching the Laravel `SiteSetting` Eloquent model.
///
/// Simple key-value pairs for admin-configurable site settings like hero
/// text, contact info, and feature flags.
class SiteSetting {
  final String id;
  final String key;
  final String? value;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SiteSetting({
    required this.id,
    required this.key,
    this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Look up a setting by key from a list.
  static String? getValue(List<SiteSetting> settings, String key) {
    for (final s in settings) {
      if (s.key == key) return s.value;
    }
    return null;
  }

  /// Look up a setting with a fallback default.
  static String getValueOr(
    List<SiteSetting> settings,
    String key,
    String defaultValue,
  ) {
    return getValue(settings, key) ?? defaultValue;
  }
}
