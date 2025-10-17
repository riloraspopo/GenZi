import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:logging/logging.dart';
import '../constant.dart';

class AppwriteService {
  static final _log = Logger('AppwriteService');

  static Client get _client {
    Client client = Client();
    client
        .setEndpoint(AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT)
        .setProject(AppwriteConstants.APPWRITE_PROJECT_ID);
    return client;
  }

  static Storage get _storage => Storage(_client);

  static String getFileView(String bucketId, String fileId) {
    return '${AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConstants.APPWRITE_PROJECT_ID}';
  }

  static Future<List<models.File>> listFiles(String bucketId) async {
    try {
      final result = await _storage.listFiles(
        bucketId: bucketId,
        queries: [
          Query.limit(100),
          Query.offset(0),
        ],
      );
      _log.info('Found ${result.files.length} files in bucket $bucketId');
      return result.files;
    } catch (e) {
      _log.severe('Error listing files: $e');
      rethrow; // Throw error so we can handle it in UI
    }
  }

  static Future<List<models.File>> listVideoFiles(String bucketId) async {
    try {
      final result = await _storage.listFiles(
        bucketId: bucketId,
        queries: [
          Query.limit(100),
          Query.offset(0),
        ],
      );
      
      // Filter for video files only
      final videoFiles = result.files.where((file) {
        final mimeType = file.mimeType.toLowerCase();
        return mimeType.startsWith('video/') || 
               file.name.toLowerCase().endsWith('.mp4') ||
               file.name.toLowerCase().endsWith('.mov') ||
               file.name.toLowerCase().endsWith('.avi') ||
               file.name.toLowerCase().endsWith('.mkv') ||
               file.name.toLowerCase().endsWith('.webm');
      }).toList();
      
      _log.info('Found ${videoFiles.length} video files in bucket $bucketId');
      return videoFiles;
    } catch (e) {
      _log.severe('Error listing video files: $e');
      rethrow;
    }
  }

  static String getVideoUrl(String bucketId, String fileId) {
    return '${AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConstants.APPWRITE_PROJECT_ID}';
  }

  static String getVideoDownloadUrl(String bucketId, String fileId) {
    return '${AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT}/storage/buckets/$bucketId/files/$fileId/download?project=${AppwriteConstants.APPWRITE_PROJECT_ID}';
  }
}