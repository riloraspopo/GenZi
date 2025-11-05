import 'package:flutter/material.dart';
import 'package:myapp/constant.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:intl/intl.dart';
import 'package:myapp/home/view/full_screen_image_viewer.dart';

class ComplaintHistoryPage extends StatefulWidget {
  const ComplaintHistoryPage({super.key});

  @override
  ComplaintHistoryPageState createState() => ComplaintHistoryPageState();
}

class ComplaintHistoryPageState extends State<ComplaintHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _complaints = [];

  @override
  void initState() {
    super.initState();
    _loadComplaints();
  }

  Future<void> _loadComplaints() async {
    try {
      final user = await AppwriteService.getCurrentUser();
      if (user == null) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/login');
        }
        return;
      }

      final complaints = await AppwriteService.getComplaintHistory(user.$id);

      if (mounted) {
        setState(() {
          _complaints = complaints;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading complaints: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Widget _buildComplaintCard(Map<String, dynamic> complaint) {
    final hasResponse =
        complaint['response'] != null &&
        complaint['response'].toString().isNotEmpty;
    final hasImage = complaint['imageId'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(complaint['timestamp']),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  complaint['description'],
                  style: const TextStyle(fontSize: 16),
                ),
                if (hasImage) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            imageUrl: AppwriteService.getFileView(
                              AppwriteConstants.PENGADUAN_BUCKET_ID,
                              complaint['imageId'],
                            ),
                            title: 'Gambar Pengaduan',
                          ),
                        ),
                      );
                    },
                    child: Hero(
                      tag: AppwriteService.getFileView(
                        AppwriteConstants.PENGADUAN_BUCKET_ID,
                        complaint['imageId'],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              AppwriteService.getFileView(
                                AppwriteConstants.PENGADUAN_BUCKET_ID,
                                complaint['imageId'],
                              ),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.error_outline),
                                  ),
                                );
                              },
                            ),
                            // Zoom indicator overlay
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(
                                  (0.3 * 255).round(),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.zoom_in,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                if (hasResponse) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.reply, size: 16, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Tanggapan:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(complaint['response'].toString()),
                        if (complaint['responseTimestamp'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _formatDate(complaint['responseTimestamp']),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pengaduan')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _complaints.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada riwayat pengaduan',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadComplaints,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _complaints.length,
                itemBuilder: (context, index) {
                  return _buildComplaintCard(_complaints[index]);
                },
              ),
            ),
    );
  }
}
