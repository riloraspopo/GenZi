import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:video_thumbnail/video_thumbnail.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final DefaultCacheManager _cacheManager = DefaultCacheManager();

  // Cache duration for different media types
  static const Duration _pdfCacheDuration = Duration(days: 7);
  static const Duration _imageCacheDuration = Duration(days: 7);
  static const Duration _videoCacheDuration = Duration(days: 3);

  // Get cached file
  Future<File?> getCachedFile(String url) async {
    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      if (fileInfo != null && await fileInfo.file.exists()) {
        return fileInfo.file;
      }
      return null;
    } catch (e) {
      print('Error getting cached file: $e');
      return null;
    }
  }

  // Download and cache file
  Future<File> downloadAndCacheFile(String url,
      {Duration? cacheDuration}) async {
    try {
      final fileStream = _cacheManager.getFileStream(
        url,
        key: url,
        withProgress: true,
      );

      File? resultFile;
      await for (final result in fileStream) {
        if (result is FileInfo) {
          resultFile = result.file;
          break;
        }
      }

      if (resultFile == null) {
        throw Exception('Failed to download file');
      }

      return resultFile;
    } catch (e) {
      print('Error downloading and caching file: $e');
      rethrow;
    }
  }

  // Cache PDF file
  Future<File> cachePDF(String url) async {
    return await downloadAndCacheFile(url, cacheDuration: _pdfCacheDuration);
  }

  // Cache image file
  Future<File> cacheImage(String url) async {
    return await downloadAndCacheFile(url, cacheDuration: _imageCacheDuration);
  }

  // Cache video file
  Future<File> cacheVideo(String url) async {
    return await downloadAndCacheFile(url, cacheDuration: _videoCacheDuration);
  }

  // Generate and cache video thumbnail
  Future<String?> cacheVideoThumbnail(String videoUrl) async {
    try {
      final cacheDir = await getTemporaryDirectory();
      final thumbnailPath = path.join(
        cacheDir.path,
        'thumbnails',
        '${Uri.parse(videoUrl).pathSegments.last}.jpg',
      );

      // Create thumbnails directory if it doesn't exist
      final thumbnailDir = Directory(path.dirname(thumbnailPath));
      if (!await thumbnailDir.exists()) {
        await thumbnailDir.create(recursive: true);
      }

      // Generate thumbnail if it doesn't exist
      if (!await File(thumbnailPath).exists()) {
        final thumbnail = await VideoThumbnail.thumbnailFile(
          video: videoUrl,
          thumbnailPath: thumbnailPath,
          imageFormat: ImageFormat.JPEG,
          quality: 75,
        );
        return thumbnail;
      }

      return thumbnailPath;
    } catch (e) {
      print('Error generating video thumbnail: $e');
      return null;
    }
  }

  // Clear specific cache
  Future<void> clearCache(String url) async {
    await _cacheManager.removeFile(url);
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    await _cacheManager.emptyCache();
  }

  // Check if file is cached
  Future<bool> isFileCached(String url) async {
    final fileInfo = await _cacheManager.getFileFromCache(url);
    return fileInfo != null && await fileInfo.file.exists();
  }
}
