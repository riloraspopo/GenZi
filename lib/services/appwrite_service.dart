import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models;
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:myapp/home/models/bmi_record.dart';
import '../constant.dart';
import '../home/models/educational_content.dart';
import '../home/models/study_tip.dart';

class AppwriteService {
  static final _log = Logger('AppwriteService');
  static Account? _account;
  static Databases? _databases;

  static Client get _client {
    Client client = Client();
    client
        .setEndpoint(AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT)
        .setProject(AppwriteConstants.APPWRITE_PROJECT_ID);
    return client;
  }

  static Account get account {
    _account ??= Account(_client);
    return _account!;
  }

  static Databases get databases {
    _databases ??= Databases(_client);
    return _databases!;
  }

  static Storage get _storage => Storage(_client);

  // Auth Methods
  static Future<models.Session> createEmailSession(
    String email,
    String password,
  ) async {
    try {
      final session = await account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      _log.info('Session created for user: ${session.userId}');
      return session;
    } catch (e) {
      _log.severe('Error creating session: $e');
      rethrow;
    }
  }

  static Future<models.User> createTeacherAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      final user = await account.create(
        userId: ID.unique(),
        email: email,
        password: password,
        name: name,
      );
      _log.info('Teacher account created: ${user.email}');
      return user;
    } catch (e) {
      _log.severe('Error creating teacher account: $e');
      rethrow;
    }
  }

  static Future<void> deleteCurrentSession() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _log.info('Session deleted');
    } catch (e) {
      _log.severe('Error deleting session: $e');
      rethrow;
    }
  }

  static Future<models.User?> getCurrentUser() async {
    try {
      final user = await account.get();
      _log.info('Current user: ${user.email}');
      return user;
    } catch (e) {
      _log.info('No current user: $e');
      return null;
    }
  }

  static Future<bool> hasValidSession() async {
    try {
      final session = await account.getSession(sessionId: 'current');
      _log.info('Found valid session for user: ${session.userId}');
      return true;
    } catch (e) {
      _log.info('No valid session found: $e');
      return false;
    }
  }

  static Future<void> init() async {
    try {
      // Try to get an existing session
      if (await hasValidSession()) {
        _log.info('Initialized with existing session');
      }
    } catch (e) {
      _log.warning('Error initializing session: $e');
    }
  }

  // Create test survey questions
  static Future<void> createTestSurveyQuestions() async {
    try {
      final testQuestions = [
        {
          'question': 'Bagaimana pemahaman siswa tentang materi gizi seimbang?',
          'options': ['Sangat Baik', 'Baik', 'Cukup', 'Perlu Peningkatan'],
        },
        {
          'question':
              'Seberapa aktif partisipasi siswa dalam kegiatan pembelajaran gizi?',
          'options': ['Sangat Aktif', 'Aktif', 'Cukup Aktif', 'Kurang Aktif'],
        },
        {
          'question':
              'Apakah siswa menerapkan pengetahuan gizi dalam kehidupan sehari-hari?',
          'options': ['Selalu', 'Sering', 'Kadang-kadang', 'Jarang'],
        },
        {
          'question':
              'Bagaimana tingkat kesadaran siswa tentang pentingnya makanan bergizi?',
          'options': ['Sangat Tinggi', 'Tinggi', 'Sedang', 'Rendah'],
        },
        {
          'question':
              'Seberapa efektif metode pembelajaran gizi yang diterapkan?',
          'options': [
            'Sangat Efektif',
            'Efektif',
            'Cukup Efektif',
            'Perlu Perbaikan',
          ],
        },
      ];

      for (var question in testQuestions) {
        await databases.createDocument(
          databaseId: AppwriteConstants.DATABASE_ID,
          collectionId: AppwriteConstants.SURVEY_COLLECTION_ID,
          documentId: ID.unique(),
          data: question,
        );
        _log.info('Created test question: ${question['question']}');
      }

      _log.info('Successfully created all test survey questions');
    } catch (e) {
      _log.severe('Error creating test survey questions: $e');
      rethrow;
    }
  }

  // Survey Methods
  static Future<List<Map<String, dynamic>>> getSurveyQuestions() async {
    try {
      // await databases.createDocument(
      //   databaseId: AppwriteConstants.DATABASE_ID,
      //   collectionId: AppwriteConstants.SURVEY_COLLECTION_ID,
      //   documentId: ID.unique(),
      //   data: question,
      // );

      Client myclient = Client()
          .setEndpoint(AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT)
          .setProject(AppwriteConstants.APPWRITE_PROJECT_ID);

      Databases mydatabases = Databases(myclient);

      final result = await mydatabases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.SURVEY_COLLECTION_ID,
      );
      _log.info('Retrieved ${result.documents.length} survey questions');

      // Convert documents to maps with proper type checking
      if (kDebugMode) {
        print('Processing ${result.documents.length} documents from Appwrite');
      }
      return result.documents.map((doc) {
        final data = doc.data;
        // Print the raw data for debugging
        if (kDebugMode) {
          print('Processing document ${doc.$id}:');
          print('Raw data: $data');
        }

        // Safely extract and convert the data with proper null checking
        dynamic rawOptions = data['options'];
        List<String> options = [];

        if (rawOptions != null) {
          if (rawOptions is List) {
            options = rawOptions.map((opt) => opt?.toString() ?? '').toList();
          } else {
            if (kDebugMode) {
              print(
                'Warning: options field is not a List: ${rawOptions.runtimeType}',
              );
            }
          }
        }

        final processedData = {
          '\$id': doc.$id,
          'question': data['question']?.toString() ?? '',
          'options': options,
          'selectedOption': null,
        };

        if (kDebugMode) {
          print('Processed data: $processedData');
        }
        return processedData;
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _log.severe('Error getting survey questions: $e');
      rethrow;
    }
  }

  static Future<void> submitSurveyResponse(
    String questionId,
    String response,
    String userId,
    String question,
    String submissionId,
  ) async {
    try {
      await databases.createDocument(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.SURVEY_RESPONSES_COLLECTION_ID,
        documentId: ID.unique(),
        data: {
          'questionId': questionId,
          'response': response,
          'userId': userId,
          'question': question,
          'submissionId': submissionId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _log.info('Survey response submitted for submission: $submissionId');
    } catch (e) {
      _log.severe('Error submitting survey response: $e');
      rethrow;
    }
  }

  // Get user's survey history grouped by submission
  static Future<List<Map<String, dynamic>>> getUserSurveyHistory(
    String userId,
  ) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.SURVEY_RESPONSES_COLLECTION_ID,
        queries: [Query.equal('userId', userId), Query.orderDesc('timestamp')],
      );

      _log.info(
        'Retrieved ${result.documents.length} survey responses for user: $userId',
      );

      // First, create a map of submissionId to list of responses
      Map<String, List<Map<String, dynamic>>> submissionGroups = {};

      for (var doc in result.documents) {
        final data = doc.data;
        final submissionId = data['submissionId'] ?? '';
        final response = {
          '\$id': doc.$id,
          'userId': data['userId'] ?? '',
          'questionId': data['questionId'] ?? '',
          'response': data['response'] ?? '',
          'question': data['question'] ?? '',
          'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
          'submissionId': submissionId,
        };

        if (!submissionGroups.containsKey(submissionId)) {
          submissionGroups[submissionId] = [];
        }
        submissionGroups[submissionId]!.add(response);
      }

      // Convert the map to a list of submissions, sorting by timestamp
      List<Map<String, dynamic>> submissions = [];
      submissionGroups.forEach((submissionId, responses) {
        // Sort responses by question order (you might want to add a questionOrder field)
        responses.sort((a, b) => a['question'].compareTo(b['question']));

        submissions.add({
          'submissionId': submissionId,
          'timestamp': responses
              .first['timestamp'], // Use the timestamp of the first response
          'responses': responses,
        });
      });

      // Sort submissions by timestamp, newest first
      submissions.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));

      return submissions;
    } catch (e) {
      _log.severe('Error getting survey history: $e');
      rethrow;
    }
  }

  static String getFileView(String bucketId, String fileId) {
    return '${AppwriteConstants.APPWRITE_PUBLIC_ENDPOINT}/storage/buckets/$bucketId/files/$fileId/view?project=${AppwriteConstants.APPWRITE_PROJECT_ID}';
  }

  static Future<List<models.File>> listFiles(String bucketId) async {
    try {
      final result = await _storage.listFiles(
        bucketId: bucketId,
        queries: [Query.limit(100), Query.offset(0)],
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
        queries: [Query.limit(100), Query.offset(0)],
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

  // BMI Record Methods
  static Future<void> createBMIRecord(BMIRecord record) async {
    try {
      await databases.createDocument(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.BMI_RECORDS_COLLECTION_ID,
        documentId: ID.unique(),
        data: record.toMap(),
      );
      _log.info('BMI record created');
    } catch (e) {
      _log.severe('Error creating BMI record: $e');
      rethrow;
    }
  }

  static Future<List<BMIRecord>> getBMIRecords() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.BMI_RECORDS_COLLECTION_ID,
        queries: [Query.orderDesc('date')],
      );
      _log.info('Retrieved ${result.documents.length} BMI records');

      return result.documents.map((doc) {
        final data = doc.data;
        return BMIRecord.fromMap({'id': doc.$id, ...data});
      }).toList();
    } catch (e) {
      _log.severe('Error getting BMI records: $e');
      rethrow;
    }
  }

  static Future<void> updateBMIRecord(BMIRecord record) async {
    try {
      if (record.id == null) {
        throw Exception('Record ID is required for update');
      }

      await databases.updateDocument(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.BMI_RECORDS_COLLECTION_ID,
        documentId: record.id!,
        data: record.toMap(),
      );
      _log.info('BMI record updated: ${record.id}');
    } catch (e) {
      _log.severe('Error updating BMI record: $e');
      rethrow;
    }
  }

  static Future<void> deleteBMIRecord(String recordId) async {
    try {
      await databases.deleteDocument(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.BMI_RECORDS_COLLECTION_ID,
        documentId: recordId,
      );
      _log.info('BMI record deleted: $recordId');
    } catch (e) {
      _log.severe('Error deleting BMI record: $e');
      rethrow;
    }
  }

  // Study Tips Methods
  static Future<List<StudyTip>> getStudyTips() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.STUDY_TIPS_COLLECTION_ID,
        queries: [Query.orderDesc('createdAt')],
      );
      _log.info('Retrieved ${result.documents.length} study tips');

      return result.documents.map((doc) {
        final data = doc.data;
        return StudyTip.fromJson({
          '\$id': doc.$id,
          'title': data['title'] ?? '',
          'description': data['description'] ?? '',
          'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
        });
      }).toList();
    } catch (e) {
      _log.severe('Error getting study tips: $e');
      rethrow;
    }
  }

  // Complaint Methods
  static Future<List<Map<String, dynamic>>> getComplaintHistory(
    String userId,
  ) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.COMPLAINTS_COLLECTION_ID,
        queries: [Query.equal('userId', userId), Query.orderDesc('timestamp')],
      );

      _log.info(
        'Retrieved ${result.documents.length} complaints for user: $userId',
      );

      return result.documents.map((doc) {
        final data = doc.data;
        return {
          'id': doc.$id,
          'description': data['description'] ?? '',
          'imageId': data['imageId'],
          'timestamp': data['timestamp'] ?? '',
          'response': data['response'],
          'responseTimestamp': data['responseTimestamp'],
        };
      }).toList();
    } catch (e) {
      _log.severe('Error getting complaint history: $e');
      rethrow;
    }
  }

  // Complaint Methods
  static Future<models.File> uploadFile({
    required String bucketId,
    required String filePath,
    required String userId,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final file = await _storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: kIsWeb && fileBytes != null
            ? InputFile.fromBytes(
                bytes: fileBytes,
                filename: fileName ?? 'image.jpg',
              )
            : InputFile.fromPath(path: filePath),
      );
      _log.info('File uploaded: ${file.$id}');
      return file;
    } catch (e) {
      _log.severe('Error uploading file: $e');
      rethrow;
    }
  }

  static Future<void> createComplaint({
    required String userId,
    required String description,
    String? imageId,
  }) async {
    try {
      await databases.createDocument(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.COMPLAINTS_COLLECTION_ID,
        documentId: ID.unique(),
        data: {
          'userId': userId,
          'description': description,
          'imageId': imageId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _log.info('Complaint created for user: $userId');
    } catch (e) {
      _log.severe('Error creating complaint: $e');
      rethrow;
    }
  }

  // Poster Methods
  static Future<List<EducationalPoster>> getPostersFromDatabase({
    String? tagFilter,
  }) async {
    try {
      List<String> queries = [Query.limit(100)];

      if (tagFilter != null && tagFilter.isNotEmpty) {
        queries.add(Query.equal('tag', tagFilter));
      }

      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.POSTER_COLLECTION_ID,
        queries: queries,
      );

      _log.info('Retrieved ${result.documents.length} posters from database');

      // Get file details to extract filename
      final List<EducationalPoster> posters = [];

      for (var doc in result.documents) {
        final data = doc.data;
        final imageId = data['imageId'] ?? '';
        final tag = data['tag'] ?? '';

        // Get title from storage filename
        String title = 'Poster ${doc.$id.substring(0, 8)}';
        if (imageId.isNotEmpty) {
          try {
            final file = await _storage.getFile(
              bucketId: AppwriteConstants.MEDIA_BUCKET_ID,
              fileId: imageId,
            );
            // Extract filename without extension
            final filename = file.name;
            if (filename.contains('.')) {
              title = filename.substring(0, filename.lastIndexOf('.'));
            } else {
              title = filename;
            }
          } catch (e) {
            _log.warning('Could not get file details for $imageId: $e');
          }
        }

        posters.add(
          EducationalPoster(
            id: doc.$id,
            title: title,
            imageUrl: getFileView(AppwriteConstants.MEDIA_BUCKET_ID, imageId),
            description: data['description'] ?? '',
            tags: tag.isNotEmpty ? [tag] : [],
          ),
        );
      }

      return posters;
    } catch (e) {
      _log.severe('Error getting posters from database: $e');
      rethrow;
    }
  }

  static Future<List<String>> getPosterTags() async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppwriteConstants.DATABASE_ID,
        collectionId: AppwriteConstants.POSTER_COLLECTION_ID,
        queries: [Query.limit(100)],
      );

      final tagsSet = <String>{};
      for (var doc in result.documents) {
        final tag = doc.data['tag'];
        if (tag != null && tag.toString().isNotEmpty) {
          tagsSet.add(tag.toString());
        }
      }

      final tags = tagsSet.toList()..sort();
      _log.info('Found ${tags.length} unique tags');
      return tags;
    } catch (e) {
      _log.severe('Error getting poster tags: $e');
      rethrow;
    }
  }
}
