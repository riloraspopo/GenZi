import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:image_picker/image_picker.dart';
import 'package:myapp/constant.dart';
import 'package:myapp/services/appwrite_service.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:typed_data';

class ComplaintPage extends StatefulWidget {
  const ComplaintPage({super.key});

  @override
  ComplaintPageState createState() => ComplaintPageState();
}

class ComplaintPageState extends State<ComplaintPage> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  Uint8List? _webImage;
  String? _imagePath; // Store the path for both web and mobile
  final TextEditingController _complaintController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _complaintController.dispose();
    super.dispose();
  }

  Future<File?> _compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      // Calculate image size in MB
      final bytes = await file.readAsBytes();
      final sizeInMb = bytes.length / (1024 * 1024);

      // Determine quality based on image size
      int quality = 85; // Default quality
      if (sizeInMb > 10) {
        quality = 40;
      } else if (sizeInMb > 5) {
        quality = 50;
      } else if (sizeInMb > 2) {
        quality = 70;
      }

      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        targetPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      if (kDebugMode) debugPrint('Error compressing image: $e');
      return null;
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920, // Limit max width to 1920px
        maxHeight: 1920, // Limit max height to 1920px
      );

      if (image != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Memproses gambar...'),
              duration: Duration(seconds: 1),
            ),
          );
        }

        if (kIsWeb) {
          // For web, read as bytes
          final bytes = await image.readAsBytes();
          if (mounted) {
            setState(() {
              _webImage = bytes;
              _imagePath = image.path;
              _selectedImage = null;
            });
          }
        } else {
          // For mobile, use File
          final File imageFile = File(image.path);
          // Compress image
          final File? compressedImage = await _compressImage(imageFile);

          if (mounted) {
            setState(() {
              _selectedImage = compressedImage ?? imageFile;
              _imagePath = (compressedImage ?? imageFile).path;
              _webImage = null;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitComplaint() async {
    if (_complaintController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon isi deskripsi pengaduan')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Get current user
      final user = await AppwriteService.getCurrentUser();
      if (user == null) throw Exception('User not found');

      // Upload image first if selected
      String? fileId;
      if (_selectedImage != null || _webImage != null) {
        final file = await AppwriteService.uploadFile(
          bucketId: AppwriteConstants.PENGADUAN_BUCKET_ID,
          filePath: _imagePath!,
          userId: user.$id,
          fileBytes: _webImage,
          fileName: kIsWeb
              ? 'complaint_${DateTime.now().millisecondsSinceEpoch}.jpg'
              : null,
        );
        fileId = file.$id;
      }

      // Create complaint document
      await AppwriteService.createComplaint(
        userId: user.$id,
        description: _complaintController.text,
        imageId: fileId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengaduan berhasil dikirim')),
      );

      // Reset form
      setState(() {
        _selectedImage = null;
        _webImage = null;
        _imagePath = null;
        _complaintController.clear();
      });

      // Go back to dashboard
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting complaint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaduan')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _complaintController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Tulis deskripsi pengaduan di sini...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    if (_selectedImage != null || _webImage != null) ...[
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(8),
                            ),
                            child: kIsWeb && _webImage != null
                                ? Image.memory(
                                    _webImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    _selectedImage!,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withAlpha(
                                  (0.5 * 255).round(),
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _webImage = null;
                                    _imagePath = null;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 1),
                    ],
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isSubmitting ? null : _pickImage,
                              icon: const Icon(Icons.photo_library),
                              label: Text(
                                _selectedImage == null && _webImage == null
                                    ? 'Pilih Gambar dari Galeri'
                                    : 'Ganti Gambar',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitComplaint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Kirim Pengaduan',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
