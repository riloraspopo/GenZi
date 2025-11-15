import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

// Conditional imports for mobile
import 'dart:io' show File;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// For web support
import 'dart:ui_web' as ui_web;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 0;
  final Dio _dio = Dio();
  late final String _iframeId;

  @override
  void initState() {
    super.initState();
    _iframeId = 'pdf-viewer-iframe-${DateTime.now().millisecondsSinceEpoch}';
    if (kIsWeb) {
      _setupWebPdfViewer();
    } else {
      _downloadAndOpenPdf();
    }
  }

  void _setupWebPdfViewer() {
    try {
      // Register the iframe view factory for web
      // ignore: undefined_prefixed_name
      ui_web.platformViewRegistry.registerViewFactory(_iframeId, (int viewId) {
        final iframe = html.IFrameElement()
          ..src = widget.pdfUrl
          ..style.border = 'none'
          ..style.height = '100%'
          ..style.width = '100%';
        return iframe;
      });

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error loading PDF: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      // Get the temporary directory
      final dir = await getTemporaryDirectory();
      // Create unique filename using URL hash to prevent cache conflicts
      final fileName =
          '${widget.pdfUrl.hashCode}_${path.basename(widget.pdfUrl)}';
      final filePath = path.join(dir.path, fileName);
      final file = File(filePath);

      // Check if file exists in cache
      if (await file.exists()) {
        setState(() {
          localPath = filePath;
          isLoading = false;
        });
        return;
      }

      // Download the PDF
      await _dio.download(
        widget.pdfUrl,
        filePath,
        options: Options(headers: {'X-Requested-With': 'XMLHttpRequest'}),
      );

      if (await file.exists()) {
        setState(() {
          localPath = filePath;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Gagal mengunduh PDF';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        actions: [
          if (!isLoading && !hasError && totalPages > 0 && !kIsWeb)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Center(
                child: Text(
                  '$currentPage / $totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat PDF...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: kIsWeb ? null : _downloadAndOpenPdf,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

    if (kIsWeb) {
      // For web, use HtmlElementView with iframe
      return HtmlElementView(viewType: _iframeId);
    } else {
      // For mobile, use flutter_pdfview
      if (localPath != null) {
        return PDFView(
          filePath: localPath!,
          enableSwipe: true,
          swipeHorizontal: false,
          autoSpacing: false,
          pageFling: false,
          onRender: (pages) {
            setState(() {
              totalPages = pages ?? 0;
            });
          },
          onViewCreated: (PDFViewController pdfViewController) {
            // PDF view created
          },
          onPageChanged: (int? page, int? total) {
            setState(() {
              currentPage = (page ?? 0) + 1;
              totalPages = total ?? 0;
            });
          },
          onError: (error) {
            setState(() {
              hasError = true;
              errorMessage = 'Error membuka PDF: $error';
            });
          },
          onPageError: (page, error) {
            setState(() {
              hasError = true;
              errorMessage = 'Error pada halaman $page: $error';
            });
          },
        );
      }
    }

    return const Center(child: Text('Tidak dapat memuat PDF'));
  }

  Future<void> _cleanupCache() async {
    if (kIsWeb) return;

    try {
      if (localPath != null) {
        final file = File(localPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      // Ignore cleanup errors
    }
  }

  @override
  void dispose() {
    _dio.close();
    _cleanupCache(); // Cleanup cached file
    super.dispose();
  }
}
