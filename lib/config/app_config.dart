/// Centralised, environment-overridable application configuration.
///
/// Values can be overridden at build time without code changes, e.g.:
/// `flutter build apk --dart-define=CLOUDINARY_CLOUD_NAME=my-cloud`
class AppConfig {
  AppConfig._();

  static const String appName = 'Commission Apparel';

  // Image hosting (Cloudinary unsigned upload preset).
  // Restrict the preset in the Cloudinary console (allowed formats, max size,
  // target folder) before production.
  static const String cloudinaryCloudName =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME', defaultValue: 'brtamhix');
  static const String cloudinaryUploadPreset = String.fromEnvironment(
      'CLOUDINARY_UPLOAD_PRESET',
      defaultValue: 'commission_apparel');

  // Support contact shown in Help & Support.
  static const String supportEmail = String.fromEnvironment('SUPPORT_EMAIL',
      defaultValue: 'support@commissionapparel.com');
  static const String supportPhone =
      String.fromEnvironment('SUPPORT_PHONE', defaultValue: '');

  /// Upload limits enforced client-side before sending to the image host.
  static const int maxImageBytes = 10 * 1024 * 1024; // 10 MB
  static const int imageMaxDimension = 1600; // px, longest side
  static const int imageQuality = 85; // JPEG quality 0-100
}
