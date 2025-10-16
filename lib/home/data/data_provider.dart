import 'package:flutter/foundation.dart';
import 'package:myapp/home/models/educational_content.dart';
import 'package:myapp/services/appwrite_service.dart';

class DataProvider {
  static const String mediaBucketId = '68f05cfc00260ee4afd8';

  static Future<List<EducationalPoster>> getPosters() async {
    try {
      final files = await AppwriteService.listFiles(mediaBucketId);
      
      final posters = files
          .where((file) => !file.mimeType.startsWith('application/pdf')) // Filter out PDFs
          .map((file) => EducationalPoster(
            id: file.$id,
             title: file.name.substring(0, file.name.lastIndexOf('.')),
            imageUrl: AppwriteService.getFileView(
              mediaBucketId, 
              file.$id
            ),
            description: file.name,
          ))
          .toList();

      if (kDebugMode) {
        print('Found ${posters.length} posters');
      } // Debug info
      return posters;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting posters: $e');
      }
      rethrow; // Re-throw to handle in UI
    }
  }

  static Future<List<PdfResource>> getPdfResources() async {
    try {
      final files = await AppwriteService.listFiles(mediaBucketId);
      
      return files
        .where((file) => file.mimeType.startsWith('application/pdf'))
        .map((file) => PdfResource(
          id: file.$id,
           title: file.name.substring(0, file.name.lastIndexOf('.')),
          pdfUrl: AppwriteService.getFileView(
            mediaBucketId, 
            file.$id
          ),
          thumbnailUrl: 'https://via.placeholder.com/150',
          description: file.name,
        )).toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting PDF resources: $e');
      return [];
    }
  }

  static List<InformationItem> getInformationItems() {
    return [
      InformationItem(
        id: '1',
        title: 'Memory Techniques',
        content: '''Master these proven memory techniques to enhance your learning:
• Active Recall: Test yourself frequently
• Spaced Repetition: Review material at increasing intervals
• Mind Mapping: Create visual connections
• Chunking: Break information into manageable parts
• Teaching Others: Explain concepts to reinforce understanding''',
      ),
      InformationItem(
        id: '2',
        title: 'Time Management',
        content: '''Effective time management strategies for students:
• Use a digital calendar for scheduling
• Break tasks into 25-minute focused sessions
• Prioritize tasks using the Eisenhower Matrix
• Create daily and weekly study schedules
• Set specific, achievable goals''',
      ),
      InformationItem(
        id: '3',
        title: 'Note-Taking Methods',
        content: '''Improve your note-taking with these methods:
• Cornell Method: Divide page into sections
• Mind Mapping: Create visual connections
• Outline Method: Organize with headings
• Flowchart Method: Show process flows
• Digital Tools: Use apps for organization''',
      ),
    ];
  }
}