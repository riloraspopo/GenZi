import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

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
  
  @override
  void initState() {
    super.initState();
    _downloadAndOpenPdf();
  }

  Future<void> _downloadAndOpenPdf() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
      });

      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/temp_pdf.pdf');
        await file.writeAsBytes(bytes);
        
        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = 'Gagal mengunduh PDF: ${response.statusCode}';
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
          if (!isLoading && !hasError && totalPages > 0)
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
            Text('Mengunduh PDF...'),
          ],
        ),
      );
    }

    if (hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage ?? 'Terjadi kesalahan',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _downloadAndOpenPdf,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }

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

    return const Center(
      child: Text('Tidak dapat memuat PDF'),
    );
  }
}