import 'dart:io';
import 'package:flutter/material.dart';

class ManagedImage {
  /// Returns the appropriate ImageProvider based on the path format.
  static ImageProvider getProvider(String? pathOrUrl, {String? defaultAsset}) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      if (defaultAsset != null) return AssetImage(defaultAsset);
      return const AssetImage('assets/images/placeholder.png'); // Fallback
    }
    if (pathOrUrl.startsWith('http') || pathOrUrl.startsWith('gs://')) {
      return NetworkImage(pathOrUrl);
    }
    if (pathOrUrl.startsWith('assets/')) {
      return AssetImage(pathOrUrl);
    }
    return FileImage(File(pathOrUrl));
  }

  /// Returns a Widget based on the path format.
  static Widget getWidget(String? pathOrUrl, {
    String? defaultAsset,
    BoxFit? fit,
    double? width,
    double? height,
  }) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) {
      if (defaultAsset != null) return Image.asset(defaultAsset, fit: fit, width: width, height: height);
      return Image.asset('assets/images/placeholder.png', fit: fit, width: width, height: height);
    }
    if (pathOrUrl.startsWith('http') || pathOrUrl.startsWith('gs://')) {
      return Image.network(
        pathOrUrl, 
        fit: fit, 
        width: width, 
        height: height,
        errorBuilder: (context, error, stackTrace) => _fallback(defaultAsset, fit, width, height),
      );
    }
    if (pathOrUrl.startsWith('assets/')) {
      return Image.asset(pathOrUrl, fit: fit, width: width, height: height);
    }
    return Image.file(
      File(pathOrUrl), 
      fit: fit, 
      width: width, 
      height: height,
      errorBuilder: (context, error, stackTrace) => _fallback(defaultAsset, fit, width, height),
    );
  }

  static Widget _fallback(String? defaultAsset, BoxFit? fit, double? width, double? height) {
    if (defaultAsset != null) return Image.asset(defaultAsset, fit: fit, width: width, height: height);
    return Image.asset('assets/images/placeholder.png', fit: fit, width: width, height: height);
  }
}
