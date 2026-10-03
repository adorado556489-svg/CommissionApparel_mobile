import 'package:cloud_firestore/cloud_firestore.dart';

/// Site setting model matching the Laravel SiteSetting Eloquent model.
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

  factory SiteSetting.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SiteSetting(
      id: doc.id,
      key: data['key'] ?? '',
      value: data['value'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'key': key,
      'value': value,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  SiteSetting copyWith({
    String? id,
    String? key,
    String? value,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SiteSetting(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
