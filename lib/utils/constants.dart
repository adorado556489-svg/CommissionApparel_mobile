/// App-wide constants derived from the Laravel source analysis.
///
/// Centralizes all enumeration values, option lists, and string constants
/// so they can be reused across screens, forms, and services.
class AppConstants {
  AppConstants._();

  // ── User Roles ──────────────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleCoach = 'coach';
  static const String roleParent = 'parent';

  // ── User Statuses ───────────────────────────────────────────────────────
  static const String userStatusActive = 'active';
  static const String userStatusPending = 'pending';
  static const String userStatusDeclined = 'declined';
  static const String userStatusApproved = 'approved';

  // ── Sports ──────────────────────────────────────────────────────────────
  static const List<String> sports = [
    'Basketball',
    'Football',
    'Baseball',
    'Soccer',
    'Volleyball',
    'Track & Field',
    'Swimming',
    'Wrestling',
    'Cheer',
    'Lacrosse',
    'Softball',
    'Tennis',
    'Golf',
    'Hockey',
  ];

  // ── Sizes ───────────────────────────────────────────────────────────────
  static const List<String> youthSizes = ['YS', 'YM', 'YL'];
  static const List<String> adultSizes = [
    'XS',
    'S',
    'M',
    'L',
    'XL',
    '2XL',
    '3XL',
  ];
  static const List<String> allSizes = [...youthSizes, ...adultSizes];

  // ── Garment / Item Types ────────────────────────────────────────────────
  static const List<String> garmentTypes = [
    'Jersey',
    'Shorts',
    'Hoodie',
    'T-Shirt',
    'Jacket',
    'Pants',
    'Headwear',
    'Accessories',
    'Uniforms',
  ];

  // ── Package Types ───────────────────────────────────────────────────────
  static const List<String> packageTypes = [
    'package_a',
    'package_b',
    'package_c',
    'individual',
  ];

  static const Map<String, String> packageTypeLabels = {
    'package_a': 'Package A',
    'package_b': 'Package B',
    'package_c': 'Package C',
    'individual': 'Individual',
  };

  // ── Quote Package Types ─────────────────────────────────────────────────
  static const Map<String, String> quotePackageLabels = {
    'base_uniforms': 'Base Uniforms',
    'full_program_bundle': 'Full Program Bundle',
    'merch_only': 'Merch Only',
  };

  // ── Gender Options ──────────────────────────────────────────────────────
  static const List<String> genderOptions = ['Mens', 'Womens', 'Unisex'];

  // ── Order Statuses ──────────────────────────────────────────────────────
  static const String orderPendingCoach = 'Pending Coach Approval';
  static const String orderSubmittedAdmin = 'Submitted to Admin';
  static const String orderProcessing = 'Processing';

  // ── Store Statuses ──────────────────────────────────────────────────────
  static const String storePending = 'pending';
  static const String storeApproved = 'approved';
  static const String storeDeclined = 'declined';
  static const String storeSubmittedToAdmin = 'submitted_to_admin';

  // ── Quote Request Statuses ──────────────────────────────────────────────
  static const String quoteNew = 'new';
  static const String quoteAddressed = 'addressed';

  // ── Estimated Quantity Options ──────────────────────────────────────────
  static const List<String> estimatedQuantityOptions = [
    '1-25',
    '26-50',
    '51-100',
    '101-250',
    '250+',
  ];
}
