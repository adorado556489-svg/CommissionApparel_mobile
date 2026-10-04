/// Display-time helpers for hosted images.
///
/// Uploading and the Cloudinary connection are untouched; this only rewrites
/// the URL we *display* so thumbnails are downloaded at a sensible size
/// instead of the full-resolution original.
class ImageUrls {
  ImageUrls._();

  static const String _marker = '/image/upload/';

  /// Whether [url] is a Cloudinary delivery URL we can safely transform.
  static bool isCloudinary(String url) =>
      url.contains('res.cloudinary.com') && url.contains(_marker);

  /// Returns [url] with a Cloudinary resize/optimise transformation inserted
  /// (`c_limit,w_<width>,q_auto,f_auto`). Non-Cloudinary URLs are returned
  /// unchanged. [width] is rounded up to the next 100px so the CDN can reuse
  /// cached variants.
  static String optimized(String url, {required int width}) {
    if (!isCloudinary(url)) return url;
    final bucket = ((width.clamp(100, 1600) + 99) ~/ 100) * 100;
    return url.replaceFirst(_marker, '${_marker}c_limit,w_$bucket,q_auto,f_auto/');
  }
}
