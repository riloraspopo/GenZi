import 'package:flutter/foundation.dart';
import 'package:myapp/constant.dart';
import 'package:myapp/home/models/educational_content.dart';
import 'package:myapp/services/appwrite_service.dart';

class DataProvider {
  static const String mediaBucketId = AppwriteConstants.MEDIA_BUCKET_ID;

  static Future<List<EducationalPoster>> getPosters() async {
    try {
      final files = await AppwriteService.listFiles(mediaBucketId);

      final posters = files
          .where(
            (file) =>
                !file.mimeType.startsWith(
                  'application/pdf',
                ) && // Filter out PDFs
                !file.mimeType.toLowerCase().startsWith(
                  'video/',
                ) && // Filter out videos by MIME type
                !file.name.toLowerCase().endsWith(
                  '.mp4',
                ) && // Filter out video files by extension
                !file.name.toLowerCase().endsWith('.mov') &&
                !file.name.toLowerCase().endsWith('.avi') &&
                !file.name.toLowerCase().endsWith('.mkv') &&
                !file.name.toLowerCase().endsWith('.webm'),
          )
          .map(
            (file) => EducationalPoster(
              id: file.$id,
              title: file.name.substring(0, file.name.lastIndexOf('.')),
              imageUrl: AppwriteService.getFileView(mediaBucketId, file.$id),
              description: file.name,
            ),
          )
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
          .map(
            (file) => PdfResource(
              id: file.$id,
              title: file.name.substring(0, file.name.lastIndexOf('.')),
              pdfUrl: AppwriteService.getFileView(mediaBucketId, file.$id),
              thumbnailUrl: 'https://via.placeholder.com/150',
              description: file.name,
            ),
          )
          .toList();
    } catch (e) {
      // ignore: avoid_print
      print('Error getting PDF resources: $e');
      return [];
    }
  }

  static Future<int> getVideoCount() async {
    try {
      final files = await AppwriteService.listFiles(mediaBucketId);

      final videoFiles = files
          .where(
            (file) =>
                file.mimeType.toLowerCase().startsWith(
                  'video/',
                ) || // Filter videos by MIME type
                file.name.toLowerCase().endsWith(
                  '.mp4',
                ) || // Filter video files by extension
                file.name.toLowerCase().endsWith('.mov') ||
                file.name.toLowerCase().endsWith('.avi') ||
                file.name.toLowerCase().endsWith('.mkv') ||
                file.name.toLowerCase().endsWith('.webm'),
          )
          .toList();

      if (kDebugMode) {
        print('Found ${videoFiles.length} video files');
        for (var file in videoFiles) {
          print('Video file: ${file.name}, MIME: ${file.mimeType}');
        }
      }

      return videoFiles.length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting video count: $e');
      }
      return 0;
    }
  }

  static List<InformationItem> getInformationItems() {
    return [
      InformationItem(
        id: '1',
        title: 'Teknik Mengingat',
        content:
            '''Kuasai teknik mengingat yang terbukti untuk meningkatkan pembelajaran:
• Mengingat Aktif: Uji diri sendiri secara berkala
• Pengulangan Berjarak: Tinjau materi dengan interval yang meningkat
• Peta Pikiran: Buat koneksi visual
• Pemecahan: Bagi informasi menjadi bagian yang mudah dikelola
• Mengajar Orang Lain: Jelaskan konsep untuk memperkuat pemahaman''',
      ),
      InformationItem(
        id: '2',
        title: 'Manajemen Waktu',
        content: '''Strategi manajemen waktu yang efektif untuk siswa:
• Gunakan kalender digital untuk penjadwalan
• Bagi tugas menjadi sesi fokus 25 menit
• Prioritaskan tugas menggunakan Matriks Eisenhower
• Buat jadwal belajar harian dan mingguan
• Tetapkan tujuan yang spesifik dan dapat dicapai''',
      ),
      InformationItem(
        id: '3',
        title: 'Metode Mencatat',
        content: '''Tingkatkan cara mencatat dengan metode ini:
• Metode Cornell: Bagi halaman menjadi beberapa bagian
• Peta Pikiran: Buat koneksi visual
• Metode Outline: Atur dengan judul
• Metode Flowchart: Tunjukkan alur proses
• Alat Digital: Gunakan aplikasi untuk organisasi''',
      ),
    ];
  }
}
