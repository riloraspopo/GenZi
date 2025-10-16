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
}