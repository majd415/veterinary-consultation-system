import '../data/services/api_service.dart';

class ImageHelper {
  /// Constructs full image URL from relative path
  /// Handles null/empty paths gracefully
  ///
  /// Examples:
  /// - getImageUrl('uploads/avatars/123.jpg') → http://192.168.1.8:8081/.../123.jpg
  /// - getImageUrl(null) → null
  /// - getImageUrl('http://...') → http://... (already full URL)
  static String? getImageUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) {
      return null;
    }

    // If already a full URL, return as-is
    if (relativePath.startsWith('http://') ||
        relativePath.startsWith('https://')) {
      return relativePath;
    }

    // Remove leading slash if present
    final cleanPath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;

    // Construct full URL using current API base
    final baseUrl = ApiService.apiBaseUrl.replaceAll('/api/', '/');
    return '$baseUrl$cleanPath';
  }

  /// Returns placeholder for null/empty images
  static String getImageUrlOrPlaceholder(
    String? relativePath, {
    String placeholder = '',
  }) {
    return getImageUrl(relativePath) ?? placeholder;
  }
}
